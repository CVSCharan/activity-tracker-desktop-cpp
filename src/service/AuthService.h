#pragma once

#include <QObject>
#include <QString>
#include <QSettings>
#include <QVector>
#include "model/User.h"

// ─────────────────────────────────────────────────────────────────────────────
// AuthService — manages user authentication, session persistence, and registration
// ─────────────────────────────────────────────────────────────────────────────
class AuthService : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY authStateChanged)
    Q_PROPERTY(QString currentUserId READ currentUserId NOTIFY authStateChanged)
    Q_PROPERTY(QString currentUserName READ currentUserName NOTIFY authStateChanged)
    Q_PROPERTY(QString currentUserEmail READ currentUserEmail NOTIFY authStateChanged)
    Q_PROPERTY(int dailyGoalMinutes READ dailyGoalMinutes NOTIFY authStateChanged)
    Q_PROPERTY(bool isBusy READ isBusy NOTIFY busyChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorChanged)

public:
    explicit AuthService(QObject *parent = nullptr);

    bool isLoggedIn() const { return m_isLoggedIn; }
    QString currentUserId() const { return m_currentUser.id; }
    QString currentUserName() const { return m_currentUser.name; }
    QString currentUserEmail() const { return m_currentUser.email; }
    int dailyGoalMinutes() const { return m_currentUser.dailyGoalMinutes; }
    bool isBusy() const { return m_isBusy; }
    QString errorMessage() const { return m_errorMessage; }

    const User &currentUser() const { return m_currentUser; }

    Q_INVOKABLE bool login(const QString &email, const QString &password, bool rememberMe);
    Q_INVOKABLE bool registerUser(const QString &name, const QString &email, const QString &password, int dailyGoalMinutes);
    Q_INVOKABLE bool resetPassword(const QString &email, const QString &newPassword);
    Q_INVOKABLE void loginDemoUser();
    Q_INVOKABLE void logout();
    Q_INVOKABLE void clearError();

    static QString hashPassword(const QString &password);

signals:
    void authStateChanged();
    void busyChanged();
    void errorChanged();
    void loginSuccess();
    void registrationSuccess();
    void resetPasswordSuccess();

private:
    void loadLocalUsers();
    void saveLocalUsers();
    void restoreSavedSession();

    bool m_isLoggedIn = false;
    bool m_isBusy = false;
    QString m_errorMessage;
    User m_currentUser;
    QVector<User> m_users;
};
