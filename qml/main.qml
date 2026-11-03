// main.qml — Root application window
//
// import statements bring in QML module namespaces:
//   QtQuick         → basic types: Rectangle, Text, ListView, etc.
//   QtQuick.Controls→ ApplicationWindow, Button, TextField, etc.
//   QtQuick.Layouts → ColumnLayout, RowLayout, GridLayout
//   QtQuick.Controls.Material → Material theme properties

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

import "./views"       as Views
import "./components"  as Components

ApplicationWindow {
    id: root
    visible: true
    width: 900
    height: 680
    minimumWidth: 700
    minimumHeight: 500
    title: "Activity Tracker"

    // ── Dark theme (Material design) ─────────────────────────────────────────
    Material.theme:     Material.Dark
    Material.accent:    "#58A6FF"   // Blue accent — matches DarkTheme.h from existing repos
    Material.background:"#181A1F"   // Dark background

    // ── Error toast state ────────────────────────────────────────────────────
    // Connections lets you listen to a C++ signal from QML.
    // activityService.errorOccurred is the signal defined in ActivityService.h
    Connections {
        target: activityService
        function onErrorOccurred(message) {
            errorBar.text = message
            errorBar.visible = true
            errorTimer.restart()
        }
    }

    // ── Root layout ──────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Header bar ───────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 56
            color: "#21252B"

            RowLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 24
                    rightMargin: 24
                }

                Text {
                    text: "📋  Activity Tracker"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#D7DAE0"
                }

                Item { Layout.fillWidth: true }  // spacer

                // Summary: total minutes today
                Text {
                    text: "Today: " + activityService.totalDurationToday + " min"
                    color: "#58A6FF"
                    font.pixelSize: 14
                }
            }
        }

        // ── Main content area: sidebar + list ────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Left panel: Add form
            Rectangle {
                width: 280
                Layout.fillHeight: true
                color: "#1E2127"

                Components.AddActivityForm {
                    anchors.fill: parent
                    anchors.margins: 16
                }
            }

            // Divider
            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: "#2D3139"
            }

            // Right panel: activity list (or empty state)
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Show list when there are activities
                Views.ActivityListView {
                    anchors.fill: parent
                    visible: activityModel.count > 0
                }

                // Show empty state when list is empty
                Views.EmptyStateView {
                    anchors.centerIn: parent
                    visible: activityModel.count === 0
                }
            }
        }

        // ── Summary bar (bottom strip) ────────────────────────────────────────
        Components.SummaryBar {
            Layout.fillWidth: true
        }
    }

    // ── Error toast ───────────────────────────────────────────────────────────
    Rectangle {
        id: errorBar
        property alias text: errorLabel.text

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 60
        }

        visible: false
        width: errorLabel.implicitWidth + 32
        height: 40
        radius: 6
        color: "#C0392B"

        Text {
            id: errorLabel
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 13
        }

        Timer {
            id: errorTimer
            interval: 3000
            onTriggered: errorBar.visible = false
        }
    }
}

