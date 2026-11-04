// StatsDashboard.qml — executive KPI metrics cards with responsive grid reflow and Lucide icons
import QtQuick
import QtQuick.Layouts
import ActivityTracker 1.0

GridLayout {
    id: statsGrid

    // ── Responsive Breakpoints ────────────────────────────────────────────────
    // Wide display (>800px): 4 cards in 1 row
    // Half-screen snap / Tablet (440px-800px): 2 rows x 2 columns
    // Compact (<440px): 1 column x 4 rows
    columns: width > 800 ? 4 : (width > 440 ? 2 : 1)
    rowSpacing: 10
    columnSpacing: 10

    // ── Reusable Stat Card Component ──────────────────────────────────────────
    component StatCard: Rectangle {
        id: cardRoot
        Layout.fillWidth: true
        Layout.preferredHeight: 88
        radius: 10
        color: cardHover.hovered ? Theme.surfaceCardHover : Theme.surfaceCard
        border.color: cardHover.hovered ? accentColor : Theme.borderDefault
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        HoverHandler { id: cardHover }

        required property string iconName
        required property string statValue
        required property string statTitle
        required property string statSubtitle
        required property var    accentColor
        property real   progressRatio: 0.0 // 0.0 to 1.0

        // Subtle left vertical accent indicator
        Rectangle {
            width: 4
            height: cardRoot.height - 24
            radius: 2
            anchors.left: cardRoot.left
            anchors.leftMargin: 8
            anchors.verticalCenter: cardRoot.verticalCenter
            color: accentColor
        }

        ColumnLayout {
            anchors {
                fill: parent
                leftMargin: 20
                rightMargin: 16
                topMargin: 12
                bottomMargin: 10
            }
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Stat Title & Value
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: statTitle
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.textSecondary
                        font.letterSpacing: 0.5
                    }

                    Text {
                        text: statValue
                        font.pixelSize: 22
                        font.bold: true
                        color: Theme.textPrimary
                    }
                }

                // Circular Icon Badge with Lucide Icon
                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 18
                    color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, Theme.isDark ? 0.15 : 0.12)
                    border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3)
                    border.width: 1

                    LucideIcon {
                        anchors.centerIn: parent
                        name: cardRoot.iconName
                        size: 16
                        color: cardRoot.accentColor
                    }
                }
            }

            // Subtitle & Progress Bar
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: statSubtitle
                    font.pixelSize: 11
                    color: accentColor
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                // Micro Progress Bar
                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 4
                    radius: 2
                    color: Theme.surfaceBadge

                    Rectangle {
                        height: parent.height
                        width: parent.width * Math.max(0.0, Math.min(1.0, cardRoot.progressRatio))
                        radius: 2
                        color: accentColor

                        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    }
                }
            }
        }
    }

    // ── 1. Total Activities Card ──────────────────────────────────────────────
    StatCard {
        iconName: "list-todo"
        statTitle: "TOTAL ACTIVITIES"
        statValue: activityModel.count.toString()
        statSubtitle: activityModel.count === 1 ? "1 item logged" : activityModel.count + " items logged"
        accentColor: Theme.accentBlue
        progressRatio: activityModel.count > 0 ? 1.0 : 0.0
    }

    // ── 2. Completed Card ─────────────────────────────────────────────────────
    StatCard {
        iconName: "check"
        statTitle: "COMPLETED"
        statValue: activityService.completedCount.toString()
        statSubtitle: activityService.completionPercentage + "% finished"
        accentColor: Theme.accentGreen
        progressRatio: activityService.completionPercentage / 100.0
    }

    // ── 3. Pending Card ───────────────────────────────────────────────────────
    StatCard {
        iconName: "clock"
        statTitle: "PENDING"
        statValue: activityService.pendingCount.toString()
        statSubtitle: activityService.pendingCount === 1 ? "1 in progress" : activityService.pendingCount + " in progress"
        accentColor: Theme.accentAmber
        progressRatio: activityModel.count > 0 ? (activityService.pendingCount / activityModel.count) : 0.0
    }

    // ── 4. Logged Today Card ──────────────────────────────────────────────────
    StatCard {
        iconName: "flame"
        statTitle: "TIME TODAY"
        statValue: activityService.totalDurationToday + " min"
        statSubtitle: formatHours(activityService.totalDurationToday)
        accentColor: Theme.accentPurple
        progressRatio: Math.min(1.0, activityService.totalDurationToday / 480.0) // 480 min = 8h work day goal

        function formatHours(mins) {
            const h = Math.floor(mins / 60)
            const m = mins % 60
            if (h === 0) return mins + "m tracked"
            return h + "h " + m + "m tracked"
        }
    }
}
