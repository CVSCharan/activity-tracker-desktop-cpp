#include "AuthService.h"

#include <QCryptographicHash>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>

static const QString SALT_PREFIX = "cvs_salt_";

AuthService::AuthService(QObject *parent)
    : QObject(parent)
{
    loadLocalUsers();
    restoreSavedSession();
}

QString AuthService::hashPassword(const QString &password)
{
    const QByteArray data = (SALT_PREFIX + password).toUtf8();
    return QString(QCryptographicHash::hash(data, QCryptographicHash::Sha256).toHex());
}

void AuthService::clearError()
{
    if (!m_errorMessage.isEmpty()) {
        m_errorMessage.clear();
        Q_EMIT errorChanged();
    }
}

bool AuthService::login(const QString &email, const QString &password, bool rememberMe)
{
    clearError();
    const QString cleanEmail = email.trimmed().toLower();

    if (cleanEmail.isEmpty() || password.isEmpty()) {
        m_errorMessage = "Please enter both email and password.";
        Q_EMIT errorChanged();
        return false;
    }

    const QString computedHash = hashPassword(password);

    for (const User &u : m_users) {
        if (u.email.toLower() == cleanEmail) {
            if (u.passwordHash == computedHash) {
                m_currentUser = u;
                m_isLoggedIn = true;

                QSettings settings;
                settings.setValue("auth/rememberMe", rememberMe);
                if (rememberMe) {
                    settings.setValue("auth/savedUserId", u.id);
                    settings.setValue("auth/savedEmail", u.email);
                } else {
                    settings.remove("auth/savedUserId");
                    settings.remove("auth/savedEmail");
                }

                Q_EMIT authStateChanged();
                Q_EMIT loginSuccess();
                return true;
            } else {
                m_errorMessage = "Incorrect password. Please try again.";
                Q_EMIT errorChanged();
                return false;
            }
        }
    }

    m_errorMessage = "No account found with this email.";
    Q_EMIT errorChanged();
    return false;
}

bool AuthService::registerUser(const QString &name, const QString &email, const QString &password, int dailyGoalMinutes)
{
    clearError();
    const QString cleanName = name.trimmed();
    const QString cleanEmail = email.trimmed().toLower();

    if (cleanName.isEmpty()) {
        m_errorMessage = "Please enter your full name.";
        Q_EMIT errorChanged();
        return false;
    }
    if (cleanEmail.isEmpty() || !cleanEmail.contains('@') || !cleanEmail.contains('.')) {
        m_errorMessage = "Please enter a valid email address.";
        Q_EMIT errorChanged();
        return false;
    }
    if (password.length() < 6) {
        m_errorMessage = "Password must be at least 6 characters long.";
        Q_EMIT errorChanged();
        return false;
    }

    for (const User &u : m_users) {
        if (u.email.toLower() == cleanEmail) {
            m_errorMessage = "An account with this email already exists.";
            Q_EMIT errorChanged();
            return false;
        }
    }

    const User newUser = User::create(cleanName, cleanEmail, hashPassword(password), dailyGoalMinutes > 0 ? dailyGoalMinutes : 240);
    m_users.append(newUser);
    saveLocalUsers();

    // Automatically log in the new user
    m_currentUser = newUser;
    m_isLoggedIn = true;

    QSettings settings;
    settings.setValue("auth/rememberMe", true);
    settings.setValue("auth/savedUserId", newUser.id);
    settings.setValue("auth/savedEmail", newUser.email);

    Q_EMIT authStateChanged();
    Q_EMIT registrationSuccess();
    return true;
}

bool AuthService::resetPassword(const QString &email, const QString &newPassword)
{
    clearError();
    const QString cleanEmail = email.trimmed().toLower();

    if (cleanEmail.isEmpty()) {
        m_errorMessage = "Please enter your registered email address.";
        Q_EMIT errorChanged();
        return false;
    }
    if (newPassword.length() < 6) {
        m_errorMessage = "New password must be at least 6 characters long.";
        Q_EMIT errorChanged();
        return false;
    }

    for (int i = 0; i < m_users.size(); ++i) {
        if (m_users[i].email.toLower() == cleanEmail) {
            m_users[i].passwordHash = hashPassword(newPassword);
            saveLocalUsers();
            Q_EMIT resetPasswordSuccess();
            return true;
        }
    }

    m_errorMessage = "No account found with this email.";
    Q_EMIT errorChanged();
    return false;
}

void AuthService::loginDemoUser()
{
    clearError();
    for (const User &u : m_users) {
        if (u.email == "charan@cvs.com") {
            m_currentUser = u;
            m_isLoggedIn = true;
            Q_EMIT authStateChanged();
            Q_EMIT loginSuccess();
            return;
        }
    }

    // If demo user wasn't present, create and log in
    const User demoUser{
        "usr_charan_demo_01",
        "Charan Developer",
        "charan@cvs.com",
        hashPassword("Password123!"),
        240,
        QDateTime::currentDateTime()
    };
    m_users.append(demoUser);
    saveLocalUsers();

    m_currentUser = demoUser;
    m_isLoggedIn = true;
    Q_EMIT authStateChanged();
    Q_EMIT loginSuccess();
}

void AuthService::logout()
{
    QSettings settings;
    settings.remove("auth/savedUserId");
    settings.remove("auth/savedEmail");
    settings.setValue("auth/rememberMe", false);

    m_currentUser = User{};
    m_isLoggedIn = false;
    clearError();
    Q_EMIT authStateChanged();
}

void AuthService::restoreSavedSession()
{
    QSettings settings;
    const bool rememberMe = settings.value("auth/rememberMe", false).toBool();
    const QString savedUserId = settings.value("auth/savedUserId").toString();

    if (rememberMe && !savedUserId.isEmpty()) {
        for (const User &u : m_users) {
            if (u.id == savedUserId) {
                m_currentUser = u;
                m_isLoggedIn = true;
                qInfo() << "AuthService: Restored session for" << u.email;
                return;
            }
        }
    }
}

void AuthService::loadLocalUsers()
{
    m_users.clear();

    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dir);
    const QString filePath = dir + "/users.json";

    QFile file(filePath);
    if (file.exists() && file.open(QIODevice::ReadOnly)) {
        const QByteArray raw = file.readAll();
        const QJsonDocument doc = QJsonDocument::fromJson(raw);
        if (doc.isArray()) {
            const QJsonArray arr = doc.array();
            for (const QJsonValue &v : arr) {
                if (v.isObject()) {
                    m_users.append(User::fromJson(v.toObject()));
                }
            }
        }
        file.close();
    }

    // If no users exist, seed default demo account
    if (m_users.isEmpty()) {
        const User seedUser{
            "usr_charan_demo_01",
            "Charan Developer",
            "charan@cvs.com",
            hashPassword("Password123!"),
            240,
            QDateTime::currentDateTime()
        };
        m_users.append(seedUser);
        saveLocalUsers();
    }
}

void AuthService::saveLocalUsers()
{
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dir);
    const QString filePath = dir + "/users.json";

    QJsonArray arr;
    for (const User &u : m_users) {
        arr.append(u.toJson());
    }

    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        file.write(QJsonDocument(arr).toJson(QJsonDocument::Indented));
        file.close();
    }
}
