# 🔍 Detailed Code Walkthrough

This document takes you through every key file in the codebase. You will learn what every line does, why it exists, and the Qt/C++ concepts behind it.

---

## 1. Data Layer: `Activity.h` & `Activity.cpp`

### `src/model/Activity.h`
```cpp
struct Activity {
    QString   id;
    QString   name;
    QString   category;
    int       durationMinutes = 0;
    bool      done            = false;
    QDateTime createdAt;

    static Activity create(const QString &name,
                           const QString &category,
                           int durationMinutes);
};
```

#### What it teaches:
1. **`struct` vs. `class` in C++:**
   - In C++, a `struct` is identical to a `class`, with one difference: by default, all members in a `struct` are `public` (accessible to anyone).
   - We use a `struct` here because `Activity` is purely a data packet (like a TypeScript interface). It does not need inheritance or encapsulation.
2. **Default Member Initialization:**
   - `int durationMinutes = 0;` and `bool done = false;` ensure that if you create an `Activity` without values, memory won't contain random garbage values.
3. **`const QString &name` (Pass by Const Reference):**
   - In JavaScript, objects are passed by reference automatically.
   - In C++, passing `QString name` by default makes a full **copy** of the string.
   - Adding `&` (`QString &`) passes a reference (pointer to existing memory).
   - Adding `const` (`const QString &`) guarantees that this function cannot accidentally mutate or change the caller's string. **This is standard modern C++ for high performance.**

### `src/model/Activity.cpp`
```cpp
Activity Activity::create(const QString &name, const QString &category, int durationMinutes)
{
    Activity a;
    a.id               = QUuid::createUuid().toString(QUuid::WithoutBraces);
    a.name             = name;
    a.category         = category;
    a.durationMinutes  = durationMinutes;
    a.done             = false;
    a.createdAt        = QDateTime::currentDateTime();
    return a;
}
```
- `QUuid::createUuid()`: Generates a cryptographically random UUID (identical to `crypto.randomUUID()` in JavaScript).
- `Activity::create`: The `::` is the scope resolution operator. It means *"the `create` method that belongs to the `Activity` struct"*.

---

## 2. Model Layer: `ActivityListModel.h` & `ActivityListModel.cpp`

This is the most important class in the project. It bridges typed C++ data into QML's `ListView`.

### Why inherit from `QAbstractListModel`?
In JavaScript, you pass an array `[item1, item2]` to a React list and map over it.
In C++, if you have 10,000 items in a list, you don't want to copy all 10,000 items into the UI engine.
`QAbstractListModel` is a virtualized interface:
- QML only asks for the rows currently visible on your monitor.
- If only 6 items fit on screen, QML calls `data(index, role)` only for those 6 rows!

### Key Methods Explained:
```cpp
int rowCount(const QModelIndex &parent) const override;
```
- Returns the total number of items (`m_activities.size()`). QML calls this to configure scroll limits.

```cpp
QVariant data(const QModelIndex &index, int role) const override;
```
- Given a row number `index.row()` and a field request `role`, returns the value wrapped in a `QVariant` (Qt's universal type container, like TypeScript's `any` with runtime safety).

```cpp
QHash<int, QByteArray> roleNames() const override;
```
- Maps integer IDs to string names that QML understands:
  - `NameRole` &rarr; `"name"`
  - `CategoryRole` &rarr; `"category"`
  - `DurationRole` &rarr; `"durationMinutes"`
  - `DoneRole` &rarr; `"done"`

### The Mutation Protocol:
```cpp
void ActivityListModel::addActivity(const Activity &activity)
{
    const int newRow = m_activities.size();
    beginInsertRows(QModelIndex(), newRow, newRow); // 1. Notify views
    m_activities.append(activity);                 // 2. Modify memory
    endInsertRows();                               // 3. Confirm addition
    Q_EMIT countChanged();                         // 4. Trigger count update
}
```
> ⚠️ **Golden Rule of Qt Models:** You must **always** call `beginInsertRows()` before modifying your vector, and `endInsertRows()` immediately after. This prevents race conditions and crashes in the UI.

---

