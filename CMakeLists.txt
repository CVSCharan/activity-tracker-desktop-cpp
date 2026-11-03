cmake_minimum_required(VERSION 3.21)
project(ActivityTracker VERSION 1.0.0 LANGUAGES CXX)

# ── C++ Standard ──────────────────────────────────────────────────────────────
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(MSVC)
    add_compile_options(/Zc:__cplusplus /Zc:preprocessor /permissive-)
endif()

# ── Qt Automation ─────────────────────────────────────────────────────────────
# AUTOMOC: auto-runs moc on Q_OBJECT classes (generates signal/slot plumbing)
# AUTORCC: auto-compiles .qrc resource files
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# ── Find Qt6 ──────────────────────────────────────────────────────────────────
# Best Practice: In production and CI/CD, CMAKE_PREFIX_PATH is supplied by
# the IDE kit (Qt Creator), CMakePresets.json, environment variables, or -D flags.
# On macOS/Linux, package managers (e.g. Homebrew `brew install qt6` or `apt install qt6-base-dev`)
# place Qt in standard system paths where find_package finds it automatically.
# The fallback below only activates on Windows if no prefix path was passed.
if(NOT DEFINED CMAKE_PREFIX_PATH AND NOT DEFINED ENV{CMAKE_PREFIX_PATH})
    if(WIN32 AND EXISTS "C:/Qt/6.9.3/msvc2022_64")
        set(CMAKE_PREFIX_PATH "C:/Qt/6.9.3/msvc2022_64")
    endif()
endif()

find_package(Qt6 6.4 REQUIRED COMPONENTS
    Core        # QObject, QString, QVector, QJsonDocument, etc.
    Gui         # QGuiApplication, fonts, colors
    Quick       # QML engine, Qt Quick controls
    Qml         # QQmlApplicationEngine, QQmlContext
    QuickControls2  # ApplicationWindow, Button, TextField, etc.
    Test        # QTest unit testing framework
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
    qml/components/StatsDashboard.qml
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
    RESOURCES resources/icons/app_icon.svg
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

# ── Windows: pure GUI application (no CLI console window) ─────────────────────
if(WIN32)
    set_target_properties(ActivityTracker PROPERTIES
        WIN32_EXECUTABLE ON
    )
endif()

qt_finalize_executable(ActivityTracker)

# ── Unit Tests ────────────────────────────────────────────────────────────────
enable_testing()

add_executable(tst_ActivityModel
    tests/tst_ActivityModel.cpp
    src/model/Activity.h
    src/model/Activity.cpp
    src/model/ActivityListModel.h
    src/model/ActivityListModel.cpp
    src/service/ActivityService.h
    src/service/ActivityService.cpp
    src/persistence/JsonStore.h
    src/persistence/JsonStore.cpp
)

# Exclude test runner executable from Release builds (only build it in Debug mode)
set_target_properties(tst_ActivityModel PROPERTIES
    EXCLUDE_FROM_DEFAULT_BUILD_RELEASE TRUE
    EXCLUDE_FROM_DEFAULT_BUILD_MINSIZEREL TRUE
    EXCLUDE_FROM_DEFAULT_BUILD_RELWITHDEBINFO TRUE
)

target_include_directories(tst_ActivityModel PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(tst_ActivityModel PRIVATE
    Qt6::Core
    Qt6::Test
)

add_test(NAME tst_ActivityModel COMMAND tst_ActivityModel)
