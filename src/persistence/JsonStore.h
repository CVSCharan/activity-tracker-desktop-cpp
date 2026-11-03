#pragma once

#include <QVector>
#include "model/Activity.h"

// ─────────────────────────────────────────────────────────────────────────────
// JsonStore — handles serialization of Activity data to/from a local JSON file.
//
// This is a stateless utility class (no QObject needed — no signals/slots).
// All methods are static.
//
// Storage location (Windows): %APPDATA%\ActivityTracker\activities.json
// ─────────────────────────────────────────────────────────────────────────────
class JsonStore
{
public:
    // Save the full list to disk. Returns true on success.
    static bool save(const QVector<Activity> &activities);

    // Load from disk. Returns empty vector if file is missing or corrupt.
    static QVector<Activity> load();

private:
    static QString filePath();  // resolves the storage path
};
