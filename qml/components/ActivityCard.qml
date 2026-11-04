// ActivityCard.qml — high-contrast modern activity card with light/dark theme support
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import ActivityTracker 1.0

Rectangle {
    id: card

    required property string activityName
    required property string activityCategory
    required property int    activityDuration
    required property bool   activityDone
    required property int    activityIndex

    signal removeRequested()
    signal completeRequested()

    height: 76
    radius: 8
    color: card.activityDone 
           ? (Theme.isDark ? "#0E1C14" : "#F0FDF4")
           : (cardHover.hovered ? Theme.surfaceCardHover : Theme.surfaceCard)

    border.color: card.activityDone 
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
        height: card.height - 18
        radius: 2
        anchors.left: card.left
        anchors.leftMargin: 6
        anchors.verticalCenter: card.verticalCenter
        color: {
            switch (card.activityCategory) {
            case "Work":     return Theme.accentBlue
            case "Learning": return Theme.accentAmber
            case "Personal": return Theme.accentGreen
            default:         return Theme.textSecondary
            }
        }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 18
            rightMargin: 16
            topMargin: 8
            bottomMargin: 8
        }
        spacing: 12

        // ── Done checkbox ─────────────────────────────────────────────────────
        CheckBox {
            id: doneBox
            checked: card.activityDone
            enabled: !card.activityDone
            Material.accent: Theme.accentGreen
            onCheckedChanged: {
                if (checked && !card.activityDone) {
                    card.completeRequested()
                }
            }
        }

        // ── Title + Metadata badges ───────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            // Activity Name
            Text {
                Layout.fillWidth: true
                text: card.activityName.length > 0 ? card.activityName : "(Untitled Activity)"
                color: card.activityDone ? Theme.textMuted : Theme.textPrimary
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight
                font.strikeout: card.activityDone
            }

            // Badges row: Category pill + Duration pill
            RowLayout {
                spacing: 8

                // Category pill
                Rectangle {
                    radius: 10
                    implicitWidth: catText.implicitWidth + 14
                    implicitHeight: 20
                    color: {
                        switch (card.activityCategory) {
                        case "Work":     return Theme.accentBlueBg
                        case "Learning": return Theme.accentAmberBg
                        case "Personal": return Theme.accentGreenBg
                        default:         return Theme.surfaceBadge
                        }
                    }
                    border.color: {
                        switch (card.activityCategory) {
                        case "Work":     return Theme.accentBlueBorder
                        case "Learning": return Theme.accentAmberBorder
                        case "Personal": return Theme.accentGreenBorder
                        default:         return Theme.borderDefault
                        }
                    }
                    border.width: 1

                    Text {
                        id: catText
                        anchors.centerIn: parent
                        text: card.activityCategory.length > 0 ? card.activityCategory : "General"
                        font.pixelSize: 11
                        font.bold: true
                        color: {
                            switch (card.activityCategory) {
                            case "Work":     return Theme.accentBlue
                            case "Learning": return Theme.accentAmber
                            case "Personal": return Theme.accentGreen
                            default:         return Theme.textSecondary
                            }
                        }
                    }
                }

                // Duration pill
                Rectangle {
                    radius: 10
                    implicitWidth: durText.implicitWidth + 14
                    implicitHeight: 20
                    color: Theme.surfaceBadge
                    border.color: Theme.borderDefault
                    border.width: 1

                    Text {
                        id: durText
                        anchors.centerIn: parent
                        text: "⏱ " + card.activityDuration + " min"
                        font.pixelSize: 11
                        color: Theme.textSecondary
                        font.bold: true
                    }
                }
            }
        }

        // ── Delete Button ─────────────────────────────────────────────────────
        Rectangle {
            id: delBtn
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: 6
            color: delHover.hovered ? Theme.accentRedBg : "transparent"
            border.color: delHover.hovered ? Theme.accentRedBorder : "transparent"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "✕"
                font.pixelSize: 13
                font.bold: true
                color: delHover.hovered ? Theme.accentRed : Theme.textMuted
            }

            HoverHandler { id: delHover }
            TapHandler {
                onTapped: card.removeRequested()
            }
        }
    }
}
