#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "service/ActivityService.h"
#include "model/ActivityListModel.h"

int main(int argc, char *argv[])
{
    // ── Application metadata ──────────────────────────────────────────────────
    // These strings are used by QStandardPaths to compute the data directory:
    //   Windows: %APPDATA%\9X Trading\ActivityTracker
    QGuiApplication::setOrganizationName("9X Trading");
    QGuiApplication::setApplicationName("ActivityTracker");
    QGuiApplication::setApplicationVersion("1.0.0");

    // ── Create the application ────────────────────────────────────────────────
    // QGuiApplication (not QApplication) because we're using Qt Quick (QML),
    // not Qt Widgets. It starts the event loop and manages the window system.
    QGuiApplication app(argc, argv);

    // ── Set Material style for Qt Quick Controls 2 ───────────────────────────
    // Must be called BEFORE QQmlApplicationEngine is created.
    QQuickStyle::setStyle("Material");

    // ── Business logic / service ──────────────────────────────────────────────
    // Stack-allocated: destroyed automatically when main() returns (RAII).
    // ActivityService owns ActivityListModel (via Qt parent-child ownership).
    ActivityService service;

    // ── QML engine ────────────────────────────────────────────────────────────
    QQmlApplicationEngine engine;

    // Expose C++ objects to QML as named globals.
    // After this, every QML file can write: activityService.addActivity(...)
    engine.rootContext()->setContextProperty("activityService", &service);
    engine.rootContext()->setContextProperty("activityModel", service.model());

    // ── Load the root QML file ────────────────────────────────────────────────
    // "qrc:/ActivityTracker/qml/main.qml" — the qrc:/ prefix means "embedded
    // resource". Qt's resource system bundles QML files into the executable.
    const QUrl mainQml("qrc:/ActivityTracker/qml/main.qml");

    // If the root object fails to load, quit immediately with a non-zero exit code.
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        [](const QUrl &url) {
            qCritical() << "Failed to load QML:" << url;
            QCoreApplication::exit(1);
        },
        Qt::QueuedConnection
    );

    engine.load(mainQml);

    // ── Event loop ────────────────────────────────────────────────────────────
    // app.exec() blocks here, processing events until the last window closes.
    // Returns the exit code (0 = success).
    return app.exec();
}
