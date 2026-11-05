#include <QTest>
#include <QSignalSpy>
#include "model/Activity.h"
#include "model/ActivityListModel.h"
#include "model/Session.h"
#include "model/User.h"
#include "service/ActivityService.h"
#include "service/AuthService.h"
#include "persistence/JsonStore.h"

class TestActivityTracker : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void testActivityCreation();
    void testModelAddAndRoles();
    void testModelRemove();
    void testModelSetDone();
    void testServiceValidation();
    void testServiceUndo();
    void testServiceRefresh();
    void testTaskLifecycleAndExtension();
    void testJsonStoreSaveAndLoad();
    void testSessionSecurityAndHashing();
    void testSessionRemoteRevocation();
    void testPreferencesSyncAndTour();
};

void TestActivityTracker::initTestCase()
{
    QCoreApplication::setOrganizationName("9X Trading");
    QCoreApplication::setApplicationName("ActivityTrackerTests");
}

void TestActivityTracker::testActivityCreation()
{
    Activity a = Activity::create("Test Code", "Learning", 45);
    QVERIFY(!a.id.isEmpty());
    QCOMPARE(a.name, QString("Test Code"));
    QCOMPARE(a.category, QString("Learning"));
    QCOMPARE(a.durationMinutes, 45);
    QCOMPARE(a.done, false);
    QVERIFY(a.createdAt.isValid());
}

void TestActivityTracker::testModelAddAndRoles()
{
    ActivityListModel model;
    QCOMPARE(model.rowCount(), 0);

    QSignalSpy countSpy(&model, &ActivityListModel::countChanged);

    Activity a = Activity::create("Task 1", "Work", 60);
    model.addActivity(a);

    QCOMPARE(model.rowCount(), 1);
    QCOMPARE(model.count(), 1);
    QCOMPARE(countSpy.count(), 1);

    QModelIndex idx = model.index(0, 0);
    QVERIFY(idx.isValid());
    QCOMPARE(model.data(idx, ActivityListModel::NameRole).toString(), QString("Task 1"));
    QCOMPARE(model.data(idx, ActivityListModel::CategoryRole).toString(), QString("Work"));
    QCOMPARE(model.data(idx, ActivityListModel::DurationRole).toInt(), 60);
    QCOMPARE(model.data(idx, ActivityListModel::DoneRole).toBool(), false);

    QVariantMap map = model.get(0);
    QCOMPARE(map["name"].toString(), QString("Task 1"));
    QCOMPARE(map["category"].toString(), QString("Work"));
    QCOMPARE(map["durationMinutes"].toInt(), 60);
    QCOMPARE(map["done"].toBool(), false);
}

void TestActivityTracker::testModelRemove()
{
    ActivityListModel model;
    model.addActivity(Activity::create("Task A", "Work", 30));
    model.addActivity(Activity::create("Task B", "Personal", 15));
    QCOMPARE(model.rowCount(), 2);

    QSignalSpy countSpy(&model, &ActivityListModel::countChanged);
    model.removeActivity(0);

    QCOMPARE(model.rowCount(), 1);
    QCOMPARE(countSpy.count(), 1);
    QModelIndex idx = model.index(0, 0);
    QCOMPARE(model.data(idx, ActivityListModel::NameRole).toString(), QString("Task B"));
}

void TestActivityTracker::testModelSetDone()
{
    ActivityListModel model;
    model.addActivity(Activity::create("Task A", "Work", 30));

    QSignalSpy dataSpy(&model, &ActivityListModel::dataChanged);
    model.setDone(0, true);

    QCOMPARE(dataSpy.count(), 1);
    QModelIndex idx = model.index(0, 0);
    QCOMPARE(model.data(idx, ActivityListModel::DoneRole).toBool(), true);
}

void TestActivityTracker::testServiceValidation()
{
    ActivityService service;
    QSignalSpy errorSpy(&service, &ActivityService::errorOccurred);

    // Empty name should trigger errorOccurred
    service.addActivity("", "Work", 30);
    QCOMPARE(errorSpy.count(), 1);

    // Zero or negative duration should trigger errorOccurred
    service.addActivity("Valid Name", "Work", 0);
    QCOMPARE(errorSpy.count(), 2);
}

void TestActivityTracker::testServiceUndo()
{
    ActivityService service;
    service.addActivity("Task To Delete", "Work", 30);
    const int countBefore = service.model()->count();
    QVERIFY(countBefore >= 1);

    // Remove the activity
    const int targetIndex = countBefore - 1;
    service.removeActivity(targetIndex);
    QCOMPARE(service.model()->count(), countBefore - 1);
    QVERIFY(service.canUndo());
    QCOMPARE(service.lastDeletedName(), QString("Task To Delete"));

    // Undo the deletion
    service.undoLastDelete();
    QCOMPARE(service.model()->count(), countBefore);
    QVERIFY(!service.canUndo());
    QCOMPARE(service.model()->activities().last().name, QString("Task To Delete"));
}

void TestActivityTracker::testServiceRefresh()
{
    ActivityService service;
    QSignalSpy refreshSpy(&service, &ActivityService::dataRefreshed);

    service.refresh();
    QVERIFY(refreshSpy.wait(1500));
    QCOMPARE(refreshSpy.count(), 1);
}

