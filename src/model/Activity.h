#pragma once

// Qt headers - each gives us specific types
#include <QString>
#include <QDateTime>

// ─────────────────────────────────────────────────────────────────────────────
// Activity — plain data struct (no QObject, no signals, no heap allocation)
//
// JS equivalent:
//   interface Activity {
//     id: string;
//     name: string;
//     category: string;
//     durationMinutes: number;
//     done: boolean;
//     createdAt: Date;
//   }
// ─────────────────────────────────────────────────────────────────────────────
struct Activity
{
    QString  id;                      // Unique identifier (e.g. QUuid string)
    QString  name;                    // Display name e.g. "Write unit tests"
    QString  category;                // "Work" | "Learning" | "Personal"
    int      durationMinutes = 0;     // Planned duration in minutes
    bool     done            = false; // Completion flag
    QDateTime createdAt;              // Creation timestamp

    // ── Convenience factory ───────────────────────────────────────────────────
    // 'static' means it belongs to the struct type, not to an instance.
    // Like a static method in a JS class: Activity.create(...)
    static Activity create(const QString &name,
                           const QString &category,
                           int durationMinutes);
};
