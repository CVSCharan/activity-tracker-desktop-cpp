#include "Activity.h"
#include <QUuid>
#include <QString>
#include <QDateTime>

// ─────────────────────────────────────────────────────────────────────────────
// Activity::create  — static factory
//
// 'Activity::create' means "the 'create' function that belongs to Activity".
// The '::' is the scope resolution operator (like the dot in JS: Activity.create)
//
// 'const QString &name' — pass by const-reference:
//   - No copy of the string is made (efficient)
//   - 'const' means we promise not to modify it inside this function
//   - JS always passes objects by reference; C++ strings are value types by
//     default, so '&' is needed to avoid an implicit copy.
// ─────────────────────────────────────────────────────────────────────────────
Activity Activity::create(const QString &name,
                          const QString &category,
                          int durationMinutes)
{
    Activity a;                                               // stack-allocated instance
    a.id               = QUuid::createUuid().toString(QUuid::WithoutBraces); // like crypto.randomUUID()
    a.name             = name;
    a.category         = category;
    a.durationMinutes  = durationMinutes;
    a.done             = false;
    a.createdAt        = QDateTime::currentDateTime();        // like new Date()
    return a;                                                 // returned by value (cheap: compiler elides the copy)
}

