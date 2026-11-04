// main.qml — Root application window with dual light/dark theme and executive UI
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import ActivityTracker 1.0

import "./views"       as Views
import "./components"  as Components

ApplicationWindow {
    id: root
    visible: true
    width: 1020
    height: 720
    minimumWidth: 840
    minimumHeight: 560
    title: "CVS Activity Tracker"

    // ── Dynamic Material Style Configuration ─────────────────────────────────
    Material.theme:      Theme.isDark ? Material.Dark : Material.Light
    Material.accent:     Theme.accentBlue
    Material.background: Theme.bgCanvas
    color: Theme.bgCanvas

    Behavior on color { ColorAnimation { duration: 200 } }

    // ── Global Filter State ──────────────────────────────────────────────────
    property string activeCategoryFilter: "All"
    property string activeSearchQuery: ""

    // ── Global Shortcuts ─────────────────────────────────────────────────────
    Shortcut {
        sequence: "Ctrl+F"
        onActivated: searchInput.forceActiveFocus()
    }
    Shortcut {
        sequence: "Ctrl+T"
        onActivated: Theme.toggleTheme()
    }

    // ── Error notification banner ─────────────────────────────────────────────
    Connections {
        target: activityService
        function onErrorOccurred(message) {
            errorBar.text = message
            errorBar.visible = true
            errorTimer.restart()
        }
    }

    // ── Main Window Layout ────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Top Navigation / Header Bar ───────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: Theme.surfaceNav
            border.color: Theme.borderDefault
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

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
                            color: Theme.textPrimary
                        }
                        Text {
                            text: "Enterprise Productivity Desk"
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.accentBlue
                            font.letterSpacing: 0.5
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Quick stats pill in header
                Rectangle {
                    radius: 12
                    color: Theme.surfaceBadge
                    border.color: Theme.borderDefault
                    border.width: 1
                    implicitWidth: headerStats.implicitWidth + 20
                    implicitHeight: 28

                    RowLayout {
                        id: headerStats
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: "Today's Logged:"
                            color: Theme.textSecondary
                            font.pixelSize: 12
                        }
                        Text {
                            text: activityService.totalDurationToday + " min"
                            color: Theme.accentBlue
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                }

                // ── Theme Switcher Button (Dark 🌙 / Light ☀️) ─────────────────
                Rectangle {
                    id: themeToggleBtn
                    radius: 14
                    color: themeHover.hovered ? Theme.surfaceCardHover : Theme.surfaceBadge
                    border.color: Theme.borderDefault
                    border.width: 1
                    implicitWidth: 86
                    implicitHeight: 28

                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: Theme.isDark ? "🌙" : "☀️"
                            font.pixelSize: 12
                        }
                        Text {
                            text: Theme.isDark ? "Dark" : "Light"
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.textPrimary
                        }
                    }

                    HoverHandler { id: themeHover }
                    TapHandler {
                        onTapped: Theme.toggleTheme()
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
                Layout.preferredWidth: root.width > 960 ? 320 : 280
                Layout.fillHeight: true
                color: Theme.surfaceSidebar
                border.color: Theme.borderDefault
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Components.AddActivityForm {
                    anchors.fill: parent
                    anchors.margins: 18
                }
            }

            // Right Main: Analytics Cards + Filter Bar + Activity List
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.bgCanvas

                Behavior on color { ColorAnimation { duration: 150 } }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    // ── 1. Top Analytics Stats Cards ──────────────────────────
                    Components.StatsDashboard {
                        Layout.fillWidth: true
                    }

                    // ── 2. Interactive Filter & Search Toolbar ────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        spacing: 10

                        // Category Filter Chips
                        RowLayout {
                            spacing: 6

                            Repeater {
                                model: ["All", "Work", "Learning", "Personal", "Done"]
                                delegate: Rectangle {
                                    id: chip
                                    implicitHeight: 28
                                    implicitWidth: chipLabel.implicitWidth + 18
                                    radius: 14
                                    readonly property bool isSelected: root.activeCategoryFilter === modelData

                                    color: isSelected 
                                           ? Theme.accentBlueBg 
                                           : (chipHover.hovered ? Theme.surfaceCardHover : Theme.surfaceBadge)
                                    border.color: isSelected ? Theme.accentBlue : Theme.borderDefault
                                    border.width: 1

                                    Behavior on color { ColorAnimation { duration: 120 } }

                                    Text {
                                        id: chipLabel
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pixelSize: 12
                                        font.bold: chip.isSelected
                                        color: chip.isSelected ? Theme.accentBlue : Theme.textSecondary
                                    }

                                    HoverHandler { id: chipHover }
                                    TapHandler {
                                        onTapped: root.activeCategoryFilter = modelData
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Live Instant Search Box
                        Rectangle {
                            implicitWidth: 190
                            implicitHeight: 28
                            radius: 14
                            color: Theme.surfaceInput
                            border.color: searchInput.activeFocus ? Theme.borderFocus : Theme.borderDefault
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 4

                                Text {
                                    text: "🔍"
                                    font.pixelSize: 11
                                    color: Theme.textMuted
                                }

                                TextField {
                                    id: searchInput
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    placeholderText: "Search..."
                                    placeholderTextColor: Theme.textMuted
                                    color: Theme.textPrimary
                                    font.pixelSize: 11
                                    background: null
                                    verticalAlignment: TextInput.AlignVCenter
                                    selectByMouse: true
                                    onTextChanged: root.activeSearchQuery = text
                                }

                                Text {
                                    visible: searchInput.text.length > 0
                                    text: "✕"
                                    font.pixelSize: 10
                                    color: Theme.textMuted
                                    TapHandler {
                                        onTapped: searchInput.text = ""
                                    }
                                }
                            }
                        }
                    }

                    // ── 3. Scrollable Activity List & Empty State ─────────────
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Views.ActivityListView {
                            anchors.fill: parent
                            filterCategory: root.activeCategoryFilter
                            filterText: root.activeSearchQuery
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
            bottomMargin: 55
        }

        visible: false
        width: errorLabel.implicitWidth + 36
        height: 40
        radius: 8
        color: Theme.accentRedBg
        border.color: Theme.accentRedBorder
        border.width: 1

        Text {
            id: errorLabel
            anchors.centerIn: parent
            color: Theme.accentRed
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
