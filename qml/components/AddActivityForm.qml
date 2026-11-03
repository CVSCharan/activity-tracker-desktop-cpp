// AddActivityForm.qml — high-contrast input form to create activities

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

ColumnLayout {
    spacing: 16

    // ── Section Title ─────────────────────────────────────────────────────────
    Text {
        text: "Add Activity"
        font.pixelSize: 17
        font.bold: true
        color: "#F0F6FC"
        Layout.topMargin: 4
    }

    // ── Activity Name ─────────────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
            text: "Activity Name"
            color: "#C9D1D9"
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
            placeholderTextColor: "#8B949E"
            color: "#F0F6FC"
            font.pixelSize: 13
            selectByMouse: true
            clip: true

            background: Rectangle {
                radius: 6
                color: "#0D1117"
                border.color: nameField.activeFocus ? "#58A6FF" : "#30363D"
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
            color: "#C9D1D9"
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
            Material.accent: "#58A6FF"
            font.pixelSize: 13

            contentItem: Text {
                leftPadding: 4
                text: categoryCombo.displayText
                font: categoryCombo.font
                color: "#F0F6FC"
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 6
                color: "#0D1117"
                border.color: categoryCombo.activeFocus ? "#58A6FF" : "#30363D"
                border.width: 1
            }
        }
    }

    // ── Duration ──────────────────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
            text: "Duration (minutes)"
            color: "#C9D1D9"
            font.pixelSize: 13
            font.bold: true
        }

        SpinBox {
            id: durationSpinBox
            Layout.fillWidth: true
            implicitHeight: 42
            from: 5
            to: 480
            value: 30
            stepSize: 15
            editable: true
            Material.accent: "#58A6FF"
            font.pixelSize: 13

            contentItem: TextInput {
                text: durationSpinBox.value.toString()
                font: durationSpinBox.font
                color: "#F0F6FC"
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                readOnly: !durationSpinBox.editable
                validator: durationSpinBox.validator
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            background: Rectangle {
                radius: 6
                color: "#0D1117"
                border.color: durationSpinBox.activeFocus ? "#58A6FF" : "#30363D"
                border.width: 1
            }
        }
    }

    // ── Add Button ────────────────────────────────────────────────────
    Button {
        id: addBtn
        Layout.fillWidth: true
        Layout.topMargin: 8
        implicitHeight: 42
        text: "+ Add Activity"
        font.pixelSize: 14
        font.bold: true

        enabled: nameField.text.trim().length > 0

        contentItem: Text {
            text: addBtn.text
            font: addBtn.font
            color: addBtn.enabled ? "#FFFFFF" : "#6E7681"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            radius: 6
            color: addBtn.enabled ? (addBtn.down ? "#1B4B91" : "#1F6FEB") : "#21262D"
            border.color: addBtn.enabled ? "#388BFD" : "#30363D"
            border.width: 1
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
