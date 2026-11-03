// ActivityCard.qml — high-contrast modern activity card

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

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
    color: card.activityDone ? "#111B15" : (cardHover.hovered ? "#1C2128" : "#161B22")
    border.color: card.activityDone ? "#238636" : (cardHover.hovered ? "#58A6FF" : "#30363D")
    border.width: 1

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    HoverHandler { id: cardHover }

    // Left accent category strip
    Rectangle {
        id: accentStrip
        width: 5
        height: card.height - 16
        radius: 3
        anchors.left: card.left
        anchors.leftMargin: 6
        anchors.verticalCenter: card.verticalCenter
        color: {
            switch (card.activityCategory) {
            case "Work":     return "#58A6FF"  // Blue
            case "Learning": return "#D29922"  // Amber
            case "Personal": return "#3FB950"  // Green
            default:         return "#8B949E"
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
            checked: card.activityDone
            enabled: !card.activityDone
            Material.accent: "#3FB950"
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

            // Activity Name (Bright white text, high contrast)
            Text {
                Layout.fillWidth: true
                text: card.activityName.length > 0 ? card.activityName : "(Untitled Activity)"
                color: card.activityDone ? "#6E7681" : "#F0F6FC"
                font.pixelSize: 15
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
                        case "Work":     return "#0D1D30"
                        case "Learning": return "#271E06"
                        case "Personal": return "#0F2818"
                        default:         return "#161B22"
                        }
                    }
                    border.color: {
                        switch (card.activityCategory) {
                        case "Work":     return "#1F6FEB"
                        case "Learning": return "#9E6A03"
                        case "Personal": return "#238636"
                        default:         return "#30363D"
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
                            case "Work":     return "#58A6FF"
                            case "Learning": return "#E3B341"
                            case "Personal": return "#3FB950"
                            default:         return "#8B949E"
                            }
                        }
                    }
                }

                // Duration pill
                Rectangle {
                    radius: 10
                    implicitWidth: durText.implicitWidth + 14
                    implicitHeight: 20
                    color: "#21262D"
                    border.color: "#30363D"
                    border.width: 1

                    Text {
                        id: durText
                        anchors.centerIn: parent
                        text: "⏱ " + card.activityDuration + " min"
                        font.pixelSize: 11
                        color: "#C9D1D9"
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
            color: delHover.hovered ? "#38171B" : "transparent"
            border.color: delHover.hovered ? "#F85149" : "transparent"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "✕"
                font.pixelSize: 14
                font.bold: true
                color: delHover.hovered ? "#FF7B72" : "#6E7681"
            }

            HoverHandler { id: delHover }
            TapHandler {
                onTapped: card.removeRequested()
            }
        }
    }
}
