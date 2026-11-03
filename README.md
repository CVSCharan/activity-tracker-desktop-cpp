# Activity Tracker — Qt/QML Learning POC

A standalone desktop application built as a **3-week C++ and Qt/QML learning proof of concept**.

## Purpose

This project was built step-by-step to learn:
- Modern C++ (C++17): structs, classes, references, `const`, STL containers
- Qt object model: `QObject`, `Q_OBJECT`, signals and slots, `Q_PROPERTY`
- `QAbstractListModel` — exposing typed C++ data to QML
- QML: layouts, controls, reusable components, delegates
- C++↔QML integration: `Q_INVOKABLE`, context properties, reactive bindings
- Persistence: `QJsonDocument`, `QFile`, `QStandardPaths`

## Architecture

```
ActivityTracker/
├── src/
│   ├── model/
│   │   ├── Activity.h/.cpp          # Plain data struct (no QObject)
│   │   └── ActivityListModel.h/.cpp # QAbstractListModel — C++ → QML data bridge
│   ├── service/
│   │   └── ActivityService.h/.cpp  # Business logic: Q_INVOKABLE, Q_PROPERTY
│   ├── persistence/
│   │   └── JsonStore.h/.cpp        # QJsonDocument file I/O
│   └── main.cpp                    # Entry point: QGuiApplication + QQmlApplicationEngine
├── qml/
│   ├── main.qml                    # Root ApplicationWindow
│   ├── views/
│   │   ├── ActivityListView.qml    # ListView with delegate
│   │   └── EmptyStateView.qml      # Shown when list is empty
│   └── components/
│       ├── ActivityCard.qml        # Single activity row
│       ├── AddActivityForm.qml     # Input form (TextField, ComboBox, SpinBox)
│       └── SummaryBar.qml          # Bottom status bar
├── CMakeLists.txt
└── README.md
```

## Prerequisites

- Qt 6.4+ with Qt Quick and Qt Quick Controls 2 (`C:\Qt\6.9.3\msvc2022_64`)
- CMake 3.21+ (`C:\Qt\Tools\CMake_64\bin\cmake.exe`)
- MSVC 2022 x64 (Visual Studio 2022 Community or higher)

## Build Instructions

### 1. Configure

```powershell
C:\Qt\Tools\CMake_64\bin\cmake.exe `
  -S d:\CVS\9X\trading-desktop\ActivityTracker `
  -B d:\CVS\9X\trading-desktop\ActivityTracker\build `
  -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_PREFIX_PATH=C:/Qt/6.9.3/msvc2022_64
```

### 2. Build

```powershell
C:\Qt\Tools\CMake_64\bin\cmake.exe `
  --build d:\CVS\9X\trading-desktop\ActivityTracker\build `
  --config Debug --parallel 4
```

### 3. Deploy Qt DLLs (first time only)

```powershell
C:\Qt\6.9.3\msvc2022_64\bin\windeployqt6.exe `
  --qmldir d:\CVS\9X\trading-desktop\ActivityTracker\qml `
  --no-translations `
  d:\CVS\9X\trading-desktop\ActivityTracker\build\Debug\ActivityTracker.exe
```

### 4. Run

```powershell
d:\CVS\9X\trading-desktop\ActivityTracker\build\Debug\ActivityTracker.exe
```

> **Opening in Qt Creator:** File → Open File or Project → select `CMakeLists.txt`.
> Qt Creator will configure and build automatically when you set the kit to `Qt 6.9.3 MSVC2022 64bit`.

## Data Storage

Activities are persisted to:
```
%APPDATA%\9X Trading\ActivityTracker\activities.json
```

## Key Qt/C++ Concepts Demonstrated

| File | Concept |
|---|---|
| `Activity.h` | C++ struct, default member values, `QString`, `QDateTime` |
| `Activity.cpp` | Static factory, `const &` parameters, `QUuid` |
| `ActivityListModel.h/.cpp` | `QAbstractListModel`, `Q_OBJECT`, `roleNames()`, `beginInsertRows`, `dataChanged` |
| `ActivityService.h/.cpp` | `Q_INVOKABLE`, `Q_PROPERTY`, signals, RAII ownership (`new X(this)`) |
| `JsonStore.h/.cpp` | `QJsonDocument`, `QFile`, `QStandardPaths`, error handling |
| `main.cpp` | `QGuiApplication`, `QQmlApplicationEngine`, `setContextProperty` |
| `main.qml` | `ApplicationWindow`, `Connections`, dark `Material` theme |
| `ActivityCard.qml` | `required property`, `signal`, `HoverHandler` |
| `AddActivityForm.qml` | `TextField`, `ComboBox`, `SpinBox`, form validation |
| `ActivityListView.qml` | `ListView`, delegate binding, `ScrollBar` |
| `SummaryBar.qml` | Reactive bindings to C++ `Q_PROPERTY` |
