// SummaryBar.qml — bottom status bar with theme-aware styling
import QtQuick
import QtQuick.Layouts
import ActivityTracker 1.0

Rectangle {
    height: 40
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
        spacing: 20

        // Total count badge
        RowLayout {
            spacing: 6
            Text { text: "Total:"; color: Theme.textSecondary; font.pixelSize: 12 }
            Text {
                text: activityModel.count + " items"
                color: Theme.textPrimary
                font.bold: true
                font.pixelSize: 12
            }
        }

        // Completed count badge
        RowLayout {
            spacing: 6
            Text { text: "Completed:"; color: Theme.textSecondary; font.pixelSize: 12 }
            Text {
                text: activityService.completedCount
                color: Theme.accentGreen
                font.bold: true
                font.pixelSize: 12
            }
        }

        // Pending count badge
        RowLayout {
            spacing: 6
            Text { text: "Pending:"; color: Theme.textSecondary; font.pixelSize: 12 }
            Text {
                text: activityService.pendingCount
                color: Theme.accentAmber
                font.bold: true
                font.pixelSize: 12
            }
        }

        Item { Layout.fillWidth: true }

        // Today duration badge
        Rectangle {
            radius: 12
            color: Theme.accentBlueBg
            border.color: Theme.accentBlueBorder
            border.width: 1
            implicitWidth: durText.implicitWidth + 18
            implicitHeight: 24

            RowLayout {
                id: durText
                anchors.centerIn: parent
                spacing: 6
                Text { text: "Today:"; color: Theme.textSecondary; font.pixelSize: 11 }
                Text {
                    text: {
                        const mins = activityService.totalDurationToday
                        if (mins < 60) return mins + " min"
                        const h = Math.floor(mins / 60)
                        const m = mins % 60
                        return m > 0 ? (h + "h " + m + "m (" + mins + "m)") : (h + "h (" + mins + "m)")
                    }
                    color: Theme.accentBlue
                    font.bold: true
                    font.pixelSize: 11
                }
            }
        }
    }
}
