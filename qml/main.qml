// main.qml — Root application window

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

import "./views"       as Views
import "./components"  as Components

ApplicationWindow {
    id: root
    visible: true
    width: 960
    height: 700
    minimumWidth: 720
    minimumHeight: 520
    title: "Activity Tracker — C++ / Qt Quick"

    // ── Dark theme configuration ─────────────────────────────────────────────
    Material.theme:      Material.Dark
    Material.accent:     "#58A6FF"
    Material.background: "#0D1117"
    color: "#0D1117"

    // ── Error notification banner ─────────────────────────────────────────────
    Connections {
        target: activityService
        function onErrorOccurred(message) {
            errorBar.text = message
            errorBar.visible = true
            errorTimer.restart()
        }
    }

    // ── Main Layout ───────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Top Navigation / Header Bar ───────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: "#161B22"
            border.color: "#30363D"
            border.width: 1

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 20
                    rightMargin: 20
                }

                // App Title & Icon
                RowLayout {
                    spacing: 10
                    Text {
                        text: "📋"
                        font.pixelSize: 22
                    }
                    Text {
                        text: "Activity Tracker"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#F0F6FC"
                    }
                }

                Item { Layout.fillWidth: true }

                // Quick stats pill in header
                Rectangle {
                    radius: 12
                    color: "#21262D"
                    border.color: "#30363D"
                    border.width: 1
                    implicitWidth: headerStats.implicitWidth + 20
                    implicitHeight: 28

                    RowLayout {
                        id: headerStats
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: "Today's Logged:"
                            color: "#8B949E"
                            font.pixelSize: 12
                        }
                        Text {
                            text: activityService.totalDurationToday + " min"
                            color: "#58A6FF"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        // ── Center Content Area ───────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Left Sidebar: Form
            Rectangle {
                width: 300
                Layout.fillHeight: true
                color: "#161B22"
                border.color: "#30363D"
                border.width: 1

                Components.AddActivityForm {
                    anchors.fill: parent
                    anchors.margins: 18
                }
            }

            // Right Main: Activity Cards List
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#0D1117"

                Views.ActivityListView {
                    anchors.fill: parent
                    visible: activityModel.count > 0
                }

                Views.EmptyStateView {
                    anchors.centerIn: parent
                    visible: activityModel.count === 0
                }
            }
        }

        // ── Bottom Summary Bar ────────────────────────────────────────────────
        Components.SummaryBar {
            Layout.fillWidth: true
        }
    }

    // ── Floating Error Toast ──────────────────────────────────────────────────
    Rectangle {
        id: errorBar
        property alias text: errorLabel.text

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 60
        }

        visible: false
        width: errorLabel.implicitWidth + 36
        height: 42
        radius: 8
        color: "#DA3633"
        border.color: "#F85149"
        border.width: 1

        Text {
            id: errorLabel
            anchors.centerIn: parent
            color: "#FFFFFF"
            font.pixelSize: 13
            font.bold: true
        }

        Timer {
            id: errorTimer
            interval: 3500
            onTriggered: errorBar.visible = false
        }
    }
}
