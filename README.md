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

### Quick Option: 1-Click Batch Scripts (Easiest)

In Windows Explorer or terminal, simply double-click:
- **`build-and-run.bat`**: Configures, compiles Debug mode, deploys dependencies, and launches the app.
- **`build-release.bat`**: Compiles an optimized, lightweight Release `.exe` and runs `windeployqt6` to create a standalone distribution folder.
- **`run-tests.bat`**: Runs the complete automated test suite (`ctest`) against the compiled binary.

---

### Manual Option: PowerShell / Command Line

#### 1. Configure CMake
```powershell
C:\Qt\Tools\CMake_64\bin\cmake.exe `
  -S d:\CVS\9X\trading-desktop\ActivityTracker `
  -B d:\CVS\9X\trading-desktop\ActivityTracker\build `
  -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_PREFIX_PATH=C:/Qt/6.9.3/msvc2022_64
```

#### 2. Compile (Debug or Release)
- **For Debug mode (faster compilation, debugging symbols):**
  ```powershell
  C:\Qt\Tools\CMake_64\bin\cmake.exe --build d:\CVS\9X\trading-desktop\ActivityTracker\build --config Debug
  ```
- **For Release mode (optimized performance, ~280 KB exe):**
  ```powershell
  C:\Qt\Tools\CMake_64\bin\cmake.exe --build d:\CVS\9X\trading-desktop\ActivityTracker\build --config Release
  ```

#### 3. Bundle Qt Runtime Dependencies (`windeployqt6`)
```powershell
C:\Qt\6.9.3\msvc2022_64\bin\windeployqt6.exe `
  --qmldir d:\CVS\9X\trading-desktop\ActivityTracker\qml `
  d:\CVS\9X\trading-desktop\ActivityTracker\build\Release\ActivityTracker.exe
```

#### 4. Run the Output Executable
- **Debug:** `d:\CVS\9X\trading-desktop\ActivityTracker\build\Debug\ActivityTracker.exe`
- **Release:** `d:\CVS\9X\trading-desktop\ActivityTracker\build\Release\ActivityTracker.exe`

---

### IDE Option: Qt Creator / VS Code
- **Qt Creator:** Open `CMakeLists.txt` → Select kit `Desktop Qt 6.9.3 MSVC 2022 64-bit` → Click the **Hammer icon** (Build, `Ctrl+B`) → Click **Green Play icon** (Run, `Ctrl+R`).
- **VS Code:** Make sure kit is set to **Visual Studio Community 2022 Release - amd64** → Press `F7` to Build → Press `Shift+F5` to Run.

---

### macOS Build Instructions

#### Prerequisites
```bash
brew install qt6 cmake
```

#### Quick Build Script (Debug or Release)
```bash
chmod +x build-macos.sh

# Release mode (default) — compiles and runs macdeployqt
./build-macos.sh

# Debug mode
./build-macos.sh Debug
```
* **Output:** `build/ActivityTracker.app` (Native macOS Application Bundle)
* Run it from terminal: `open build/ActivityTracker.app`

---

### Automated Multi-Platform CI/CD (GitHub Actions)

This repository includes a continuous integration workflow ([`.github/workflows/build.yml`](.github/workflows/build.yml)) that automatically compiles, tests, and packages both **Windows (`.exe` + DLLs)** and **macOS (`.app` + `.dmg`)** in both **Debug** and **Release** modes on every push! Download links are published automatically in the GitHub Actions **Artifacts** tab.

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