void TestActivityTracker::testTaskLifecycleAndExtension()
{
    ActivityService service;
    service.addActivity("Deep Work Session", "Work", 45);
    const int idx = service.model()->count() - 1;

    // Test initial state
    QCOMPARE(service.model()->data(service.model()->index(idx, 0), ActivityListModel::StatusRole).toString(), QString("Created"));
    QCOMPARE(service.model()->data(service.model()->index(idx, 0), ActivityListModel::DoneRole).toBool(), false);

    // Set In Progress
    service.setActivityStatus(idx, "In Progress");
    QCOMPARE(service.model()->data(service.model()->index(idx, 0), ActivityListModel::StatusRole).toString(), QString("In Progress"));

    // Complete it
    service.markComplete(idx);
    QCOMPARE(service.model()->data(service.model()->index(idx, 0), ActivityListModel::DoneRole).toBool(), true);
    QCOMPARE(service.model()->data(service.model()->index(idx, 0), ActivityListModel::StatusRole).toString(), QString("Done"));

    // Reopen task
    service.reopenActivity(idx);
    QCOMPARE(service.model()->data(service.model()->index(idx, 0), ActivityListModel::DoneRole).toBool(), false);
    QCOMPARE(service.model()->data(service.model()->index(idx, 0), ActivityListModel::StatusRole).toString(), QString("In Progress"));

    // Extend task by +15m (in-place cumulative extension)
    service.extendActivity(idx, 15);
    QCOMPARE(service.model()->data(service.model()->index(idx, 0), ActivityListModel::DurationRole).toInt(), 60);
    QCOMPARE(service.model()->data(service.model()->index(idx, 0), ActivityListModel::ExtensionCountRole).toInt(), 1);

    // Set priority to Urgent
    service.setActivityPriority(idx, "Urgent");
    QCOMPARE(service.model()->data(service.model()->index(idx, 0), ActivityListModel::PriorityRole).toString(), QString("Urgent"));

    // Create follow-up extension activity
    const int countBefore = service.model()->count();
    service.createExtension(idx, 20);
    QCOMPARE(service.model()->count(), countBefore + 1);
    QCOMPARE(service.model()->activities().last().name, QString("Deep Work Session (Extension)"));
    QCOMPARE(service.model()->activities().last().durationMinutes, 20);
}

void TestActivityTracker::testJsonStoreSaveAndLoad()
{
    QVector<Activity> activities;
    activities.append(Activity::create("Persistent 1", "Work", 25));
    activities.append(Activity::create("Persistent 2", "Personal", 50));

    bool saved = JsonStore::save(activities);
    QVERIFY(saved);

    QVector<Activity> loaded = JsonStore::load();
    QCOMPARE(loaded.size(), 2);
    QCOMPARE(loaded[0].name, QString("Persistent 1"));
    QCOMPARE(loaded[1].name, QString("Persistent 2"));
}

void TestActivityTracker::testSessionSecurityAndHashing()
{
    // Generate token
    const QString rawToken = UserSession::generateToken();
    QVERIFY(!rawToken.isEmpty());

    // Hash token
    const QString hash1 = UserSession::hashToken(rawToken);
    const QString hash2 = UserSession::hashToken(rawToken);
    QCOMPARE(hash1, hash2);
    QCOMPARE(hash1.length(), 64); // SHA-256 hex string length

    // Create session
    const UserSession session = UserSession::create("usr_test_01", rawToken, "Test Machine", "windows", 30);
    QVERIFY(session.isValid());
    QCOMPARE(session.isRevoked, false);
    QVERIFY(session.expiresAt > QDateTime::currentDateTime());
    QCOMPARE(session.tokenHash, hash1);
}

void TestActivityTracker::testSessionRemoteRevocation()
{
    AuthService auth;
    auth.loginDemoUser();
    QVERIFY(auth.isLoggedIn());

    const QString currentSessId = auth.currentSessionId();
    QVERIFY(!currentSessId.isEmpty());

    // Remote revoke
    QSignalSpy revokeSpy(&auth, &AuthService::sessionRevoked);
    auth.revokeSession(currentSessId);

    // Assert session was terminated
    QCOMPARE(auth.isLoggedIn(), false);
    QCOMPARE(revokeSpy.count(), 1);
}

void TestActivityTracker::testPreferencesSyncAndTour()
{
    AuthService auth;
    auth.loginDemoUser();

    // Verify initial tour state
    auth.resetTour();
    QCOMPARE(auth.hasSeenTour(), false);

    // Complete tour
    QSignalSpy prefSpy(&auth, &AuthService::preferencesChanged);
    auth.completeTour();
    QCOMPARE(auth.hasSeenTour(), true);
    QCOMPARE(prefSpy.count(), 1);

    // Sync preferences across devices
    auth.syncPreferences("dark", "right", true, "Today", true);
    QCOMPARE(auth.preferences().sidebarDock, QString("right"));
    QCOMPARE(auth.preferences().sidebarCollapsed, true);
    QCOMPARE(auth.preferences().hasSeenTour, true);
}

QTEST_MAIN(TestActivityTracker)
#include "tst_ActivityModel.moc"

