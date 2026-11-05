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
    property var createdAt: null

    signal removeRequested()
    signal completeRequested()

    height: 76
    radius: 10
    color: card.done 
           ? (Theme.isDark ? "#0E1C14" : "#F0FDF4")
           : (cardHover.hovered ? Theme.surfaceCardHover : Theme.surfaceCard)

    border.color: card.done 
                  ? Theme.accentGreenBorder
                  : (cardHover.hovered ? Theme.accentBlue : Theme.borderDefault)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    HoverHandler { id: cardHover }

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

        // ── Done checkbox ─────────────────────────────────────────────────────
        CheckBox {
            id: doneBox
            Layout.alignment: Qt.AlignVCenter
            checked: card.done
            enabled: !card.done
            Material.accent: Theme.accentGreen
            onCheckedChanged: {
                if (checked && !card.done) {
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

                // Status pill (Completed badge if done)
                Rectangle {
                    visible: card.done
                    radius: 10
                    implicitWidth: statusRow.implicitWidth + 14
                    implicitHeight: 22
                    color: Theme.accentGreenBg
                    border.color: Theme.accentGreenBorder
                    border.width: 1

                    Row {
                        id: statusRow
                        anchors.centerIn: parent
                        spacing: 4

                        LucideIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: "check"
                            size: 12
                            color: Theme.accentGreen
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Completed"
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.accentGreen
                        }
                    }
                }
            }
        }

        // ── Delete Button ─────────────────────────────────────────────────────
        Rectangle {
            id: delBtn
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: 6
            color: delHover.hovered ? Theme.accentRedBg : "transparent"
            border.color: delHover.hovered ? Theme.accentRedBorder : "transparent"
            border.width: 1

            LucideIcon {
                anchors.centerIn: parent
                name: "trash-2"
                size: 13
                color: delHover.hovered ? Theme.accentRed : Theme.textMuted
            }

            HoverHandler { id: delHover }
            TapHandler {
                onTapped: card.removeRequested()
            }
        }
    }
}
