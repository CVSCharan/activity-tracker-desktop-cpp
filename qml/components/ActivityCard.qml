// ActivityCard.qml — high-contrast modern activity card with light/dark theme support
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import ActivityTracker 1.0

Rectangle {
    id: card

    // Required properties match the exact C++ ActivityListModel roleNames
    required property string name
    required property string category
    required property int    durationMinutes
    required property bool   done
    required property int    index
    property string status: "Created"
    property var createdAt: null

    readonly property string activeStatus: (typeof card.status !== "undefined" && card.status && card.status.length > 0)
                                           ? card.status
                                           : (card.done ? "Done" : "Created")

    signal removeRequested()
    signal completeRequested()
    signal reopenRequested()
    signal statusChangeRequested(string newStatus)
    signal extendRequested(int additionalMinutes)
    signal createExtensionRequested(int minutes)

    height: 76
    radius: 10
    color: card.done 
           ? (Theme.isDark ? "#0E1C14" : "#F0FDF4")
           : (card.activeStatus === "In Progress"
              ? (cardHover.hovered ? (Theme.isDark ? "#172338" : "#EFF6FF") : (Theme.isDark ? "#131B2A" : "#F8FAFC"))
              : (cardHover.hovered ? Theme.surfaceCardHover : Theme.surfaceCard))

    border.color: card.done 
                  ? Theme.accentGreenBorder
                  : (card.activeStatus === "In Progress"
                     ? (cardHover.hovered ? Theme.accentBlue : (Theme.isDark ? "#1E3A5F" : "#BFDBFE"))
                     : (cardHover.hovered ? Theme.accentBlue : Theme.borderDefault))
    border.width: 1

    // ── Smooth Hover Lift Animation (like Framer Motion's whileHover) ────────
    y: cardHover.hovered ? -1.5 : 0
    Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    HoverHandler { id: cardHover }

    // Helper: Formats historical timestamps into human-readable labels
    function formatHistoryDate(created) {
        if (!created) return "Today"
        const date = new Date(created)
        if (isNaN(date.getTime())) return "Today"
        const now = new Date()
        const diffMs = now - date
        const diffDays = Math.floor(diffMs / (86400 * 1000))

        if (date.toDateString() === now.toDateString()) {
            const h = date.getHours()
            const m = date.getMinutes()
            const ampm = h >= 12 ? 'PM' : 'AM'
            const h12 = h % 12 || 12
            return "Today, " + h12 + ":" + (m < 10 ? '0' + m : m) + " " + ampm
        } else if (diffDays === 1) {
            return "Yesterday"
        } else if (diffDays < 7) {
            const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            return days[date.getDay()]
        } else {
            const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            return months[date.getMonth()] + " " + date.getDate()
        }
    }

    // Left accent category strip
    Rectangle {
        id: accentStrip
        width: 4
        height: card.height - 20
        radius: 2
        anchors.left: card.left
        anchors.leftMargin: 8
        anchors.verticalCenter: card.verticalCenter
        color: {
            if (card.done) return Theme.accentGreen;
            switch (card.category) {
            case "Work":     return Theme.accentBlue;
            case "Learning": return Theme.accentAmber;
            case "Personal": return Theme.accentGreen;
            default:         return Theme.textSecondary;
            }
        }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 20
            rightMargin: 16
            topMargin: 8
            bottomMargin: 8
        }
        spacing: 12

        // ── Done / Toggle checkbox ────────────────────────────────────────────
        CheckBox {
            id: doneBox
            Layout.alignment: Qt.AlignVCenter
            checked: card.done
            enabled: true
            Material.accent: Theme.accentGreen

            ToolTip.visible: hovered
            ToolTip.text: card.done ? "Click to Reopen Task" : "Mark as Completed"
            ToolTip.delay: 350

            onClicked: {
                if (card.done) {
                    card.reopenRequested()
                } else {
                    card.completeRequested()
                }
            }
        }

        // ── Title + Metadata badges ───────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            // Activity Name
            Text {
                Layout.fillWidth: true
                text: card.name && card.name.length > 0 ? card.name : "(Untitled Activity)"
                color: card.done ? Theme.textMuted : Theme.textPrimary
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight
                font.strikeout: card.done
            }

            // Badges row: Category pill + Duration pill
            RowLayout {
                spacing: 8

                // Category pill
                Rectangle {
                    radius: 10
                    implicitWidth: catRow.implicitWidth + 16
                    implicitHeight: 22
                    color: {
                        if (card.done) return Theme.accentGreenBg;
                        switch (card.category) {
                        case "Work":     return Theme.accentBlueBg;
                        case "Learning": return Theme.accentAmberBg;
                        case "Personal": return Theme.accentGreenBg;
                        default:         return Theme.surfaceBadge;
                        }
                    }
                    border.color: {
                        if (card.done) return Theme.accentGreenBorder;
                        switch (card.category) {
                        case "Work":     return Theme.accentBlueBorder;
                        case "Learning": return Theme.accentAmberBorder;
                        case "Personal": return Theme.accentGreenBorder;
                        default:         return Theme.borderDefault;
                        }
                    }
                    border.width: 1

                    Row {
                        id: catRow
                        anchors.centerIn: parent
                        spacing: 5

                        LucideIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: {
                                switch (card.category) {
                                case "Work":     return "briefcase";
                                case "Learning": return "book-open";
                                case "Personal": return "user";
                                default:         return "list-todo";
                                }
                            }
                            size: 12
                            color: {
                                if (card.done) return Theme.accentGreen;
                                switch (card.category) {
                                case "Work":     return Theme.accentBlue;
                                case "Learning": return Theme.accentAmber;
                                case "Personal": return Theme.accentGreen;
                                default:         return Theme.textSecondary;
                                }
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: card.category && card.category.length > 0 ? card.category : "General"
                            font.pixelSize: 11
                            font.bold: true
                            color: {
                                if (card.done) return Theme.accentGreen;
                                switch (card.category) {
                                case "Work":     return Theme.accentBlue;
                                case "Learning": return Theme.accentAmber;
                                case "Personal": return Theme.accentGreen;
                                default:         return Theme.textSecondary;
                                }
                            }
                        }
                    }
                }

                // Duration pill
                Rectangle {
                    radius: 10
                    implicitWidth: durRow.implicitWidth + 14
                    implicitHeight: 22
                    color: Theme.surfaceBadge
                    border.color: Theme.borderDefault
                    border.width: 1

                    Row {
                        id: durRow
                        anchors.centerIn: parent
                        spacing: 4

                        LucideIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: "clock"
                            size: 12
                            color: Theme.textSecondary
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: card.durationMinutes + " min"
                            font.pixelSize: 11
                            color: Theme.textSecondary
                            font.bold: true
                        }
                    }
                }

                // History Date Pill (shows exact historical timeframe: Today, Yesterday, Oct 24)
                Rectangle {
                    radius: 10
                    implicitWidth: historyRow.implicitWidth + 14
                    implicitHeight: 22
                    color: Theme.surfaceBadge
                    border.color: Theme.borderDefault
                    border.width: 1

                    Row {
                        id: historyRow
                        anchors.centerIn: parent
                        spacing: 4

                        LucideIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: "clock"
                            size: 10
                            color: Theme.textMuted
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: card.formatHistoryDate(card.createdAt)
                            font.pixelSize: 10
                            color: Theme.textMuted
                            font.bold: false
                        }
                    }
                }

                // Status pill (Interactive Lifecycle Badge: Todo / In Progress / Done)
                Rectangle {
                    id: statusBadge
                    radius: 10
                    implicitWidth: statusRow.implicitWidth + 16
                    implicitHeight: 22
                    color: {
                        if (card.done || card.activeStatus === "Done") return Theme.accentGreenBg;
                        if (card.activeStatus === "In Progress") return Theme.accentBlueBg;
                        return Theme.surfaceBadge;
                    }
                    border.color: {
                        if (card.done || card.activeStatus === "Done") return Theme.accentGreenBorder;
                        if (card.activeStatus === "In Progress") return Theme.accentBlueBorder;
                        return Theme.borderDefault;
                    }
                    border.width: 1

                    scale: statusBadgeHover.hovered ? 1.05 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120 } }
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Row {
                        id: statusRow
                        anchors.centerIn: parent
                        spacing: 4

                        LucideIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: {
                                if (card.done || card.activeStatus === "Done") return "check";
                                if (card.activeStatus === "In Progress") return "zap";
                                return "list-todo";
                            }
                            size: 11
                            color: {
                                if (card.done || card.activeStatus === "Done") return Theme.accentGreen;
                                if (card.activeStatus === "In Progress") return Theme.accentBlue;
                                return Theme.textSecondary;
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: {
                                if (card.done || card.activeStatus === "Done") return "Done ▾";
                                if (card.activeStatus === "In Progress") return "In Progress ▾";
                                return "Todo ▾";
                            }
                            font.pixelSize: 10
                            font.bold: true
                            color: {
                                if (card.done || card.activeStatus === "Done") return Theme.accentGreen;
                                if (card.activeStatus === "In Progress") return Theme.accentBlue;
                                return Theme.textSecondary;
                            }
                        }
                    }

                    HoverHandler { id: statusBadgeHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        onTapped: statusMenu.open()
                    }

                    ToolTip.visible: statusBadgeHover.hovered
                    ToolTip.text: "Click to change lifecycle status"
                    ToolTip.delay: 300

                    Menu {
                        id: statusMenu
                        y: statusBadge.height + 4

                        Action {
                            text: "📌  Todo / Created"
                            enabled: card.activeStatus !== "Created"
                            onTriggered: card.statusChangeRequested("Created")
                        }
                        Action {
                            text: "⚡  In Progress"
                            enabled: card.activeStatus !== "In Progress"
                            onTriggered: card.statusChangeRequested("In Progress")
                        }
                        Action {
                            text: "✓  Completed / Done"
                            enabled: !card.done
                            onTriggered: card.completeRequested()
                        }
                        MenuSeparator {}
                        Action {
                            text: "⏱  Extend Duration (+15m)"
                            onTriggered: card.extendRequested(15)
                        }
                        Action {
                            text: "✨  Create Extension Task (+15m)"
                            onTriggered: card.createExtensionRequested(15)
                        }
                    }
                }
            }
        }

        // ── Right Actions Deck (Reopen, +15m / Extension, Delete) ─────────────
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            // Reopen Action Button (Visible when completed)
            Rectangle {
                id: reopenBtn
                visible: card.done
                implicitWidth: 32
                implicitHeight: 32
                radius: 8
                color: reopenHover.hovered ? (Theme.isDark ? "#10281E" : "#DCFCE7") : "transparent"
                border.color: reopenHover.hovered ? Theme.accentGreen : "transparent"
                border.width: 1

                scale: reopenHover.hovered ? 1.1 : 1.0
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                LucideIcon {
                    anchors.centerIn: parent
                    name: "rotate-ccw"
                    size: 14
                    color: Theme.accentGreen
                }

                ToolTip.visible: reopenHover.hovered
                ToolTip.text: "Reopen Activity (to In Progress)"
                ToolTip.delay: 300

                HoverHandler { id: reopenHover }
                TapHandler {
                    onTapped: card.reopenRequested()
                }
            }

            // Quick Extension Action (+15m or Follow-up)
            Rectangle {
                id: extBtn
                implicitWidth: card.done ? 32 : 46
                implicitHeight: 32
                radius: 8
                color: extHover.hovered 
                       ? (card.done ? (Theme.isDark ? "#2A1838" : "#F3E8FF") : (Theme.isDark ? "#17263C" : "#EFF6FF"))
                       : (cardHover.hovered ? (Theme.isDark ? "#1B2230" : "#F1F5F9") : "transparent")
                border.color: extHover.hovered 
                              ? (card.done ? Theme.accentPurple : Theme.accentBlue) 
                              : (cardHover.hovered ? Theme.borderDefault : "transparent")
                border.width: 1

                scale: extHover.hovered ? 1.08 : 1.0
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                Row {
                    anchors.centerIn: parent
                    spacing: 3
                    LucideIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: card.done ? "sparkles" : "plus"
                        size: 13
                        color: card.done ? Theme.accentPurple : Theme.accentBlue
                    }
                    Text {
                        visible: !card.done
                        anchors.verticalCenter: parent.verticalCenter
                        text: "15m"
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.accentBlue
                    }
                }

                ToolTip.visible: extHover.hovered
                ToolTip.text: card.done ? "Create Follow-up Extension Task (+15m)" : "Extend Duration (+15 min)"
                ToolTip.delay: 300

                HoverHandler { id: extHover }
                TapHandler {
                    onTapped: {
                        if (card.done) {
                            card.createExtensionRequested(15)
                        } else {
                            card.extendRequested(15)
                        }
                    }
                }
            }

            // Delete Button (Always Red with Framer-like Hover Spring & Rotation)
            Rectangle {
                id: delBtn
                implicitWidth: 32
                implicitHeight: 32
                radius: 8
                color: delHover.hovered 
                       ? (Theme.isDark ? "#3A1418" : "#FEE2E2") 
                       : (cardHover.hovered ? (Theme.isDark ? "#241014" : "#FFF1F2") : "transparent")
                border.color: delHover.hovered 
                              ? Theme.accentRed 
                              : (cardHover.hovered ? Theme.accentRedBorder : "transparent")
                border.width: 1

                // Framer Motion style spring micro-interactions: scale + rotation tilt
                scale: delHover.hovered ? 1.12 : 1.0
                rotation: delHover.hovered ? -8 : 0

                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                Behavior on rotation { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                Behavior on color { ColorAnimation { duration: 140 } }
                Behavior on border.color { ColorAnimation { duration: 140 } }

                LucideIcon {
                    anchors.centerIn: parent
                    name: "trash-2"
                    size: 14
                    color: Theme.accentRed // Crisp, vibrant red
                }

                ToolTip.visible: delHover.hovered
                ToolTip.text: "Delete Activity"
                ToolTip.delay: 300

                HoverHandler { id: delHover }
                TapHandler {
                    onTapped: card.removeRequested()
                }
            }
        }
    }
}
