// EmptyStateView.qml — shown when the activity list is empty

import QtQuick
import QtQuick.Layouts

Column {
    spacing: 12

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "📭"
        font.pixelSize: 48
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "No activities yet"
        color: "#6B7280"
        font.pixelSize: 18
        font.bold: true
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Add your first activity using the form on the left."
        color: "#4B5563"
        font.pixelSize: 13
    }
}
