// EmptyStateView.qml — high-contrast empty state view

import QtQuick
import QtQuick.Layouts

Column {
    spacing: 14

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "📋"
        font.pixelSize: 52
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "No activities yet"
        color: "#F0F6FC"
        font.pixelSize: 20
        font.bold: true
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Add an activity using the form on the left to start tracking."
        color: "#8B949E"
        font.pixelSize: 14
    }
}
