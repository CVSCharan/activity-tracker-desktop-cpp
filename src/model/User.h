#pragma once

#include <QString>
#include <QDateTime>
#include <QJsonObject>

// ─────────────────────────────────────────────────────────────────────────────
// User — represents an authenticated user in the system
// ─────────────────────────────────────────────────────────────────────────────
struct User
{
    QString   id;
    QString   name;
    QString   email;
    QString   passwordHash;
    int       dailyGoalMinutes = 240; // Default 4 hours
    QDateTime createdAt;

    // Factory method
    static User create(const QString &name,
                       const QString &email,
                       const QString &passwordHash,
                       int dailyGoalMinutes = 240)
    {
        return User{
            QString("usr_%1").arg(QDateTime::currentMSecsSinceEpoch()),
            name,
            email,
            passwordHash,
            dailyGoalMinutes,
            QDateTime::currentDateTime()
        };
    }

    QJsonObject toJson() const
    {
        QJsonObject obj;
        obj["id"]               = id;
        obj["name"]             = name;
        obj["email"]            = email;
        obj["passwordHash"]     = passwordHash;
        obj["dailyGoalMinutes"] = dailyGoalMinutes;
        obj["createdAt"]        = createdAt.toString(Qt::ISODate);
        return obj;
    }

    static User fromJson(const QJsonObject &obj)
    {
        User u;
        u.id               = obj["id"].toString();
        u.name             = obj["name"].toString();
        u.email            = obj["email"].toString();
        u.passwordHash     = obj["passwordHash"].toString();
        u.dailyGoalMinutes = obj["dailyGoalMinutes"].toInt(240);
        u.createdAt        = QDateTime::fromString(obj["createdAt"].toString(), Qt::ISODate);
        return u;
    }
};
