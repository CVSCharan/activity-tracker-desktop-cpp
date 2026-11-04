// EmptyStateView.qml — engaging empty state with 1-click quick starter templates
import QtQuick
import ActivityTracker 1.0

Column {
    id: emptyRoot
    spacing: 20

    // Visual Icon Box
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 68
        height: 68
        radius: 34
        color: Theme.accentBlueBg
        border.color: Theme.accentBlueBorder
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: "📋"
            font.pixelSize: 32
        }
    }

    // Informational Text
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "No activities logged yet"
            color: Theme.textPrimary
            font.pixelSize: 18
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Add an activity using the form on the left, or click a quick-start template below:"
            color: Theme.textSecondary
            font.pixelSize: 13
        }
    }

    // ── 1-Click Quick Starter Templates ───────────────────────────────────────
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12

        component TemplateCard: Rectangle {
            id: tmplRoot
            width: 154
            height: 76
            radius: 8
            color: tmplHover.hovered ? Theme.surfaceCardHover : Theme.surfaceCard
            border.color: tmplHover.hovered ? accentColor : Theme.borderDefault
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            required property string title
            required property string category
            required property int    duration
            required property string iconSymbol
            required property var    accentColor

            Column {
                anchors.centerIn: parent
                spacing: 5

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    Text { text: tmplRoot.iconSymbol; font.pixelSize: 14 }
                    Text {
                        text: tmplRoot.title
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.textPrimary
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    Text {
                        text: tmplRoot.category
                        font.pixelSize: 11
                        color: tmplRoot.accentColor
                        font.bold: true
                    }
                    Text { text: "•"; color: Theme.textMuted; font.pixelSize: 11 }
                    Text {
                        text: tmplRoot.duration + "m"
                        font.pixelSize: 11
                        color: Theme.textSecondary
                        font.bold: true
                    }
                }
            }

            HoverHandler { id: tmplHover }
            TapHandler {
                onTapped: {
                    activityService.addActivity(
                        tmplRoot.title,
                        tmplRoot.category,
                        tmplRoot.duration
                    )
                }
            }
        }

        TemplateCard {
            iconSymbol: "☕"
            title: "Daily Standup"
            category: "Work"
            duration: 15
            accentColor: Theme.accentBlue
        }

        TemplateCard {
            iconSymbol: "🔍"
            title: "Code Review"
            category: "Work"
            duration: 45
            accentColor: Theme.accentBlue
        }

        TemplateCard {
            iconSymbol: "📚"
            title: "Study Qt/QML"
            category: "Learning"
            duration: 30
            accentColor: Theme.accentAmber
        }

        TemplateCard {
            iconSymbol: "🏃"
            title: "Workout & Health"
            category: "Personal"
            duration: 30
            accentColor: Theme.accentGreen
        }
    }
}
