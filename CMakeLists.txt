cmake_minimum_required(VERSION 3.21)
project(ActivityTracker VERSION 1.0.0 LANGUAGES CXX)

# ── C++ Standard ──────────────────────────────────────────────────────────────
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ── Qt Automation ─────────────────────────────────────────────────────────────
# AUTOMOC: auto-runs moc on Q_OBJECT classes (generates signal/slot plumbing)
# AUTORCC: auto-compiles .qrc resource files
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# ── Find Qt6 ──────────────────────────────────────────────────────────────────
# If cmake can't find Qt automatically, pass -DCMAKE_PREFIX_PATH=C:/Qt/6.9.3/msvc2022_64
find_package(Qt6 6.4 REQUIRED COMPONENTS
    Core        # QObject, QString, QVector, QJsonDocument, etc.
    Gui         # QGuiApplication, fonts, colors
    Quick       # QML engine, Qt Quick controls
    Qml         # QQmlApplicationEngine, QQmlContext
    QuickControls2  # ApplicationWindow, Button, TextField, etc.
)

# Silence Qt 6.5+ policy warnings for this learning POC
qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

# ── Source Files ──────────────────────────────────────────────────────────────
set(SOURCES
    src/main.cpp
    src/model/Activity.h
    src/model/Activity.cpp
    src/model/ActivityListModel.h
    src/model/ActivityListModel.cpp
    src/service/ActivityService.h
    src/service/ActivityService.cpp
    src/persistence/JsonStore.h
    src/persistence/JsonStore.cpp
)

# ── QML / Resource Files ──────────────────────────────────────────────────────
set(QML_FILES
    qml/main.qml
    qml/views/ActivityListView.qml
    qml/views/EmptyStateView.qml
    qml/components/ActivityCard.qml
    qml/components/AddActivityForm.qml
    qml/components/SummaryBar.qml
)

# ── Executable ────────────────────────────────────────────────────────────────
qt_add_executable(ActivityTracker
    MANUAL_FINALIZATION
    ${SOURCES}
)

# Register QML module (Qt 6 style: replaces .qrc for QML files)
qt_add_qml_module(ActivityTracker
    URI ActivityTracker          # import ActivityTracker 1.0 in QML
    VERSION 1.0
    QML_FILES ${QML_FILES}
)

# ── Link Qt Libraries ─────────────────────────────────────────────────────────
target_link_libraries(ActivityTracker PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Qml
    Qt6::QuickControls2
)

# ── Include Paths ─────────────────────────────────────────────────────────────
target_include_directories(ActivityTracker PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# ── Windows: hide the console window in Release builds ────────────────────────
if(WIN32)
    set_target_properties(ActivityTracker PROPERTIES
        WIN32_EXECUTABLE $<CONFIG:Release>
    )
endif()

qt_finalize_executable(ActivityTracker)