## 3. Service Layer: `ActivityService.h` & `ActivityService.cpp`

`ActivityService` acts as the Controller / Redux Store of the application.

```cpp
class ActivityService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int totalDurationToday READ totalDurationToday NOTIFY totalDurationTodayChanged)
    Q_PROPERTY(int completedCount READ completedCount NOTIFY completedCountChanged)
    Q_PROPERTY(ActivityListModel* model READ model CONSTANT)
...
    Q_INVOKABLE void addActivity(const QString &name, const QString &category, int durationMinutes);
    Q_INVOKABLE void removeActivity(int index);
    Q_INVOKABLE void markComplete(int index);
```

### Essential Concepts:
1. **`Q_OBJECT` macro:**
   - Must appear in the `private:` header of any class that uses signals, slots, or `Q_PROPERTY`.
   - Qt's build tool (`moc` - Meta-Object Compiler) inspects this macro and automatically writes C++ glue code behind the scenes.
2. **`Q_PROPERTY`:**
   - Exposes a C++ property to QML as a reactive variable.
   - When `totalDurationTodayChanged()` is emitted in C++, any QML element bound to `activityService.totalDurationToday` automatically updates on screen.
3. **`Q_INVOKABLE`:**
   - Makes a C++ function callable directly by name from QML JavaScript:
     ```qml
     activityService.addActivity("Study", "Learning", 45);
     ```
4. **Parent-Child Memory Ownership:**
   ```cpp
   ActivityService::ActivityService(QObject *parent)
       : QObject(parent)
       , m_model(new ActivityListModel(this)) // 'this' is the parent!
   ```
   - In Qt, when you pass `this` into the constructor of another `QObject`, a parent-child relationship is formed.
   - When `ActivityService` is destroyed, Qt **automatically deletes `m_model`**. No manual `delete` call is required! This is Qt's built-in memory safety system.

---

## 4. Persistence Layer: `JsonStore.h` & `JsonStore.cpp`

This class handles reading and writing the list of activities to disk.

```cpp
QString JsonStore::filePath()
{
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dir);
    return dir + "/activities.json";
}
```

- **`QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)`:**
  - On Windows, this resolves to `%APPDATA%\9X Trading\ActivityTracker`.
  - On macOS, it resolves to `~/Library/Application Support/9X Trading/ActivityTracker`.
  - On Linux, it resolves to `~/.local/share/9X Trading/ActivityTracker`.
  - **You never have to hardcode OS paths!**
- **`QJsonDocument`:** Converts arrays and objects into indented, human-readable JSON.
- **`QFile`:** Provides safe file stream operations with error checking.

---

## 5. Entry Point: `main.cpp`

```cpp
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Material");

    ActivityService service; // Lives on the stack (destroyed cleanly at exit)

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("activityService", &service);
    engine.rootContext()->setContextProperty("activityModel", service.model());

    const QUrl mainQml("qrc:/qt/qml/ActivityTracker/qml/main.qml");
    engine.load(mainQml);

    return app.exec(); // Starts the event loop!
}
```

- **`setContextProperty`:** Registers C++ objects as global names inside QML.
- **`app.exec()`:** The program halts here and runs the event loop. It waits for user clicks, keyboard strokes, and timer ticks. When the window is closed, `app.exec()` returns `0`, exiting `main()`.

---

## 6. UI Layer: Modern QML Architecture

- **`qml/main.qml`:** The root window. It configures the Dark Material theme and splits the window into a 300px sidebar on the left and a scrollable card area on the right.
- **`qml/components/AddActivityForm.qml`:** Input form. Uses `TextField`, `ComboBox`, and `SpinBox`. Handles keyboard <kbd>Enter</kbd> to submit directly.
- **`qml/components/ActivityCard.qml`:** Each card in the list. Features:
  - Explicit model role bindings (`model.name`, `model.category`, `model.durationMinutes`, `model.done`).
  - Color-coded category pill badges.
  - Duration pill (`⏱ 30 min`).
  - Custom delete button (`✕`) with red hover effect.
- **`qml/components/SummaryBar.qml`:** Bottom status strip showing Total, Completed, and Today's duration.
