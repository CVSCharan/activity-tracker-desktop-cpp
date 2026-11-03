#include <QTest>
#include <QSignalSpy>
#include "model/Activity.h"
#include "model/ActivityListModel.h"
#include "service/ActivityService.h"
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
    void testJsonStoreSaveAndLoad();
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

QTEST_MAIN(TestActivityTracker)
#include "tst_ActivityModel.moc"
