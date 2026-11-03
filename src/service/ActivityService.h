#pragma once

#include <QObject>
#include "model/ActivityListModel.h"

// ─────────────────────────────────────────────────────────────────────────────
// ActivityService — owns the model, handles mutations, triggers persistence.
//
// This is the layer between QML (UI) and the model+storage.
// Equivalent to a React Context + reducer, or a MobX store.
//
// Lifetime: created in main.cpp, set as a QML context property, lives for
//           the duration of the app.
// ─────────────────────────────────────────────────────────────────────────────
class ActivityService : public QObject
{
    Q_OBJECT

    // ── Properties exposed to QML ─────────────────────────────────────────────
    Q_PROPERTY(int totalDurationToday READ totalDurationToday NOTIFY totalDurationTodayChanged)
    Q_PROPERTY(int completedCount READ completedCount NOTIFY statsChanged)
    Q_PROPERTY(int pendingCount READ pendingCount NOTIFY statsChanged)
    Q_PROPERTY(int completionPercentage READ completionPercentage NOTIFY statsChanged)

    // The model itself — QML binds: model: activityService.model
    Q_PROPERTY(ActivityListModel* model READ model CONSTANT)

public:
    explicit ActivityService(QObject *parent = nullptr);

    // ── Property getters ──────────────────────────────────────────────────────
    int totalDurationToday() const;
    int completedCount() const;
    int pendingCount() const;
    int completionPercentage() const;
    ActivityListModel *model() const { return m_model; }

    // ── Q_INVOKABLE methods — callable from QML ───────────────────────────────
    Q_INVOKABLE void addActivity(const QString &name,
                                 const QString &category,
                                 int durationMinutes);

    Q_INVOKABLE void removeActivity(int index);
    Q_INVOKABLE void markComplete(int index);

signals:
    void totalDurationTodayChanged();
    void completedCountChanged();
    void statsChanged();

    // Emitted when something goes wrong — QML can connect to show a toast/dialog
    void errorOccurred(const QString &message);

private:
    void save();  // serializes current model to JsonStore

    ActivityListModel *m_model = nullptr;  // owned: destroyed when 'this' is destroyed
};
