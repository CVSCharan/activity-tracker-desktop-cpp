// main.qml — Root application window with dual light/dark theme, executive auth flow & workstation
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCore
import ActivityTracker 1.0

import "./views"       as Views
import "./views/auth"  as AuthViews
import "./components"  as Components

ApplicationWindow {
    id: root
    visible: true
    width: appSettings.width
    height: appSettings.height
    minimumWidth: 880
    minimumHeight: 600
    title: "CVS Activity Tracker — Executive Workstation"

    // ── Persistent Window Geometry & Executive User Preferences ───────────────
    Settings {
        id: appSettings
        category: "WorkstationPreferences"
        property int x: -1
        property int y: -1
        property int width: 1080
        property int height: 740
        property bool isMaximized: false
        property string sidebarDock: "left"       // "left" or "right"
        property bool sidebarCollapsed: false     // true = 56px compact rail, false = full deck
        property string activeTimeframe: "Today"  // "Today", "Last 7 Days", "Last 30 Days", "All Time"
    }

    Component.onCompleted: {
        if (appSettings.x >= 0 && appSettings.y >= 0) {
            root.x = appSettings.x
            root.y = appSettings.y
        }
        if (appSettings.isMaximized) {
            root.showMaximized()
        }
    }

    onClosing: {
        appSettings.isMaximized = (root.visibility === Window.Maximized)
        if (root.visibility !== Window.Maximized) {
            appSettings.x = root.x
            appSettings.y = root.y
            appSettings.width = root.width
            appSettings.height = root.height
        }
        appSettings.sidebarDock = root.sidebarDock
        appSettings.sidebarCollapsed = root.sidebarCollapsed
        appSettings.activeTimeframe = root.activeTimeframe
    }

    // ── Dynamic Material Style Configuration ─────────────────────────────────
    Material.theme:      Theme.isDark ? Material.Dark : Material.Light
    Material.accent:     Theme.accentBlue
    Material.background: Theme.bgCanvas
    color: Theme.bgCanvas

    Behavior on color { ColorAnimation { duration: 200 } }

    // ── Global Filter & Workstation State ────────────────────────────────────
    property string activeCategoryFilter: "All"
    property string activeSearchQuery: ""
    property string activeTimeframe: appSettings.activeTimeframe
    property string activeAuthScreen: "login" // "login", "signup", "forgot"
    property string sidebarDock: appSettings.sidebarDock
    property bool   sidebarCollapsed: appSettings.sidebarCollapsed

    // ── Global Shortcuts Matrix ──────────────────────────────────────────────
    Shortcut {
        sequence: "Ctrl+B"
        onActivated: {
            root.sidebarCollapsed = !root.sidebarCollapsed
            appSettings.sidebarCollapsed = root.sidebarCollapsed
        }
    }
    Shortcut {
        sequence: "Ctrl+D"
        onActivated: {
            root.sidebarDock = (root.sidebarDock === "left" ? "right" : "left")
            appSettings.sidebarDock = root.sidebarDock
        }
    }
    Shortcut {
        sequence: "Ctrl+F"
        onActivated: {
            if (authService.isLoggedIn && taskSearchField) {
                taskSearchField.forceActiveFocus()
            }
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

    // Reference to search input for shortcut focusing
    property var taskSearchField: null

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
    // 1. DYNAMIC LAZY LOADER FOR AUTH SCREENS
    // =========================================================================
    // Unloads completely from memory when user logs in
    Loader {
        id: authLoader
        anchors.fill: parent
        visible: !authService.isLoggedIn
        active: !authService.isLoggedIn

        sourceComponent: {
            if (authService.isLoggedIn) return null
            switch (root.activeAuthScreen) {
            case "signup": return signupComponent
            case "forgot": return forgotComponent
            default:       return loginComponent
            }
        }
    }

    Component {
        id: loginComponent
        AuthViews.LoginView {
            onNavigateToSignUp: root.activeAuthScreen = "signup"
            onNavigateToForgotPassword: root.activeAuthScreen = "forgot"
        }
    }

    Component {
        id: signupComponent
        AuthViews.SignUpView {
            onNavigateToLogin: root.activeAuthScreen = "login"
        }
    }

    Component {
        id: forgotComponent
        AuthViews.ForgotPasswordView {
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
                spacing: 12

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

                Item { Layout.preferredWidth: 12 }

                // ── Timeframe Scope Dropdown Selector ─────────────────────────
                Rectangle {
                    id: timeframeBtn
                    implicitHeight: 32
                    implicitWidth: tfRow.implicitWidth + 24
                    radius: 8
                    color: tfHover.hovered ? Theme.surfaceCardHover : Theme.surfaceBadge
                    border.color: tfMenu.visible ? Theme.accentBlue : Theme.borderDefault
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        id: tfRow
                        anchors.centerIn: parent
                        spacing: 6

                        Components.LucideIcon {
                            Layout.alignment: Qt.AlignVCenter
                            name: "clock"
                            size: 13
                            color: Theme.accentBlue
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: root.activeTimeframe
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.textPrimary
                        }

                        Components.LucideIcon {
                            Layout.alignment: Qt.AlignVCenter
                            name: "arrow-up-down"
                            size: 10
                            color: Theme.textMuted
                        }
                    }

                    ToolTip.visible: tfHover.hovered
                    ToolTip.text: "Filter query timeframe"
                    ToolTip.delay: 300

                    HoverHandler { id: tfHover }
                    TapHandler {
                        onTapped: tfMenu.open()
                    }

                    Menu {
                        id: tfMenu
                        y: timeframeBtn.height + 4
                        Action {
                            text: "Today"
                            onTriggered: {
                                root.activeTimeframe = "Today"
                                appSettings.activeTimeframe = "Today"
                            }
                        }
                        Action {
                            text: "Last 7 Days"
                            onTriggered: {
                                root.activeTimeframe = "Last 7 Days"
                                appSettings.activeTimeframe = "Last 7 Days"
                            }
                        }
                        Action {
                            text: "Last 30 Days"
                            onTriggered: {
                                root.activeTimeframe = "Last 30 Days"
                                appSettings.activeTimeframe = "Last 30 Days"
                            }
                        }
                        Action {
                            text: "All Time"
                            onTriggered: {
                                root.activeTimeframe = "All Time"
                                appSettings.activeTimeframe = "All Time"
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // ── Sidebar Dock & Collapse Controls ──────────────────────────
                RowLayout {
                    spacing: 6

                    // Toggle Sidebar Collapse Button (Ctrl+B)
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 28
                        radius: 6
                        color: toggleSidebarHover.hovered ? Theme.surfaceCardHover : Theme.surfaceBadge
                        border.color: Theme.borderDefault
                        border.width: 1

                        Components.LucideIcon {
                            anchors.centerIn: parent
                            name: root.sidebarDock === "left" ? "panel-left" : "panel-right"
                            size: 14
                            color: root.sidebarCollapsed ? Theme.textMuted : Theme.accentBlue
                        }

                        ToolTip.visible: toggleSidebarHover.hovered
                        ToolTip.text: root.sidebarCollapsed ? "Expand Sidebar (Ctrl+B)" : "Collapse Sidebar (Ctrl+B)"
                        ToolTip.delay: 300

                        HoverHandler { id: toggleSidebarHover }
                        TapHandler {
                            onTapped: {
                                root.sidebarCollapsed = !root.sidebarCollapsed
                                appSettings.sidebarCollapsed = root.sidebarCollapsed
                            }
                        }
                    }

                    // Switch Dock Side Button (Ctrl+D)
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 28
                        radius: 6
                        color: dockSwitchHover.hovered ? Theme.surfaceCardHover : Theme.surfaceBadge
                        border.color: Theme.borderDefault
                        border.width: 1

                        Components.LucideIcon {
                            anchors.centerIn: parent
                            name: "arrow-up-down"
                            size: 13
                            color: Theme.textSecondary
                        }

                        ToolTip.visible: dockSwitchHover.hovered
                        ToolTip.text: "Dock Sidebar to " + (root.sidebarDock === "left" ? "Right" : "Left") + " (Ctrl+D)"
                        ToolTip.delay: 300

                        HoverHandler { id: dockSwitchHover }
                        TapHandler {
                            onTapped: {
                                root.sidebarDock = (root.sidebarDock === "left" ? "right" : "left")
                                appSettings.sidebarDock = root.sidebarDock
                            }
                        }
                    }
                }

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
                            text: root.activeTimeframe === "Today" ? "Today's Log:" : (root.activeTimeframe + ":")
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

        // ── Center Content Area: Floating Dockable Sidebar + Workspace ────────
        GridLayout {
            id: workstationBody
            Layout.fillWidth: true
            Layout.fillHeight: true
            rows: 1
            columns: 2
            columnSpacing: 0
            rowSpacing: 0

            // ── Sidebar Deck (Dockable Left or Right, Expandable/Collapsible) ──
            Rectangle {
                id: sidebarContainer
                Layout.column: root.sidebarDock === "left" ? 0 : 1
                Layout.row: 0
                Layout.fillHeight: true
                Layout.preferredWidth: root.sidebarCollapsed ? 56 : (root.width > 960 ? 320 : 280)
                clip: true

                color: Theme.surfaceSidebar
                border.color: Theme.borderDefault
                border.width: 1

                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                }
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                // Full Form View (Shown when expanded)
                Item {
                    anchors.fill: parent
                    visible: !root.sidebarCollapsed
                    opacity: root.sidebarCollapsed ? 0.0 : 1.0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        // Sidebar Header with Mini Dock Controls
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Components.LucideIcon {
                                Layout.alignment: Qt.AlignVCenter
                                name: "plus"
                                size: 14
                                color: Theme.accentBlue
                            }

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: "Add New Activity"
                                font.pixelSize: 14
                                font.bold: true
                                color: Theme.textPrimary
                            }

                            Item { Layout.fillWidth: true }

                            // Quick Dock Side Toggle
                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: 24
                                implicitHeight: 24
                                radius: 4
                                color: sidebarDockMiniHover.hovered ? Theme.surfaceCardHover : "transparent"

                                Components.LucideIcon {
                                    anchors.centerIn: parent
                                    name: "arrow-up-down"
                                    size: 11
                                    color: Theme.textMuted
                                }

                                ToolTip.visible: sidebarDockMiniHover.hovered
                                ToolTip.text: "Dock to " + (root.sidebarDock === "left" ? "Right" : "Left")
                                ToolTip.delay: 300

                                HoverHandler { id: sidebarDockMiniHover }
                                TapHandler {
                                    onTapped: {
                                        root.sidebarDock = (root.sidebarDock === "left" ? "right" : "left")
                                        appSettings.sidebarDock = root.sidebarDock
                                    }
                                }
                            }

                            // Quick Collapse Button
                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: 24
                                implicitHeight: 24
                                radius: 4
                                color: sidebarCollapseMiniHover.hovered ? Theme.surfaceCardHover : "transparent"

                                Components.LucideIcon {
                                    anchors.centerIn: parent
                                    name: root.sidebarDock === "left" ? "panel-left" : "panel-right"
                                    size: 12
                                    color: Theme.textMuted
                                }

                                ToolTip.visible: sidebarCollapseMiniHover.hovered
                                ToolTip.text: "Collapse Sidebar"
                                ToolTip.delay: 300

                                HoverHandler { id: sidebarCollapseMiniHover }
                                TapHandler {
                                    onTapped: {
                                        root.sidebarCollapsed = true
                                        appSettings.sidebarCollapsed = true
                                    }
                                }
                            }
                        }

                        // Embedded Form
                        Components.AddActivityForm {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }

                // Compact Icon Rail (Shown when collapsed)
                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 16
                    anchors.bottomMargin: 16
                    visible: root.sidebarCollapsed
                    opacity: root.sidebarCollapsed ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    spacing: 16

                    // Expand Action Button
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 38
                        implicitHeight: 38
                        radius: 8
                        color: railExpandHover.hovered ? Theme.accentBlueBg : Theme.surfaceBadge
                        border.color: railExpandHover.hovered ? Theme.accentBlue : Theme.borderDefault
                        border.width: 1

                        Components.LucideIcon {
                            anchors.centerIn: parent
                            name: "plus"
                            size: 16
                            color: Theme.accentBlue
                        }

                        ToolTip.visible: railExpandHover.hovered
                        ToolTip.text: "Expand Sidebar (Ctrl+B)"
                        ToolTip.delay: 300

                        HoverHandler { id: railExpandHover }
                        TapHandler {
                            onTapped: {
                                root.sidebarCollapsed = false
                                appSettings.sidebarCollapsed = false
                            }
                        }
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 28
                        implicitHeight: 1
                        color: Theme.borderDefault
                    }

                    // Category Counter Badges in Rail
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12

                        // Work icon badge
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 32
                            implicitHeight: 32
                            radius: 16
                            color: Theme.accentBlueBg
                            border.color: Theme.accentBlueBorder
                            border.width: 1

                            Components.LucideIcon {
                                anchors.centerIn: parent
                                name: "briefcase"
                                size: 13
                                color: Theme.accentBlue
                            }

                            ToolTip.visible: railWorkHover.hovered
                            ToolTip.text: "Filter Work Activities"
                            ToolTip.delay: 300

                            HoverHandler { id: railWorkHover }
                            TapHandler {
                                onTapped: {
                                    root.activeCategoryFilter = "Work"
                                }
                            }
                        }

                        // Learning icon badge
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 32
                            implicitHeight: 32
                            radius: 16
                            color: Theme.accentAmberBg
                            border.color: Theme.accentAmberBorder
                            border.width: 1

                            Components.LucideIcon {
                                anchors.centerIn: parent
                                name: "book-open"
                                size: 13
                                color: Theme.accentAmber
                            }

                            ToolTip.visible: railLearnHover.hovered
                            ToolTip.text: "Filter Learning Activities"
                            ToolTip.delay: 300

                            HoverHandler { id: railLearnHover }
                            TapHandler {
                                onTapped: {
                                    root.activeCategoryFilter = "Learning"
                                }
                            }
                        }

                        // Personal icon badge
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 32
                            implicitHeight: 32
                            radius: 16
                            color: Theme.accentGreenBg
                            border.color: Theme.accentGreenBorder
                            border.width: 1

                            Components.LucideIcon {
                                anchors.centerIn: parent
                                name: "user"
                                size: 13
                                color: Theme.accentGreen
                            }

                            ToolTip.visible: railPersHover.hovered
                            ToolTip.text: "Filter Personal Activities"
                            ToolTip.delay: 300

                            HoverHandler { id: railPersHover }
                            TapHandler {
                                onTapped: {
                                    root.activeCategoryFilter = "Personal"
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Dock Switcher at bottom of rail
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 6
                        color: railDockHover.hovered ? Theme.surfaceCardHover : "transparent"

                        Components.LucideIcon {
                            anchors.centerIn: parent
                            name: "arrow-up-down"
                            size: 13
                            color: Theme.textMuted
                        }

                        ToolTip.visible: railDockHover.hovered
                        ToolTip.text: "Dock to " + (root.sidebarDock === "left" ? "Right" : "Left")
                        ToolTip.delay: 300

                        HoverHandler { id: railDockHover }
                        TapHandler {
                            onTapped: {
                                root.sidebarDock = (root.sidebarDock === "left" ? "right" : "left")
                                appSettings.sidebarDock = root.sidebarDock
                            }
                        }
                    }
                }
            }

            // ── Main Workspace Area (Cards + Toolbar + List) ──────────────────
            Rectangle {
                id: mainWorkspaceArea
                Layout.column: root.sidebarDock === "left" ? 1 : 0
                Layout.row: 0
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
                        timeframe: root.activeTimeframe
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
                                    Layout.alignment: Qt.AlignVCenter
                                    name: "search"
                                    size: 13
                                    color: Theme.textSecondary
                                    opacity: searchInput.activeFocus ? 1.0 : 0.6
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignVCenter

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
                                        Component.onCompleted: root.taskSearchField = searchInput
                                        onTextChanged: root.activeSearchQuery = text
                                    }
                                }

                                Rectangle {
                                    Layout.alignment: Qt.AlignVCenter
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
                            filterTimeframe: root.activeTimeframe
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
