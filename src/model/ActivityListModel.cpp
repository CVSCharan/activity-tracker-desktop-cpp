#include "ActivityListModel.h"

// ─────────────────────────────────────────────────────────────────────────────
// Constructor
// Pass 'parent' up to QAbstractListModel so Qt's ownership tree is correct.
// ─────────────────────────────────────────────────────────────────────────────
ActivityListModel::ActivityListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

// ─────────────────────────────────────────────────────────────────────────────
// rowCount — how many rows does this model have?
// QML's ListView calls this to know how many delegates to create.
// The 'parent' check is boilerplate for list models (always empty/invalid).
// ─────────────────────────────────────────────────────────────────────────────
int ActivityListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;               // flat list: no tree children
    return m_activities.size();
}

// ─────────────────────────────────────────────────────────────────────────────
// data — return a single field for a given row + role
//
// QML calls: model.name  →  data(index, NameRole)
//
// QVariant is Qt's "any" type — can hold QString, int, bool, QDateTime, etc.
// Like TypeScript's 'any' but with runtime type safety (toInt(), toString()…).
// ─────────────────────────────────────────────────────────────────────────────
QVariant ActivityListModel::data(const QModelIndex &index, int role) const
{
    // Bounds check — always guard against invalid indices
    if (!index.isValid() || index.row() < 0 || index.row() >= m_activities.size())
        return {};               // default-constructed QVariant = null/undefined

    const Activity &activity = m_activities.at(index.row()); // const ref: no copy

    switch (role) {
    case IdRole:        return activity.id;
    case NameRole:      return activity.name;
    case CategoryRole:  return activity.category;
    case DurationRole:  return activity.durationMinutes;
    case DoneRole:      return activity.done;
    case CreatedAtRole: return activity.createdAt;
    default:            return {};
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// roleNames — map integer role IDs → QML property names
//
// This is what makes  model.name  work in a QML delegate.
// QByteArray is Qt's raw byte string (used for internal names, not display).
// ─────────────────────────────────────────────────────────────────────────────
QHash<int, QByteArray> ActivityListModel::roleNames() const
{
    return {
        { IdRole,        "activityId"       },
        { NameRole,      "name"             },
        { CategoryRole,  "category"         },
        { DurationRole,  "durationMinutes"  },
        { DoneRole,      "done"             },
        { CreatedAtRole, "createdAt"        }
    };
}

// ─────────────────────────────────────────────────────────────────────────────
// addActivity
//
// beginInsertRows / endInsertRows  ←  this is the Qt model notification protocol.
// Any ListView watching this model will automatically insert the new row.
// No manual re-render call, no state update function — Qt handles it.
// ─────────────────────────────────────────────────────────────────────────────
void ActivityListModel::addActivity(const Activity &activity)
{
    const int newRow = m_activities.size();
    beginInsertRows(QModelIndex(), newRow, newRow); // notify: "row N is about to appear"
    m_activities.append(activity);
    endInsertRows();                                // notify: "row N is now there"
    Q_EMIT countChanged();
}

void ActivityListModel::insertActivity(int index, const Activity &activity)
{
    if (index < 0 || index > m_activities.size())
        index = m_activities.size();

    beginInsertRows(QModelIndex(), index, index);
    m_activities.insert(index, activity);
    endInsertRows();
    Q_EMIT countChanged();
}

// ─────────────────────────────────────────────────────────────────────────────
// removeActivity
// ─────────────────────────────────────────────────────────────────────────────
void ActivityListModel::removeActivity(int index)
{
    if (index < 0 || index >= m_activities.size())
        return;

    beginRemoveRows(QModelIndex(), index, index);
    m_activities.removeAt(index);
    endRemoveRows();
    Q_EMIT countChanged();
}

// ─────────────────────────────────────────────────────────────────────────────
// setDone
//
// dataChanged(topLeft, bottomRight, roles) tells the view: "the data at these
// rows changed for these roles — please re-read and repaint."
// ─────────────────────────────────────────────────────────────────────────────
void ActivityListModel::setDone(int index, bool done)
{
    if (index < 0 || index >= m_activities.size())
        return;

    m_activities[index].done = done;

    const QModelIndex changedIndex = createIndex(index, 0);
    Q_EMIT dataChanged(changedIndex, changedIndex, { DoneRole });
}

// ─────────────────────────────────────────────────────────────────────────────
// resetWith — bulk-replace all activities (called on app startup from JsonStore)
// ─────────────────────────────────────────────────────────────────────────────
void ActivityListModel::resetWith(const QVector<Activity> &activities)
{
    beginResetModel();
    m_activities = activities;
    endResetModel();
    Q_EMIT countChanged();
}

