#include "ActivityService.h"
#include "persistence/JsonStore.h"

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

int ActivityService::completedCount() const
{
    int count = 0;
    for (const Activity &a : m_model->activities()) {
        if (a.done) ++count;
    }
    return count;
}

// ─────────────────────────────────────────────────────────────────────────────
// addActivity
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::addActivity(const QString &name,
                                  const QString &category,
                                  int durationMinutes)
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

    const Activity activity = Activity::create(name.trimmed(), category, durationMinutes);
    m_model->addActivity(activity);
    save();
    Q_EMIT totalDurationTodayChanged();
}

// ─────────────────────────────────────────────────────────────────────────────
// removeActivity
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::removeActivity(int index)
{
    if (index < 0 || index >= m_model->count()) {
        Q_EMIT errorOccurred("Invalid activity index.");
        return;
    }

    m_model->removeActivity(index);
    save();
    Q_EMIT totalDurationTodayChanged();
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
}

// ─────────────────────────────────────────────────────────────────────────────
// save — private helper; always call after any mutation
// ─────────────────────────────────────────────────────────────────────────────
void ActivityService::save()
{
    if (!JsonStore::save(m_model->activities())) {
        Q_EMIT errorOccurred("Failed to save activities to disk.");
    }
}
