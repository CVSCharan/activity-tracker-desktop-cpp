// ActivityListView.qml — scrollable list of activity cards
//
// ListView is like a virtualised FlatList in React Native / react-window.
// It only creates delegate items for the rows currently visible on screen.

import QtQuick
import QtQuick.Controls
import "../components" as Components

ListView {
    id: listView
    clip: true              // don't draw delegates outside this item's bounds
    spacing: 8

    // 'activityModel' is the C++ ActivityListModel set as a context property
    // in main.cpp.  No import needed — context properties are global in QML.
    model: activityModel

    // Padding so cards don't hug the edges
    topMargin:    12
    bottomMargin: 12
    leftMargin:   12
    rightMargin:  12

    // ── Delegate ──────────────────────────────────────────────────────────────
    // 'delegate' is rendered once per row — like a map() callback in JSX.
    // 'index' and all roleNames() values are auto-injected as local properties.
    delegate: Components.ActivityCard {
        // 'width: listView.width - ...' accounts for margins so cards fill
        // the available width properly.
        width: listView.width - listView.leftMargin - listView.rightMargin

        // Bind to the model roles defined in ActivityListModel::roleNames()
        activityName:      name             // model.name
        activityCategory:  category         // model.category
        activityDuration:  durationMinutes  // model.durationMinutes
        activityDone:      done             // model.done
        activityIndex:     index            // auto-provided by ListView

        // Wire card actions back to the service
        onRemoveRequested: activityService.removeActivity(activityIndex)
        onCompleteRequested: activityService.markComplete(activityIndex)
    }

    // ── Scrollbar ─────────────────────────────────────────────────────────────
    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
    }
}
