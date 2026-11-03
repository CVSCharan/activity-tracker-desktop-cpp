# 🧠 Architecture & "Explain Like I'm 5" Guide

Welcome to the beginner-friendly architecture guide for **Activity Tracker**!

If someone asks you: *"What did you build, how does it work, and why did you use these technologies?"* — this document gives you the mental model and analogies to explain it with total clarity.

---

## 1. The Big Picture (The Restaurant Analogy 🍽️)

Think of our desktop application like a well-run **Italian Restaurant**:

```
 ┌──────────────────────┐         ┌──────────────────────┐         ┌──────────────────────┐
 │     THE DINING ROOM  │ <-----> │      THE WAITER      │ <-----> │      THE KITCHEN     │
 │     (QML / UI)       │         │  (ActivityService)   │         │ (ActivityListModel)  │
 │                      │         │                      │         │                      │
 │ Buttons, TextFields, │ Orders  │ Translates requests, │ Prepares│ Holds recipes,       │
 │ Animations, Colors   │ placed  │ validates inputs,    │ the food│ manages the raw data │
 └──────────────────────┘         │ coordinates cooks    │         └──────────┬───────────┘
                                  └──────────────────────┘                    │
                                                                       ┌──────▼──────────┐
                                                                       │    THE PANTRY   │
                                                                       │   (JsonStore)   │
                                                                       │                 │
                                                                       │ Saves food to   │
                                                                       │ the hard disk   │
                                                                       └─────────────────┘
```

1. **The Dining Room (QML / Views):** This is what the customer sees. It is beautiful, interactive, and built with declarative code (like HTML/CSS/React). It doesn't know *how* to cook food or save to a database; it just displays things and captures clicks.
2. **The Waiter (`ActivityService`):** When a user clicks "+ Add Activity", the Dining Room tells the Waiter. The waiter validates the order: *"Is the name empty? Is the duration negative?"* If something is wrong, the waiter politely declines. If valid, the waiter tells the Kitchen.
3. **The Kitchen (`ActivityListModel`):** This is the heart of the operation. It maintains the list of activities in C++ memory with microsecond speed. When an item is added or finished, it rings a bell (`beginInsertRows` / `dataChanged`) to tell the dining room to update the board.
4. **The Pantry (`JsonStore`):** If the restaurant closes and reopens tomorrow, we don't want to lose our records. The pantry serializes the activities into a clean JSON file on the computer's hard disk (`%APPDATA%`).

---

## 2. JavaScript / React vs. C++ / Qt Dictionary

If you know JavaScript, TypeScript, and React, you already know 90% of the concepts. They just have different names in C++ and Qt:

| Concept | JavaScript / React / Node.js | Modern C++ / Qt 6 | What It Actually Means |
|---|---|---|---|
| **Data Container** | `interface Activity { name: string; }` or object literal `{}` | `struct Activity { QString name; };` | A lightweight blueprint for holding data fields. |
| **String Type** | `string` / `String` | `QString` | A string with full Unicode support (handles emojis, foreign characters, and memory efficiently). |
| **Array** | `const list = [a, b, c];` | `QVector<Activity>` or `std::vector` | A list of items stored next to each other in memory for maximum speed. |
| **State Management** | React `useState()` or MobX `@observable` | `QAbstractListModel` + `Q_PROPERTY` | When this data changes, the UI automatically updates without manual DOM queries. |
| **Event Listeners** | `button.addEventListener('click', fn)` or `onClick` | **Signals and Slots** (`Q_EMIT clicked()`) | Object A sends a message; Object B listens and reacts. Completely decoupled. |
| **Exporting to UI** | Passing props or React Context | `setContextProperty("service", &service)` | Makes a C++ backend object accessible inside any QML file like a global store. |
| **Calling Backend from UI** | `fetch('/api/add')` or calling a server action | `Q_INVOKABLE void addActivity(...)` | A macro that permits QML (JavaScript) to directly invoke a native C++ function. |
| **Package / Build Tool** | `package.json` + `webpack` / `vite` | `CMakeLists.txt` + `CMake` | Tells the compiler what files to build, what libraries to link, and which Qt version to use. |
| **Linter** | `ESLint` | `clang-tidy` | Scans C++ source code to find bugs, bad practices, and memory mistakes. |
| **Type Definition File** | `tsconfig.json` | `compile_commands.json` | Tells the editor where all header files and compiler flags live so you don't get red squiggles. |
| **Local Storage** | `localStorage.setItem('key', json)` | `QJsonDocument` + `QFile` to `%APPDATA%` | Saves structured data to a local file on the user's computer. |

---

## 3. Why Did We Choose These Technologies?

### Why C++17?
- **Speed & Efficiency:** C++ compiles down directly to native CPU machine code (`010101`). Unlike JavaScript/Electron, there is **no heavy browser engine (Chromium)** running in the background consuming 500MB of RAM.
- **Safety:** C++17 gives us modern features like `auto`, smart pointers, and range-based `for` loops, so we never have to manage raw memory or dangerous pointers manually.

### Why Qt 6 & QML?
- **Separation of Concerns:** 
  - Heavy logic, data processing, and file saving live in **C++** (fast, safe, strongly typed).
  - UI design, layouts, animations, and themes live in **QML** (declarative, flexible, looks like JSON/CSS).
- **Cross-Platform:** The exact same C++ and QML code can compile on Windows, macOS, Linux, and even mobile devices without rewriting the UI.
- **Hardware-Accelerated:** Qt Quick uses your computer's GPU (Direct3D on Windows, Metal on Mac, OpenGL/Vulkan) to render 60 FPS silky-smooth animations with near-zero CPU usage.

---

## 4. How Data Flows (Step-by-Step)

Here is what happens when you type *"Buy groceries"*, choose *"Personal"*, and click **"+ Add Activity"**:

```
[1] User clicks "+ Add Activity" in AddActivityForm.qml
                          │
                          ▼
[2] QML calls C++: activityService.addActivity("Buy groceries", "Personal", 30)
                          │
                          ▼
[3] ActivityService validates the inputs (ensures name is not blank)
                          │
                          ▼
[4] ActivityService creates an Activity struct:
    Activity a = Activity::create("Buy groceries", "Personal", 30);
                          │
                          ▼
[5] ActivityService tells ActivityListModel to insert the row:
    model->addActivity(a)
    ├── beginInsertRows(...)  <-- Notifies QML ListView that a row is arriving
    ├── m_activities.append(a)
    └── endInsertRows()        <-- ListView smoothly animates the new card in
                          │
                          ▼
[6] ActivityService saves the updated list to disk:
    JsonStore::save(activities) --> writes to %APPDATA%/activities.json
                          │
                          ▼
[7] ActivityService emits totalDurationTodayChanged():
    Summary bar and header bar automatically re-render the total minutes
```

Everything is **reactive, fast, and crash-proof**.
