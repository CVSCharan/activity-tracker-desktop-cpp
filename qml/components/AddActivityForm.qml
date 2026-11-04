// AddActivityForm.qml — ergonomic input form with 1-click quick duration pills
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import ActivityTracker 1.0

ColumnLayout {
    id: formRoot
    spacing: 16

    // ── Section Title ─────────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 4
        spacing: 8

        Text {
            text: "Add Activity"
            font.pixelSize: 17
            font.bold: true
            color: Theme.textPrimary
        }

        Item { Layout.fillWidth: true }

        Text {
            text: "Fast Log"
            font.pixelSize: 11
            font.bold: true
            color: Theme.accentBlue
        }
    }

    // ── Activity Name ─────────────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
            text: "Activity Name"
            color: Theme.textSecondary
            font.pixelSize: 13
            font.bold: true
        }

        TextField {
            id: nameField
            Layout.fillWidth: true
            implicitHeight: 42
            leftPadding: 14
            rightPadding: 14
            topPadding: 11
            bottomPadding: 11
            verticalAlignment: TextInput.AlignVCenter
            placeholderText: "e.g. Code review, Study QML"
            placeholderTextColor: Theme.textMuted
            color: Theme.textPrimary
            font.pixelSize: 13
            selectByMouse: true
            clip: true

            background: Rectangle {
                radius: 6
                color: Theme.surfaceInput
                border.color: nameField.activeFocus ? Theme.borderFocus : Theme.borderDefault
                border.width: nameField.activeFocus ? 2 : 1
            }

            onAccepted: {
                if (nameField.text.trim().length > 0) {
                    addBtn.clicked()
                }
            }
        }
    }

    // ── Category ──────────────────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
            text: "Category"
            color: Theme.textSecondary
            font.pixelSize: 13
            font.bold: true
        }

        ComboBox {
            id: categoryCombo
            Layout.fillWidth: true
            implicitHeight: 42
            leftPadding: 14
            rightPadding: 14
            model: ["Work", "Learning", "Personal"]
            Material.accent: Theme.accentBlue
            font.pixelSize: 13

            contentItem: Text {
                leftPadding: 4
                text: categoryCombo.displayText
                font: categoryCombo.font
                color: Theme.textPrimary
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 6
                color: Theme.surfaceInput
                border.color: categoryCombo.activeFocus ? Theme.borderFocus : Theme.borderDefault
                border.width: 1
            }
        }
    }

    // ── Duration with 1-Click Quick Duration Pills ─────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Duration"
                color: Theme.textSecondary
                font.pixelSize: 13
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Text {
                text: durationSpinBox.value + " min"
                color: Theme.accentBlue
                font.pixelSize: 12
                font.bold: true
            }
        }

        // Quick Preset Pills: 15m, 30m, 45m, 60m
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: [15, 30, 45, 60]
                delegate: Rectangle {
                    id: pill
                    Layout.fillWidth: true
                    implicitHeight: 28
                    radius: 6
                    readonly property bool isSelected: durationSpinBox.value === modelData
                    color: isSelected ? Theme.accentBlueBg : (pillHover.hovered ? Theme.surfaceCardHover : Theme.surfaceInput)
                    border.color: isSelected ? Theme.accentBlue : Theme.borderDefault
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: modelData + "m"
                        font.pixelSize: 12
                        font.bold: pill.isSelected
                        color: pill.isSelected ? Theme.accentBlue : Theme.textSecondary
                    }

                    HoverHandler { id: pillHover }
                    TapHandler {
                        onTapped: durationSpinBox.value = modelData
                    }
                }
            }
        }

        // Fine-tuning SpinBox
        SpinBox {
            id: durationSpinBox
            Layout.fillWidth: true
            implicitHeight: 38
            from: 5
            to: 480
            value: 30
            stepSize: 5
            editable: true
            Material.accent: Theme.accentBlue
            font.pixelSize: 13

            contentItem: TextInput {
                text: durationSpinBox.value.toString()
                font: durationSpinBox.font
                color: Theme.textPrimary
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                readOnly: !durationSpinBox.editable
                validator: durationSpinBox.validator
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            background: Rectangle {
                radius: 6
                color: Theme.surfaceInput
                border.color: durationSpinBox.activeFocus ? Theme.borderFocus : Theme.borderDefault
                border.width: 1
            }
        }
    }

    // ── Add Button ────────────────────────────────────────────────────────────
    Button {
        id: addBtn
        Layout.fillWidth: true
        Layout.topMargin: 8
        implicitHeight: 44
        text: "+ Add Activity"
        font.pixelSize: 14
        font.bold: true

        enabled: nameField.text.trim().length > 0

        contentItem: Text {
            text: addBtn.text
            font: addBtn.font
            color: addBtn.enabled ? "#FFFFFF" : Theme.textMuted
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            radius: 6
            color: addBtn.enabled ? (addBtn.down ? Qt.darker(Theme.accentBlue, 1.2) : Theme.accentBlue) : Theme.surfaceBadge
            border.color: addBtn.enabled ? Theme.accentBlueBorder : Theme.borderDefault
            border.width: 1

            Behavior on color { ColorAnimation { duration: 120 } }
        }

        onClicked: {
            activityService.addActivity(
                nameField.text.trim(),
                categoryCombo.currentText,
                durationSpinBox.value
            )
            nameField.text = ""
            nameField.forceActiveFocus()
        }
    }

    // Bottom filler spacer
    Item { Layout.fillHeight: true }
}
