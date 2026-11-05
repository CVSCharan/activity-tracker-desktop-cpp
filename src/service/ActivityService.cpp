#include "ActivityService.h"
#include "persistence/JsonStore.h"
#include <QDate>
#include <QString>
#include <QTimer>

// ─────────────────────────────────────────────────────────────────────────────
// Constructor
//
// 'new ActivityListModel(this)' — allocates model on the heap.
//   - 'this' is passed as the parent, so Qt will automatically delete
//     m_model when ActivityService is destroyed (RAII ownership tree).
//   - JS equivalent: this.model = new ActivityListModel();
//     but in Qt, the parent handles cleanup — no manual delete needed.
// ─────────────────────────────────────────────────────────────────────────────
ActivityService::ActivityService(QObject *parent)
    : QObject(parent)
    , m_model(new ActivityListModel(this))   // parent = this → auto-deleted
{
    // Load persisted data on startup
    const QVector<Activity> saved = JsonStore::load();
    if (!saved.isEmpty())
        m_model->resetWith(saved);

    // Keep stats in sync whenever model row count changes
    connect(m_model, &ActivityListModel::countChanged, this, &ActivityService::statsChanged);
}

// ─────────────────────────────────────────────────────────────────────────────
// totalDurationToday — computed property (no cache; recalculated on each read)
//
// STL-style: std::accumulate would also work, but a plain loop is clearer here.
// ─────────────────────────────────────────────────────────────────────────────
int ActivityService::totalDurationToday() const
{
    const QDate today = QDate::currentDate();
    int total = 0;
    for (const Activity &a : m_model->activities()) {
        if (a.createdAt.date() == today)
            total += a.durationMinutes;
    }
    return total;
}

int ActivityService::totalDurationAllTime() const
{
    int total = 0;
    for (const Activity &a : m_model->activities()) {
        total += a.durationMinutes;
    }
    return total;
}

int ActivityService::completedCount() const
{
    int count = 0;
    for (const Activity &a : m_model->activities()) {
        if (a.done) ++count;
    }
    return count;
}

int ActivityService::pendingCount() const
{
    return m_model->count() - completedCount();
}

int ActivityService::completionPercentage() const
{
    const int total = m_model->count();
    if (total == 0) return 0;
    return (completedCount() * 100) / total;
}

// ─────────────────────────────────────────────────────────────────────────────
// addActivity
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::addActivity(const QString &name,
                                  const QString &category,
                                  int durationMinutes,
                                  const QString &priority)
{
    // Input validation — emit an error signal instead of crashing
    if (name.trimmed().isEmpty()) {
        Q_EMIT errorOccurred("Activity name cannot be empty.");
        return;
    }
    if (durationMinutes <= 0) {
        Q_EMIT errorOccurred("Duration must be greater than 0.");
        return;
    }

    const Activity activity = Activity::create(name.trimmed(), category, durationMinutes, priority);
    m_model->addActivity(activity);
    save();
    Q_EMIT totalDurationTodayChanged();
}

// ─────────────────────────────────────────────────────────────────────────────
// removeActivity (Optimistic UI: stashes deleted item for Undo action)
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::removeActivity(int index)
{
    if (index < 0 || index >= m_model->count()) {
        Q_EMIT errorOccurred("Invalid activity index.");
        return;
    }

    m_lastDeletedActivity = m_model->activities().at(index);
    m_lastDeletedIndex = index;
    m_canUndo = true;

    m_model->removeActivity(index);
    save();

    Q_EMIT totalDurationTodayChanged();
    Q_EMIT canUndoChanged();
    Q_EMIT lastDeletedNameChanged();
    Q_EMIT activityRemoved(m_lastDeletedActivity.name);
}

// ─────────────────────────────────────────────────────────────────────────────
// undoLastDelete (Restores last deleted activity to its original position)
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::undoLastDelete()
{
    if (!m_canUndo || m_lastDeletedActivity.name.isEmpty()) {
        return;
    }

    m_model->insertActivity(m_lastDeletedIndex, m_lastDeletedActivity);
    m_canUndo = false;
    save();

    Q_EMIT totalDurationTodayChanged();
    Q_EMIT canUndoChanged();
    Q_EMIT lastDeletedNameChanged();
}

// ─────────────────────────────────────────────────────────────────────────────
// triggerSync (Simulates / triggers cloud DB sync cycle)
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::triggerSync()
{
    m_syncStatus = "syncing";
    Q_EMIT syncStatusChanged();

    QTimer::singleShot(800, this, [this]() {
        m_syncStatus = "synced";
        Q_EMIT syncStatusChanged();
    });
}

