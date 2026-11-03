// SummaryBar.qml — bottom status bar showing activity counts and total time

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    height: 36
    color: "#13151A"

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 24
            rightMargin: 24
        }
        spacing: 24

        // Bind directly to the C++ model's count property.
        // When ActivityListModel emits countChanged(), this Text item
        // re-evaluates automatically — no event listener needed.
        Text {
            text: "Total: " + activityModel.count + " activities"
            color: "#6B7280"
            font.pixelSize: 12
        }

        // completedCount is a Q_PROPERTY on ActivityService — reactive binding.
        Text {
            text: "Completed: " + activityService.completedCount
            color: "#10B981"
            font.pixelSize: 12
        }

        Item { Layout.fillWidth: true }  // spacer

        Text {
            text: "Today: " + activityService.totalDurationToday + " min"
            color: "#58A6FF"
            font.pixelSize: 12
        }
    }
}
