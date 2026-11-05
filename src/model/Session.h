#pragma once

#include <QString>
#include <QDateTime>
#include <QJsonObject>
#include <QUuid>
#include <QCryptographicHash>

// ─────────────────────────────────────────────────────────────────────────────
// UserSession — Represents a secure, validated client session
// Supports token hashing, multi-device tracking, and instant remote revocation.
// ─────────────────────────────────────────────────────────────────────────────
struct UserSession
{
    QString   id;
    QString   userId;
    QString   tokenHash;    // SHA-256 hash of the secret bearer token
    QString   deviceName;   // e.g. "Executive Workstation (Windows x64)", "MacBook Pro (Apple Silicon)"
    QString   platform;     // "windows", "macos", "linux"
    QDateTime createdAt;
    QDateTime lastActiveAt;
    QDateTime expiresAt;
    bool      isRevoked = false;

    // Factory: generates a cryptographically random bearer token
    static QString generateToken()
    {
        const QString u1 = QUuid::createUuid().toString(QUuid::WithoutBraces);
        const QString u2 = QUuid::createUuid().toString(QUuid::WithoutBraces);
        return QString("%1-%2").arg(u1, u2);
    }

    // Hashes bearer token with SHA-256 for secure database/store verification
    static QString hashToken(const QString &token)
    {
        return QString(QCryptographicHash::hash(token.toUtf8(), QCryptographicHash::Sha256).toHex());
    }

    // Factory: creates a new 30-day session
    static UserSession create(const QString &userId,
                              const QString &bearerToken,
                              const QString &deviceName,
                              const QString &platform,
                              int validDays = 30)
    {
        const QDateTime now = QDateTime::currentDateTime();
        return UserSession{
            QString("sess_%1").arg(QUuid::createUuid().toString(QUuid::WithoutBraces)),
            userId,
            hashToken(bearerToken),
            deviceName,
            platform,
            now,
            now,
            now.addDays(validDays),
            false
        };
    }

    bool isValid() const
    {
        return !isRevoked && (expiresAt > QDateTime::currentDateTime());
    }

    QJsonObject toJson() const
    {
        QJsonObject obj;
        obj["id"]           = id;
        obj["userId"]       = userId;
        obj["tokenHash"]    = tokenHash;
        obj["deviceName"]   = deviceName;
        obj["platform"]     = platform;
        obj["createdAt"]    = createdAt.toString(Qt::ISODate);
        obj["lastActiveAt"] = lastActiveAt.toString(Qt::ISODate);
        obj["expiresAt"]    = expiresAt.toString(Qt::ISODate);
        obj["isRevoked"]    = isRevoked;
        return obj;
    }

    static UserSession fromJson(const QJsonObject &obj)
    {
        UserSession s;
        s.id           = obj["id"].toString();
        s.userId       = obj["userId"].toString();
        s.tokenHash    = obj["tokenHash"].toString();
        s.deviceName   = obj["deviceName"].toString();
        s.platform     = obj["platform"].toString();
        s.createdAt    = QDateTime::fromString(obj["createdAt"].toString(), Qt::ISODate);
        s.lastActiveAt = QDateTime::fromString(obj["lastActiveAt"].toString(), Qt::ISODate);
        s.expiresAt    = QDateTime::fromString(obj["expiresAt"].toString(), Qt::ISODate);
        s.isRevoked    = obj["isRevoked"].toBool(false);
        return s;
    }
};

// ─────────────────────────────────────────────────────────────────────────────
// UserPreferences — Cross-device synchronized workstation preferences
// Synchronizes theme, dock layout, and first-run UI Tour across devices.
// ─────────────────────────────────────────────────────────────────────────────
struct UserPreferences
{
    QString userId;
    QString theme = "dark";
    QString sidebarDock = "left";
    bool    sidebarCollapsed = false;
    QString activeTimeframe = "All Time";
    bool    hasSeenTour = false;
    int     dailyGoalMinutes = 240;

    QJsonObject toJson() const
    {
        QJsonObject obj;
        obj["userId"]           = userId;
        obj["theme"]            = theme;
        obj["sidebarDock"]      = sidebarDock;
        obj["sidebarCollapsed"] = sidebarCollapsed;
        obj["activeTimeframe"]  = activeTimeframe;
        obj["hasSeenTour"]      = hasSeenTour;
        obj["dailyGoalMinutes"] = dailyGoalMinutes;
        return obj;
    }

    static UserPreferences fromJson(const QJsonObject &obj)
    {
        UserPreferences p;
        p.userId           = obj["userId"].toString();
        p.theme            = obj["theme"].toString("dark");
        p.sidebarDock      = obj["sidebarDock"].toString("left");
        p.sidebarCollapsed = obj["sidebarCollapsed"].toBool(false);
        p.activeTimeframe  = obj["activeTimeframe"].toString("All Time");
        p.hasSeenTour      = obj["hasSeenTour"].toBool(false);
        p.dailyGoalMinutes = obj["dailyGoalMinutes"].toInt(240);
        return p;
    }
};
