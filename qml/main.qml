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
    title: "CVS Activity Tracker"

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
            Layout.preferredHeight: 60
            color: "#161B22"
            border.color: "#30363D"
            border.width: 1

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 20
                    rightMargin: 20
                }

                // Brand Logo & Title
                RowLayout {
                    spacing: 12
                    Image {
                        source: "qrc:/qt/qml/ActivityTracker/resources/icons/app_icon.svg"
                        sourceSize.width: 34
                        sourceSize.height: 34
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        smooth: true
                        mipmap: true
                    }
                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: "CVS Activity Tracker"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#F0F6FC"
                        }
                        Text {
                            text: "Enterprise Productivity Desk"
                            font.pixelSize: 10
                            font.bold: true
                            color: "#58A6FF"
                            font.letterSpacing: 0.5
                        }
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
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                color: "#161B22"
                border.color: "#30363D"
                border.width: 1

                Components.AddActivityForm {
                    anchors.fill: parent
                    anchors.margins: 18
                }
            }

            // Right Main: Analytics Cards + Activity List
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#0D1117"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16

                    // ── 1. Top Analytics Stats Cards ──────────────────────────
                    Components.StatsDashboard {
                        Layout.fillWidth: true
                    }

                    // ── 2. List Header ────────────────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        spacing: 8

                        Text {
                            text: "Activity Feed"
                            font.pixelSize: 15
                            font.bold: true
                            color: "#F0F6FC"
                        }

                        Rectangle {
                            radius: 8
                            color: "#21262D"
                            border.color: "#30363D"
                            border.width: 1
                            implicitWidth: feedCount.implicitWidth + 12
                            implicitHeight: 20

                            Text {
                                id: feedCount
                                anchors.centerIn: parent
                                text: activityModel.count + " logged"
                                font.pixelSize: 11
                                font.bold: true
                                color: "#8B949E"
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "● Local Engine Active"
                            font.pixelSize: 11
                            color: "#3FB950"
                        }
                    }

                    // ── 3. Scrollable Activity List ───────────────────────────
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

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
