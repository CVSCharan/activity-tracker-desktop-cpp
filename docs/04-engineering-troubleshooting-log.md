# 🛠️ Real-World Engineering & Troubleshooting Log

During the development of this project, we encountered four real-world C++ and Qt engineering challenges. Documenting how we diagnosed and resolved each one demonstrates practical systems engineering capability.

---

## Issue 1: Application Exited Immediately with Code 1 on Startup

### 🔴 Symptom
Double-clicking or running `ActivityTracker.exe` caused the process to terminate within milliseconds with exit code `1`. No window appeared.

### 🔍 Root Cause Analysis
We ran the binary directly in a command prompt with console stderr capture:
```powershell
cmd /c "set QT_ASSUME_STDERR_HAS_CONSOLE=1 && ActivityTracker.exe 2>&1"
```
Output:
```text
QQmlApplicationEngine failed to load component
qrc:/ActivityTracker/qml/main.qml: No such file or directory
Failed to load QML: QUrl("qrc:/ActivityTracker/qml/main.qml")
```
- In Qt 6, `qt_add_qml_module` follows CMake policy **`QTP0001`**, which sets the default internal resource prefix to `:/qt/qml/`.
- The QML module named `ActivityTracker` was embedded at:
  `qrc:/qt/qml/ActivityTracker/qml/main.qml`
- But `main.cpp` was requesting:
  `qrc:/ActivityTracker/qml/main.qml` (missing `/qt/qml`).

### 🟢 Resolution
Updated `src/main.cpp`:
```cpp
const QUrl mainQml("qrc:/qt/qml/ActivityTracker/qml/main.qml");
```
The QML engine loaded the root window successfully.

---

## Issue 2: A Black Command Prompt (CLI) Window Opened Alongside the GUI

### 🔴 Symptom
When launching `ActivityTracker.exe`, a black Windows Command Prompt window opened first. If the user closed the command prompt, the entire desktop application closed.

### 🔍 Root Cause Analysis
- Windows executables (PE files) specify a **Subsystem** in their PE header:
  - `IMAGE_SUBSYSTEM_WINDOWS_CUI` (Console): Spawns a console window.
  - `IMAGE_SUBSYSTEM_WINDOWS_GUI` (GUI): Does not spawn a console window.
- In `CMakeLists.txt`, we initially had:
  ```cmake
  WIN32_EXECUTABLE $<CONFIG:Release>
  ```
  Because we were building in **Debug** mode (`--config Debug`), the generator expression evaluated to false. MSVC linked the executable with `/SUBSYSTEM:CONSOLE`.

### 🟢 Resolution
Changed `CMakeLists.txt` to enable `WIN32_EXECUTABLE` unconditionally:
```cmake
if(WIN32)
    set_target_properties(ActivityTracker PROPERTIES
        WIN32_EXECUTABLE ON
    )
endif()
```
Inspected the re-linked binary with `dumpbin /headers`:
```text
            6.00 subsystem version
               2 subsystem (Windows GUI)
```
The executable now launches directly into the Windows desktop with no terminal window.

---

## Issue 3: Editor Showed "Unknown type name 'QString'" & "Undeclared Identifier"

### 🔴 Symptom
The code compiled with zero errors using MSVC, but the IDE editor showed red squiggles on `QString`, `QGuiApplication`, and other Qt classes.

### 🔍 Root Cause Analysis
- Unlike JavaScript (where `package.json` and `node_modules` sit directly in the folder), C++ header files live in the installed toolchain (`C:\Qt\6.9.3\msvc2022_64\include`).
- The editor's C/C++ language server (IntelliSense / clangd) needs a **`compile_commands.json`** file to know all include directories and preprocessor definitions.
- Visual Studio project generators (`.vcxproj`) do not emit `compile_commands.json` by default.

### 🟢 Resolution
1. Ran CMake with Ninja generator to generate [`compile_commands.json`](file:///d:/CVS/9X/trading-desktop/ActivityTracker/compile_commands.json).
2. Added [`.vscode/c_cpp_properties.json`](file:///d:/CVS/9X/trading-desktop/ActivityTracker/.vscode/c_cpp_properties.json) referencing `compileCommands: "${workspaceFolder}/compile_commands.json"` and providing explicit fallback include paths for Qt 6.
3. Added automatic `CMAKE_PREFIX_PATH` fallback in [`CMakeLists.txt`](file:///d:/CVS/9X/trading-desktop/ActivityTracker/CMakeLists.txt) to automatically locate `C:/Qt/6.9.3/msvc2022_64`.
All editor squiggles were resolved.

---

## Issue 4: Activity Card Displayed Blank Name and "• 0 min"

### 🔴 Symptom
When a user added an activity, the list created a card, but the title was empty and duration showed `• 0 min` instead of the entered values.

### 🔍 Root Cause Analysis
In `ActivityListView.qml`, the delegate was defined as:
```qml
delegate: Components.ActivityCard {
    activityName: name
    activityDuration: durationMinutes
}
```
- In Qt 6 QML modules, unqualified model role access (e.g. `name` instead of `model.name`) inside delegate child instances is deprecated and does not resolve into scope.
- `name` evaluated to `undefined`, assigning an empty string `""`.
- `durationMinutes` evaluated to `undefined`, defaulting to `0`.

### 🟢 Resolution
Updated [`ActivityListView.qml`](file:///d:/CVS/9X/trading-desktop/ActivityTracker/qml/views/ActivityListView.qml) to use explicit `model.` prefixes:
```qml
delegate: Components.ActivityCard {
    activityName:      model.name
    activityCategory:  model.category
    activityDuration:  model.durationMinutes
    activityDone:      model.done
    activityIndex:     model.index
}
```
The card immediately displayed the correct title, category, and duration minutes.
