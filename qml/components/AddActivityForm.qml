// AddActivityForm.qml — input form to create a new activity

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

ColumnLayout {
    spacing: 16

    // ── Section title ─────────────────────────────────────────────────────────
    Text {
        text: "Add Activity"
        font.pixelSize: 16
        font.bold: true
        color: "#D7DAE0"
        Layout.topMargin: 8
    }

    // ── Activity name ─────────────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        Text { text: "Name"; color: "#9CA3AF"; font.pixelSize: 12 }

        TextField {
            id: nameField
            Layout.fillWidth: true
            placeholderText: "e.g. Write unit tests"
            Material.accent: "#58A6FF"
            // 'text' is a built-in property of TextField — no need to declare it
        }
    }

    // ── Category ──────────────────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        Text { text: "Category"; color: "#9CA3AF"; font.pixelSize: 12 }

        ComboBox {
            id: categoryCombo
            Layout.fillWidth: true
            model: ["Work", "Learning", "Personal"]
            // currentText gives the selected string — like <select> value in HTML
        }
    }

    // ── Duration ──────────────────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        Text { text: "Duration (minutes)"; color: "#9CA3AF"; font.pixelSize: 12 }

        SpinBox {
            id: durationSpinBox
            Layout.fillWidth: true
            from: 1
            to: 480       // 8 hours max
            value: 30
            stepSize: 15
        }
    }

    // ── Spacer ────────────────────────────────────────────────────────────────
    Item { Layout.fillHeight: true }

    // ── Add button ────────────────────────────────────────────────────────────
    Button {
        Layout.fillWidth: true
        text: "Add Activity"

        // Disable the button when name is empty — validation at the UI level.
        // The service also validates, but this prevents the round trip.
        enabled: nameField.text.trim().length > 0

        Material.background: enabled ? "#58A6FF" : "#2D3139"

        onClicked: {
            // Call the Q_INVOKABLE method on the C++ ActivityService.
            // JS types are automatically converted to C++ types:
            //   JS string  →  QString
            //   JS number  →  int
            activityService.addActivity(
                nameField.text.trim(),
                categoryCombo.currentText,
                durationSpinBox.value
            )
            // Reset form
            nameField.text = ""
            durationSpinBox.value = 30
        }
    }
}