// ─────────────────────────────────────────────────────────────────────────────
// refresh (Reloads persisted activities from disk/DB and refreshes all metrics)
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::refresh()
{
    m_syncStatus = "syncing";
    Q_EMIT syncStatusChanged();

    const QVector<Activity> loaded = JsonStore::load();
    m_model->resetWith(loaded);

    Q_EMIT totalDurationTodayChanged();
    Q_EMIT statsChanged();
    Q_EMIT completedCountChanged();

    QTimer::singleShot(500, this, [this]() {
        m_syncStatus = "synced";
        Q_EMIT syncStatusChanged();
        Q_EMIT dataRefreshed();
    });
}

// ─────────────────────────────────────────────────────────────────────────────
// markComplete
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::markComplete(int index)
{
    if (index < 0 || index >= m_model->count()) {
        Q_EMIT errorOccurred("Invalid activity index.");
        return;
    }

    m_model->setDone(index, true);
    save();
    Q_EMIT completedCountChanged();
    Q_EMIT statsChanged();
}

// ─────────────────────────────────────────────────────────────────────────────
// setActivityStatus ("Created" | "In Progress" | "Done")
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::setActivityStatus(int index, const QString &status)
{
    if (index < 0 || index >= m_model->count()) {
        Q_EMIT errorOccurred("Invalid activity index.");
        return;
    }

    m_model->setStatus(index, status);
    save();
    Q_EMIT completedCountChanged();
    Q_EMIT statsChanged();
}

// ─────────────────────────────────────────────────────────────────────────────
// setActivityPriority ("Urgent" | "High" | "Medium" | "Low")
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::setActivityPriority(int index, const QString &priority)
{
    if (index < 0 || index >= m_model->count() || priority.trimmed().isEmpty()) {
        Q_EMIT errorOccurred("Invalid activity priority parameters.");
        return;
    }

    m_model->setPriority(index, priority);
    save();
}

// ─────────────────────────────────────────────────────────────────────────────
// updateActivity (Edits all activity properties in-place)
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::updateActivity(int index,
                                     const QString &name,
                                     const QString &category,
                                     int durationMinutes,
                                     const QString &status,
                                     const QString &priority)
{
    if (index < 0 || index >= m_model->count()) {
        Q_EMIT errorOccurred("Invalid activity index.");
        return;
    }
    if (name.trimmed().isEmpty()) {
        Q_EMIT errorOccurred("Activity name cannot be empty.");
        return;
    }
    if (durationMinutes <= 0) {
        Q_EMIT errorOccurred("Duration must be greater than 0.");
        return;
    }

    m_model->updateActivity(index, name.trimmed(), category, durationMinutes, status, priority);
    save();
    Q_EMIT totalDurationTodayChanged();
    Q_EMIT completedCountChanged();
    Q_EMIT statsChanged();
}

// ─────────────────────────────────────────────────────────────────────────────
// reopenActivity (Reopens a finished task back into active progress)
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::reopenActivity(int index)
{
    if (index < 0 || index >= m_model->count()) {
        Q_EMIT errorOccurred("Invalid activity index.");
        return;
    }

    m_model->setStatus(index, "In Progress");
    save();
    Q_EMIT completedCountChanged();
    Q_EMIT statsChanged();
}

// ─────────────────────────────────────────────────────────────────────────────
// extendActivity (Adds additional minutes to existing activity in-place)
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::extendActivity(int index, int additionalMinutes)
{
    if (index < 0 || index >= m_model->count() || additionalMinutes <= 0) {
        Q_EMIT errorOccurred("Invalid extension parameters.");
        return;
    }

    m_model->incrementExtension(index, additionalMinutes);
    save();
    Q_EMIT totalDurationTodayChanged();
    Q_EMIT statsChanged();
}

// ─────────────────────────────────────────────────────────────────────────────
// createExtension (Forks a follow-up activity for the task)
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::createExtension(int index, int minutes)
{
    if (index < 0 || index >= m_model->count()) {
        Q_EMIT errorOccurred("Invalid activity index.");
        return;
    }

    const Activity &parent = m_model->activities().at(index);
    const QString newName = parent.name + " (Extension)";
    addActivity(newName, parent.category, minutes > 0 ? minutes : 15);
}

// ─────────────────────────────────────────────────────────────────────────────
// save — private helper; always call after any mutation
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::save()
{
    m_syncStatus = "syncing";
    Q_EMIT syncStatusChanged();

    if (!JsonStore::save(m_model->activities())) {
        m_syncStatus = "offline";
        Q_EMIT syncStatusChanged();
        Q_EMIT errorOccurred("Failed to save activities to disk.");
        return;
    }

    // Flash syncing -> synced to give tactile feedback
    QTimer::singleShot(600, this, [this]() {
        m_syncStatus = "synced";
        Q_EMIT syncStatusChanged();
    });
}
