// SummaryBar.qml — high-contrast bottom status bar

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    height: 42
    color: "#161B22"
    border.color: "#30363D"
    border.width: 1

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
            Text { text: "Total:"; color: "#8B949E"; font.pixelSize: 13 }
            Text {
                text: activityModel.count + " items"
                color: "#F0F6FC"
                font.bold: true
                font.pixelSize: 13
            }
        }

        // Completed count badge
        RowLayout {
            spacing: 6
            Text { text: "Completed:"; color: "#8B949E"; font.pixelSize: 13 }
            Text {
                text: activityService.completedCount
                color: "#3FB950"
                font.bold: true
                font.pixelSize: 13
            }
        }

        Item { Layout.fillWidth: true }

        // Today duration badge
        Rectangle {
            radius: 12
            color: "#0D1D30"
            border.color: "#1F6FEB"
            border.width: 1
            implicitWidth: durText.implicitWidth + 18
            implicitHeight: 26

            RowLayout {
                id: durText
                anchors.centerIn: parent
                spacing: 6
                Text { text: "Today:"; color: "#8B949E"; font.pixelSize: 12 }
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
