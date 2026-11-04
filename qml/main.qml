// main.qml — Root application window with dual light/dark theme, executive auth flow & workstation
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import ActivityTracker 1.0

import "./views"       as Views
import "./views/auth"  as AuthViews
import "./components"  as Components

ApplicationWindow {
    id: root
    visible: true
    width: 1060
    height: 740
    minimumWidth: 860
    minimumHeight: 580
    title: "CVS Activity Tracker"

    // ── Dynamic Material Style Configuration ─────────────────────────────────
    Material.theme:      Theme.isDark ? Material.Dark : Material.Light
    Material.accent:     Theme.accentBlue
    Material.background: Theme.bgCanvas
    color: Theme.bgCanvas

    Behavior on color { ColorAnimation { duration: 200 } }

    // ── Global Filter & Auth State ───────────────────────────────────────────
    property string activeCategoryFilter: "All"
    property string activeSearchQuery: ""
    property string activeAuthScreen: "login" // "login", "signup", "forgot"

    // ── Global Shortcuts ─────────────────────────────────────────────────────
    Shortcut {
        sequence: "Ctrl+F"
        onActivated: {
            if (authService.isLoggedIn && searchInput) searchInput.forceActiveFocus()
        }
    }
    Shortcut {
        sequence: "Ctrl+T"
        onActivated: Theme.toggleTheme()
    }
    Shortcut {
        sequence: "Ctrl+L"
        onActivated: {
            if (authService.isLoggedIn) authService.logout()
        }
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

    // =========================================================================
    // 1. AUTHENTICATION SCREENS (Shown when !authService.isLoggedIn)
    // =========================================================================
    Item {
        id: authContainer
        anchors.fill: parent
        visible: !authService.isLoggedIn

        AuthViews.LoginView {
            anchors.fill: parent
            visible: root.activeAuthScreen === "login"
            onNavigateToSignUp: root.activeAuthScreen = "signup"
            onNavigateToForgotPassword: root.activeAuthScreen = "forgot"
        }

        AuthViews.SignUpView {
            anchors.fill: parent
            visible: root.activeAuthScreen === "signup"
            onNavigateToLogin: root.activeAuthScreen = "login"
        }

        AuthViews.ForgotPasswordView {
            anchors.fill: parent
            visible: root.activeAuthScreen === "forgot"
            onNavigateToLogin: root.activeAuthScreen = "login"
        }
    }

    // =========================================================================
    // 2. MAIN TRACKER WORKSTATION (Shown when authService.isLoggedIn)
    // =========================================================================
    ColumnLayout {
        id: workstationContainer
        anchors.fill: parent
        spacing: 0
        visible: authService.isLoggedIn

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
                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 10
                        color: Theme.accentBlue
                        Components.LucideIcon {
                            anchors.centerIn: parent
                            name: "clock"
                            size: 18
                            color: "#FFFFFF"
                        }
                    }
                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: "CVS Activity Tracker"
                            font.pixelSize: 15
                            font.bold: true
                            color: Theme.textPrimary
                        }
                        RowLayout {
                            spacing: 6
                            Text {
                                text: "Enterprise Workstation"
                                font.pixelSize: 10
                                font.bold: true
                                color: Theme.accentBlue
                                font.letterSpacing: 0.5
                            }
                            Text { text: "•"; color: Theme.textMuted; font.pixelSize: 10 }
                            Text {
                                text: "☁️ Neon PostgreSQL Connected"
                                font.pixelSize: 10
                                font.bold: true
                                color: Theme.accentGreen
                            }
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

                // User Profile Chip
                Rectangle {
                    radius: 14
                    color: Theme.surfaceBadge
                    border.color: Theme.borderDefault
                    border.width: 1
                    implicitWidth: userRow.implicitWidth + 20
                    implicitHeight: 28

                    RowLayout {
                        id: userRow
                        anchors.centerIn: parent
                        spacing: 6
                        Components.LucideIcon {
                            Layout.alignment: Qt.AlignVCenter
                            name: "user"
                            size: 12
                            color: Theme.accentBlue
                        }
                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: authService.currentUserName.length > 0 ? authService.currentUserName : "User"
                            color: Theme.textPrimary
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                }

                // ── Theme Switcher Button (Dark / Light) ─────────────────────
                Rectangle {
                    id: themeToggleBtn
                    radius: 14
                    color: themeHover.hovered ? Theme.surfaceCardHover : Theme.surfaceBadge
                    border.color: Theme.borderDefault
                    border.width: 1
                    implicitWidth: 84
                    implicitHeight: 28

                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Components.LucideIcon {
                            Layout.alignment: Qt.AlignVCenter
                            name: Theme.isDark ? "moon" : "sun"
                            size: 12
                            color: Theme.accentAmber
                        }
                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: Theme.isDark ? "Dark" : "Light"
                            font.pixelSize: 11
                            font.bold: true
                            color: Theme.textPrimary
                        }
                    }

                    HoverHandler { id: themeHover }
                    TapHandler {
                        onTapped: Theme.toggleTheme()
                    }
                }

                // Sign Out Button
                Rectangle {
                    id: logoutBtn
                    radius: 14
                    color: logoutHover.hovered ? Theme.accentRedBg : Theme.surfaceBadge
                    border.color: logoutHover.hovered ? Theme.accentRedBorder : Theme.borderDefault
                    border.width: 1
                    implicitWidth: 32
                    implicitHeight: 28

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Components.LucideIcon {
                        anchors.centerIn: parent
                        name: "log-out"
                        size: 13
                        color: logoutHover.hovered ? Theme.accentRed : Theme.textMuted
                    }

                    ToolTip.visible: logoutHover.hovered
                    ToolTip.text: "Sign Out (Ctrl+L)"
                    ToolTip.delay: 300

                    HoverHandler { id: logoutHover }
                    TapHandler {
                        onTapped: authService.logout()
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

                        // Live Instant Search Box (Zero-Overlay Desktop Input)
                        Rectangle {
                            implicitWidth: 220
                            implicitHeight: 32
                            radius: 8
                            color: searchInput.activeFocus ? (Theme.isDark ? "#121A28" : "#F8FAFC") : Theme.surfaceInput
                            border.color: searchInput.activeFocus ? Theme.accentBlue : Theme.borderDefault
                            border.width: searchInput.activeFocus ? 2 : 1

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 8
                                spacing: 6

                                Components.LucideIcon {
                                    name: "search"
                                    size: 13
                                    color: Theme.textSecondary
                                    opacity: searchInput.activeFocus ? 1.0 : 0.6
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "Search activities... (Ctrl+F)"
                                        color: Theme.textMuted
                                        font.pixelSize: 12
                                        visible: searchInput.text.length === 0
                                        opacity: searchInput.activeFocus ? 0.35 : 0.75
                                        Behavior on opacity { NumberAnimation { duration: 120 } }
                                    }

                                    TextField {
                                        id: searchInput
                                        anchors.fill: parent
                                        verticalAlignment: TextInput.AlignVCenter
                                        color: Theme.textPrimary
                                        font.pixelSize: 12
                                        background: null
                                        placeholderText: ""
                                        selectByMouse: true
                                        onTextChanged: root.activeSearchQuery = text
                                    }
                                }

                                Rectangle {
                                    visible: searchInput.text.length > 0
                                    implicitWidth: 18
                                    implicitHeight: 18
                                    radius: 9
                                    color: searchClearHover.hovered ? Theme.surfaceCardHover : "transparent"

                                    Components.LucideIcon {
                                        anchors.centerIn: parent
                                        name: "x"
                                        size: 10
                                        color: Theme.textMuted
                                    }

                                    HoverHandler { id: searchClearHover }
                                    TapHandler {
                                        onTapped: {
                                            searchInput.text = ""
                                            searchInput.forceActiveFocus()
                                        }
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
                            id: mainListView
                            anchors.fill: parent
                            filterCategory: root.activeCategoryFilter
                            filterText: root.activeSearchQuery
                            visible: activityModel.count > 0
                        }

                        // Empty State View
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
