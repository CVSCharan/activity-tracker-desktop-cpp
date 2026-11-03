// ActivityCard.qml — displays one activity row
//
// 'required property' means the parent MUST set this when using the component.
// Equivalent to a required prop in React: PropTypes.isRequired

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Rectangle {
    id: card

    // ── Required props from parent ────────────────────────────────────────────
    required property string activityName
    required property string activityCategory
    required property int    activityDuration
    required property bool   activityDone
    required property int    activityIndex

    // ── Signals — events this component raises to its parent ──────────────────
    // JS analogy: custom events (CustomEvent / EventEmitter)
    signal removeRequested()
    signal completeRequested()

    // ── Appearance ────────────────────────────────────────────────────────────
    height: 72
    radius: 8
    color: activityDone ? "#1A2F1A" : "#21252B"  // green tint when done

    // Subtle left-side accent bar (category color indicator)
    Rectangle {
        width: 4
        height: parent.height
        radius: 2
        color: {
            switch (activityCategory) {
            case "Work":     return "#58A6FF"
            case "Learning": return "#F59E0B"
            case "Personal": return "#10B981"
            default:         return "#6B7280"
            }
        }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 16
            rightMargin: 12
            topMargin: 8
            bottomMargin: 8
        }
        spacing: 12

        // ── Done checkbox ─────────────────────────────────────────────────────
        CheckBox {
            checked: activityDone
            enabled: !activityDone           // can't un-complete
            onCheckedChanged: {
                if (checked) card.completeRequested()
            }
            Material.accent: "#10B981"       // green checkmark
        }

        // ── Name + category ───────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: activityName
                color: activityDone ? "#6B7280" : "#D7DAE0"
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight      // truncate with '…' if too long
                font.strikeout: activityDone
            }

            Text {
                text: activityCategory + "  •  " + activityDuration + " min"
                color: "#6B7280"
                font.pixelSize: 12
            }
        }

        // ── Delete button ─────────────────────────────────────────────────────
        RoundButton {
            flat: true
            text: "🗑"
            font.pixelSize: 16
            implicitWidth: 36
            implicitHeight: 36
            opacity: deleteHover.containsMouse ? 1.0 : 0.5

            onClicked: card.removeRequested()

            HoverHandler { id: deleteHover }
        }
    }
}

