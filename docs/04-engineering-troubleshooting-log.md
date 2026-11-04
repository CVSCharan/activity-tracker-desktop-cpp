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

---

## Issue 5: Linter False-Positives on Attached Properties and Context Objects (`.qmllint.ini`)

### 🔴 Symptom
When opening QML files in VS Code, the editor displayed multiple warnings:
- `Type Layout is used but it is not resolved [unresolved-type]`
- `Type Material is used but it is not resolved [unresolved-type]`
- `Unqualified access to context property 'activityService' [unqualified]`

### 🔍 Root Cause Analysis
- **Dynamic C++ Injection:** `activityService` and `activityModel` are injected dynamically at runtime via C++ (`rootContext()->setContextProperty(...)`). Static analyzers do not run C++ code, so they warn that the identifier is not defined inside the static QML file.
- **Attached Properties:** `Layout.*` (from `QtQuick.Layouts`) and `Material.*` (from `QtQuick.Controls.Material`) are attached property types, not standalone components. Without build-directory AST caches, the linter treats them as missing instantiations.

### 🟢 Resolution & Industry Best Practice
We created and committed `.qmllint.ini`:
```ini
[Warnings]
unqualified=disable
UnqualifiedAccess=disable
import=disable
Import=disable
ImportFailure=disable
unresolved-type=disable
UnresolvedType=disable
UnresolvedAttachedProperty=disable
```
- **Why keeping `.qmllint.ini` in Git is standard practice:** Just as frontend teams commit `.eslintrc.json` or `.prettierrc` so that every developer and CI pipeline runs with consistent code-quality rules, committing `.qmllint.ini` standardizes Qt linter behavior across all workstations and automated CI test runners.


---

## Issue 6: Qt 6 Delegate Required Properties Role Mapping (`(Untitled Activity)` & `0 min`)

### 🔴 Symptom
When adding activities or clicking quick-start templates, the cards rendered with `(Untitled Activity)`, `General`, and `0 min` instead of their actual name, category, and duration.

### 🔍 Root Cause Analysis
In Qt 6, when a custom delegate declares `required property`, Qt's QML engine alters data binding:
1. **Automated Role Matching:** Qt 6 searches the C++ model for roles with the exact same identifier as the required property.
2. If `ActivityCard.qml` declares `required property string activityName`, Qt 6 searches for a model role named `"activityName"`. Because the C++ `ActivityListModel::roleNames()` provides `"name"`, `"category"`, and `"durationMinutes"`, Qt 6 finds no match and initializes the required property to default values (`""`, `0`).
3. Furthermore, declaring `required property` disables legacy context object injection (`model.name`), rendering manual assignments inside the delegate null or unreactive.

### 🟢 Resolution & Best Practice
Aligned delegate property names to match C++ role names exactly:
```qml
// ActivityCard.qml
required property string name
required property string category
required property int    durationMinutes
required property bool   done
required property int    index
```
In `ActivityListView.qml`, Qt 6 directly and automatically populates these properties with zero boilerplate and full compile-time type safety.

---

## Issue 7: Multi-Platform CI/CD Workflow Failures (Windows & macOS)

### 🔴 Symptoms
The GitHub Actions workflow failed on both Windows and macOS runners:
1. **Windows:** `Error: The process 'C:\hostedtoolcache\windows\Python\3.15.2\x64\python.exe' failed with exit code 1`.
2. **Windows:** `ERROR: The packages ['qt_base'] were not found while parsing XML of package information!`.
3. **Windows:** `Generator Visual Studio 17 2022 could not find any instance of Visual Studio`.
4. **macOS:** `ld: framework 'AGL' not found` during linking `ActivityTracker.app`.
5. **CTest (Windows):** `Exit code 0xc0000135` (`STATUS_DLL_NOT_FOUND`).

### 🔍 Root Cause Analysis & Resolutions

1. **Python Toolcache Alpha Version:**
   * *Root Cause:* GitHub's runner image populated Python 3.15.2 alpha in `hostedtoolcache`. `jurplel/install-qt-action` defaulted to `setup-python: true`, discovering and crashing on Python 3.15 alpha.
   * *Fix:* Added `actions/setup-python@v5` with `python-version: '3.12'` and set `setup-python: false` in `install-qt-action`.
2. **Qt 6 Architecture Identifier Mismatch:**
   * *Root Cause:* In Qt 6 on Windows, the 64-bit MSVC package in `aqtinstall` is officially named `win64_msvc2022_64` (not `win64_msvc2022`).
   * *Fix:* Updated `arch: win64_msvc2022_64`.
3. **`windows-latest` Runner Version Drift:**
   * *Root Cause:* `windows-latest` migrated to preview `windows-2025` with Visual Studio 18/2026, where CMake could not locate Visual Studio 17 2022.
   * *Fix:* Pinned the runner explicitly to `windows-2022`.
4. **Obsolete Apple Carbon `AGL` Linker Dependency:**
   * *Root Cause:* Modern macOS (macOS 14/15/26 Apple Silicon) removed the deprecated Carbon `AGL.framework`. Qt 6.8's `FindWrapOpenGL.cmake` unconditionally linked `-framework AGL`.
   * *Fix:* In root `CMakeLists.txt`, pre-empted the finder by declaring `WrapOpenGL::WrapOpenGL` target with `-framework OpenGL` when `APPLE` is true.
5. **CTest Missing Qt DLLs on Windows (`0xc0000135`):**
   * *Root Cause:* The test executable `tst_ActivityModel.exe` was executed without Qt's `bin` directory in system `PATH`.
   * *Fix:* Added `set_tests_properties(tst_ActivityModel PROPERTIES ENVIRONMENT "PATH=$<TARGET_FILE_DIR:Qt6::Core>;$ENV{PATH}")` in `CMakeLists.txt`.

---

## Issue 8: Material Design Floating Placeholder Overlay Glitch

### 🔴 Symptom
In `TextField`, when focused or after typing, placeholder text did not disappear cleanly; it floated or remained overlayed on top of the user's typed text.

### 🔍 Root Cause Analysis
`QQuickStyle::setStyle("Material")` activates Material Design's mobile floating label animation. When a custom `background: Rectangle` with fixed container height and padding is used, the floating label cannot translate outside the container boundaries, causing it to render directly over the input text baseline.

### 🟢 Resolution & Modern Desktop Desktop Input Architecture
1. Set `placeholderText: ""` on the `TextField` to disable Material's internal floating label.
2. Embedded a custom smooth `Text` placeholder inside the container that softly dims on focus (`opacity: 0.35`) and instantly transitions to `0` opacity the moment any character is typed.
3. Added a dynamic Electric Blue focus halo, clear button (`✕`), and keyboard shortcut badge (`↵`).
