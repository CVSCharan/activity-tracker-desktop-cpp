// StatsDashboard.qml — top summary cards displaying high-level metrics

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: statsRow
    spacing: 12

    // ── Reusable Stat Card Component ──────────────────────────────────────────
    component StatCard: Rectangle {
        id: cardRoot
        Layout.fillWidth: true
        height: 84
        radius: 10
        color: cardHover.hovered ? "#1C2128" : "#161B22"
        border.color: cardHover.hovered ? accentColor : "#30363D"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        HoverHandler { id: cardHover }

        required property string iconText
        required property string statValue
        required property string statTitle
        required property string statSubtitle
        required property color  accentColor

        // Subtle left vertical accent indicator
        Rectangle {
            width: 4
            height: parent.height - 24
            radius: 2
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            color: accentColor
        }

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 20
                rightMargin: 16
                topMargin: 12
                bottomMargin: 12
            }
            spacing: 12

            // Stat numbers & labels
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: statTitle
                    font.pixelSize: 11
                    font.bold: true
                    color: "#8B949E"
                    letterSpacing: 0.5
                }

                Text {
                    text: statValue
                    font.pixelSize: 22
                    font.bold: true
                    color: "#F0F6FC"
                }

                Text {
                    text: statSubtitle
                    font.pixelSize: 11
                    color: accentColor
                    font.bold: true
                }
            }

            // Circular Icon Badge
            Rectangle {
                width: 38
                height: 38
                radius: 19
                color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.15)
                border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3)
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: iconText
                    font.pixelSize: 16
                }
            }
        }
    }

    // ── 1. Total Activities Card ──────────────────────────────────────────────
    StatCard {
        iconText: "📋"
        statTitle: "TOTAL ACTIVITIES"
        statValue: activityModel.count.toString()
        statSubtitle: "All logged items"
        accentColor: "#58A6FF"
    }

    // ── 2. Completed Card ─────────────────────────────────────────────────────
    StatCard {
        iconText: "✅"
        statTitle: "COMPLETED"
        statValue: activityService.completedCount.toString()
        statSubtitle: activityService.completionPercentage + "% finished"
        accentColor: "#3FB950"
    }

    // ── 3. Pending Card ───────────────────────────────────────────────────────
    StatCard {
        iconText: "⏳"
        statTitle: "PENDING"
        statValue: activityService.pendingCount.toString()
        statSubtitle: "In progress"
        accentColor: "#D29922"
    }

    // ── 4. Logged Today Card ──────────────────────────────────────────────────
    StatCard {
        iconText: "⏱️"
        statTitle: "TIME TODAY"
        statValue: activityService.totalDurationToday + " min"
        statSubtitle: formatHours(activityService.totalDurationToday)
        accentColor: "#A371F7"

        function formatHours(mins) {
            const h = Math.floor(mins / 60)
            const m = mins % 60
            if (h === 0) return mins + " minutes"
            return h + "h " + m + "m total"
        }
    }
}

