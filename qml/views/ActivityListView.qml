// ActivityListView.qml — scrollable list with live instant search and category filtering
import QtQuick
import QtQuick.Controls
import "../components" as Components
import ActivityTracker 1.0

ListView {
    id: listView
    clip: true
    spacing: 8

    property string filterCategory: "All"
    property string filterText: ""

    model: activityModel

    topMargin:    0
    bottomMargin: 10
    leftMargin:   0
    rightMargin:  0

    delegate: Components.ActivityCard {
        id: cardDelegate
        width: listView.width

        // Explicit model.role bindings
        activityName:      model.name
        activityCategory:  model.category
        activityDuration:  model.durationMinutes
        activityDone:      model.done
        activityIndex:     model.index

        // ── Filter Evaluation ─────────────────────────────────────────────────
        readonly property bool matchesCategory: {
            if (listView.filterCategory === "All") return true;
            if (listView.filterCategory === "Done") return model.done;
            return model.category === listView.filterCategory;
        }

        readonly property bool matchesSearch: {
            if (listView.filterText.trim().length === 0) return true;
            return model.name.toLowerCase().includes(listView.filterText.trim().toLowerCase());
        }

        readonly property bool isVisibleInFilter: matchesCategory && matchesSearch

        visible: isVisibleInFilter
        height: isVisibleInFilter ? 76 : 0

        Behavior on height { NumberAnimation { duration: 150 } }

        onRemoveRequested: activityService.removeActivity(activityIndex)
        onCompleteRequested: activityService.markComplete(activityIndex)
    }

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
    }
}
