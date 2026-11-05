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
    property string filterTimeframe: "All Time"

    model: activityModel

    topMargin:    0
    bottomMargin: 10
    leftMargin:   0
    rightMargin:  0

    // Smooth list transitions
    add: Transition {
        NumberAnimation { properties: "opacity,scale"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
    }
    remove: Transition {
        NumberAnimation { properties: "opacity,scale"; to: 0; duration: 150; easing.type: Easing.InCubic }
    }
    displaced: Transition {
        NumberAnimation { properties: "y"; duration: 200; easing.type: Easing.OutCubic }
    }

    delegate: Components.ActivityCard {
        id: cardDelegate
        width: listView.width

        // ── Filter Evaluation ─────────────────────────────────────────────────
        readonly property bool matchesCategory: {
            if (listView.filterCategory === "All") return true;
            if (listView.filterCategory === "Done") return cardDelegate.done;
            if (listView.filterCategory === "In Progress") return cardDelegate.activeStatus === "In Progress";
            if (listView.filterCategory === "Todo") return cardDelegate.activeStatus === "Created";
            return cardDelegate.category === listView.filterCategory;
        }

        readonly property bool matchesSearch: {
            if (listView.filterText.trim().length === 0) return true;
            return cardDelegate.name.toLowerCase().includes(listView.filterText.trim().toLowerCase());
        }

        readonly property bool matchesTimeframe: {
            if (listView.filterTimeframe === "All Time") return true;
            if (!model.createdAt) return true;
            const now = new Date();
            const created = new Date(model.createdAt);
            if (isNaN(created.getTime())) return true;

            if (listView.filterTimeframe === "Today") {
                return created.toDateString() === now.toDateString();
            } else if (listView.filterTimeframe === "Last 7 Days") {
                return (now - created) <= 7 * 24 * 3600 * 1000;
            } else if (listView.filterTimeframe === "Last 30 Days") {
                return (now - created) <= 30 * 24 * 3600 * 1000;
            }
            return true;
        }

        readonly property bool isVisibleInFilter: matchesCategory && matchesSearch && matchesTimeframe

        visible: isVisibleInFilter
        height: isVisibleInFilter ? 76 : 0

        Behavior on height { NumberAnimation { duration: 150 } }

        onRemoveRequested: activityService.removeActivity(cardDelegate.index)
        onCompleteRequested: activityService.markComplete(cardDelegate.index)
        onReopenRequested: activityService.reopenActivity(cardDelegate.index)
        onStatusChangeRequested: function(newStatus) {
            activityService.setActivityStatus(cardDelegate.index, newStatus)
        }
        onExtendRequested: function(additionalMinutes) {
            activityService.extendActivity(cardDelegate.index, additionalMinutes)
        }
        onCreateExtensionRequested: function(minutes) {
            activityService.createExtension(cardDelegate.index, minutes)
        }
    }

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
    }
}
