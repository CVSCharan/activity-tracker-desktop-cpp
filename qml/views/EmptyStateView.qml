// EmptyStateView.qml — engaging empty state with responsive quick starter templates and Lucide icons
import QtQuick
import ActivityTracker 1.0
import "../components" as Components

Column {
    id: emptyRoot
    spacing: 20
    width: Math.min(parent.width - 40, 720)

    // Visual Icon Box
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 68
        height: 68
        radius: 34
        color: Theme.accentBlueBg
        border.color: Theme.accentBlueBorder
        border.width: 1

        Components.LucideIcon {
            anchors.centerIn: parent
            name: "list-todo"
            size: 30
            color: Theme.accentBlue
        }
    }

    // Informational Text
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6
        width: parent.width

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
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // ── Responsive 1-Click Quick Starter Templates ────────────────────────────
    // Reflows: 4 in 1 row (>660px), 2x2 grid (340-660px), 1 column (<340px)
    Grid {
        id: templateGrid
        anchors.horizontalCenter: parent.horizontalCenter
        columns: emptyRoot.width > 660 ? 4 : (emptyRoot.width > 340 ? 2 : 1)
        spacing: 10

        component TemplateCard: Rectangle {
            id: tmplRoot
            width: emptyRoot.width > 660 ? 154 : (emptyRoot.width > 340 ? (emptyRoot.width - 10) / 2 : emptyRoot.width)
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
            required property string iconName
            required property var    accentColor

            Column {
                anchors.centerIn: parent
                spacing: 6

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    Components.LucideIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: tmplRoot.iconName
                        size: 13
                        color: tmplRoot.accentColor
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
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
            iconName: "zap"
            title: "Daily Standup"
            category: "Work"
            duration: 15
            accentColor: Theme.accentBlue
        }

        TemplateCard {
            iconName: "search"
            title: "Code Review"
            category: "Work"
            duration: 45
            accentColor: Theme.accentBlue
        }

        TemplateCard {
            iconName: "book-open"
            title: "Study Qt/QML"
            category: "Learning"
            duration: 30
            accentColor: Theme.accentAmber
        }

        TemplateCard {
            iconName: "flame"
            title: "Workout & Health"
            category: "Personal"
            duration: 30
            accentColor: Theme.accentGreen
        }
    }
}
