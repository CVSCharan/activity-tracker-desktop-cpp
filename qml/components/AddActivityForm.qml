// AddActivityForm.qml — ergonomic, modern input form with custom desktop text fields
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ActivityTracker 1.0

ColumnLayout {
    id: formRoot
    spacing: 16

    property string selectedCategory: "Work"
    property string selectedPriority: "Medium"
    function focusNameField() { nameField.forceActiveFocus() }

    // ── Activity Name (Custom Desktop Input Field) ─────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Activity Name"
                color: Theme.textSecondary
                font.pixelSize: 13
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Text {
                text: nameField.text.length > 0 ? nameField.text.length + " chars" : ""
                color: Theme.textMuted
                font.pixelSize: 11
            }
        }

        // Modern input container with focus halo and zero placeholder overlay
        Rectangle {
            id: inputWrapper
            Layout.fillWidth: true
            implicitHeight: 44
            radius: 8
            color: nameField.activeFocus 
                   ? (Theme.isDark ? "#121A28" : "#F8FAFC") 
                   : Theme.surfaceInput
            border.color: nameField.activeFocus ? Theme.accentBlue : Theme.borderDefault
            border.width: nameField.activeFocus ? 2 : 1

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 8

                LucideIcon {
                    name: "plus"
                    size: 13
                    color: nameField.activeFocus ? Theme.accentBlue : Theme.textMuted
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Custom Smooth Placeholder (vanishes completely when user types; never overlays text)
                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "e.g. Code review, Study Qt/QML..."
                        color: Theme.textMuted
                        font.pixelSize: 13
                        visible: nameField.text.length === 0
                        opacity: nameField.activeFocus ? 0.35 : 0.8
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    TextField {
                        id: nameField
                        anchors.fill: parent
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.textPrimary
                        font.pixelSize: 13
                        font.bold: false
                        selectByMouse: true
                        clip: true
                        background: null
                        placeholderText: "" // Empty so Material style's internal floating label does NOT clash
                        activeFocusOnTab: true
                        KeyNavigation.tab: catWork

                        onAccepted: {
                            if (nameField.text.trim().length > 0) {
                                addBtn.clicked()
                            }
                        }
                    }
                }

                // Clear button (✕)
                Rectangle {
                    visible: nameField.text.length > 0
                    implicitWidth: 20
                    implicitHeight: 20
                    radius: 10
                    color: clearNameHover.hovered ? Theme.surfaceCardHover : "transparent"

                    LucideIcon {
                        anchors.centerIn: parent
                        name: "x"
                        size: 11
                        color: Theme.textMuted
                    }

                    HoverHandler { id: clearNameHover }
                    TapHandler {
                        onTapped: {
                            nameField.text = ""
                            nameField.forceActiveFocus()
                        }
                    }
                }

                // Enter key shortcut hint
                Rectangle {
                    visible: nameField.text.trim().length > 0
                    radius: 4
                    implicitWidth: 22
                    implicitHeight: 20
                    color: Theme.accentBlueBg
                    border.color: Theme.accentBlueBorder
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "↵"
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.accentBlue
                    }
                }
            }
        }
    }

    // ── Category (Interactive Visual Selector Cards) ──────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
            text: "Category"
            color: Theme.textSecondary
            font.pixelSize: 13
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Work
            Rectangle {
                id: catWork
                Layout.fillWidth: true
                implicitHeight: 38
                radius: 8
                readonly property bool isSelected: formRoot.selectedCategory === "Work"
                activeFocusOnTab: true
                KeyNavigation.tab: durationSpinBox
                Keys.onRightPressed: formRoot.selectedCategory = "Learning"

                color: isSelected 
                       ? Theme.accentBlueBg 
                       : (workHover.hovered || catWork.activeFocus ? Theme.surfaceCardHover : Theme.surfaceInput)
                border.color: isSelected ? Theme.accentBlue : (catWork.activeFocus ? Theme.accentBlue : Theme.borderDefault)
                border.width: isSelected || catWork.activeFocus ? 2 : 1

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    LucideIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "briefcase"
                        size: 12
                        color: catWork.isSelected ? Theme.accentBlue : Theme.textPrimary
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Work"
                        font.pixelSize: 12
                        font.bold: catWork.isSelected
                        color: catWork.isSelected ? Theme.accentBlue : Theme.textPrimary
                    }
                }

                HoverHandler { id: workHover }
                TapHandler { onTapped: formRoot.selectedCategory = "Work" }
            }

            // Learning
            Rectangle {
                id: catLearn
                Layout.fillWidth: true
                implicitHeight: 38
                radius: 8
                readonly property bool isSelected: formRoot.selectedCategory === "Learning"
                activeFocusOnTab: true
                KeyNavigation.tab: durationSpinBox
                Keys.onLeftPressed: formRoot.selectedCategory = "Work"
                Keys.onRightPressed: formRoot.selectedCategory = "Personal"

                color: isSelected 
                       ? Theme.accentAmberBg 
                       : (learnHover.hovered || catLearn.activeFocus ? Theme.surfaceCardHover : Theme.surfaceInput)
                border.color: isSelected ? Theme.accentAmber : (catLearn.activeFocus ? Theme.accentAmber : Theme.borderDefault)
                border.width: isSelected || catLearn.activeFocus ? 2 : 1

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    LucideIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "book-open"
                        size: 12
                        color: catLearn.isSelected ? Theme.accentAmber : Theme.textPrimary
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Learning"
                        font.pixelSize: 12
                        font.bold: catLearn.isSelected
                        color: catLearn.isSelected ? Theme.accentAmber : Theme.textPrimary
                    }
                }

                HoverHandler { id: learnHover }
                TapHandler { onTapped: formRoot.selectedCategory = "Learning" }
            }

            // Personal
            Rectangle {
                id: catPers
                Layout.fillWidth: true
                implicitHeight: 38
                radius: 8
                readonly property bool isSelected: formRoot.selectedCategory === "Personal"
                activeFocusOnTab: true
                KeyNavigation.tab: durationSpinBox
                Keys.onLeftPressed: formRoot.selectedCategory = "Learning"

                color: isSelected 
                       ? Theme.accentGreenBg 
                       : (persHover.hovered || catPers.activeFocus ? Theme.surfaceCardHover : Theme.surfaceInput)
                border.color: isSelected ? Theme.accentGreen : (catPers.activeFocus ? Theme.accentGreen : Theme.borderDefault)
                border.width: isSelected || catPers.activeFocus ? 2 : 1

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    LucideIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "user"
                        size: 12
                        color: catPers.isSelected ? Theme.accentGreen : Theme.textPrimary
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Personal"
                        font.pixelSize: 12
                        font.bold: catPers.isSelected
                        color: catPers.isSelected ? Theme.accentGreen : Theme.textPrimary
                    }
                }

                HoverHandler { id: persHover }
                TapHandler { onTapped: formRoot.selectedCategory = "Personal" }
            }
        }
    }

    // ── Priority Selector (Executive P1-P4 Segment) ───────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Priority"
                color: Theme.textSecondary
                font.pixelSize: 13
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Text {
                text: formRoot.selectedPriority
                color: formRoot.selectedPriority === "Urgent" ? Theme.accentRed :
                       (formRoot.selectedPriority === "High" ? Theme.accentAmber :
                       (formRoot.selectedPriority === "Medium" ? Theme.accentBlue : Theme.textMuted))
                font.pixelSize: 11
                font.bold: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: [
                    { name: "Urgent", color: "#EF4444", bg: "#2A1215", border: "#7F1D1D" },
                    { name: "High",   color: "#F97316", bg: "#2A1805", border: "#7C2D12" },
                    { name: "Medium", color: "#3B82F6", bg: "#0C1E3A", border: "#1E3A8A" },
                    { name: "Low",    color: "#94A3B8", bg: "#1E293B", border: "#334155" }
                ]

                delegate: Rectangle {
                    id: prioPill
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: 6
                    readonly property bool isSelected: formRoot.selectedPriority === modelData.name

                    color: isSelected 
                           ? (Theme.isDark ? modelData.bg : Qt.lighter(modelData.bg, 3.5)) 
                           : (prioHover.hovered ? Theme.surfaceCardHover : Theme.surfaceInput)
                    border.color: isSelected ? modelData.color : Theme.borderDefault
                    border.width: isSelected ? 1.5 : 1

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Rectangle {
                            implicitWidth: 6
                            implicitHeight: 6
                            radius: 3
                            color: modelData.color
                        }

                        Text {
                            text: modelData.name
                            font.pixelSize: 11
                            font.bold: prioPill.isSelected
                            color: prioPill.isSelected ? (Theme.isDark ? "#FFFFFF" : modelData.color) : Theme.textSecondary
                        }
                    }

                    HoverHandler { id: prioHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: formRoot.selectedPriority = modelData.name }
                }
            }
        }
    }

    // ── Duration with 1-Click Quick Pills & Stepper ────────────────────────────
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
                text: durationSpinBox.value + " min  (" + (durationSpinBox.value / 60).toFixed(1) + " hrs)"
                color: Theme.accentBlue
                font.pixelSize: 12
                font.bold: true
            }
        }

        // Quick Preset Pills: 15m, 30m, 45m, 60m, 90m
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: [15, 30, 45, 60, 90]
                delegate: Rectangle {
                    id: pill
                    Layout.fillWidth: true
                    implicitHeight: 30
                    radius: 6
                    readonly property bool isSelected: durationSpinBox.value === modelData
                    color: isSelected ? Theme.accentBlueBg : (pillHover.hovered ? Theme.surfaceCardHover : Theme.surfaceInput)
                    border.color: isSelected ? Theme.accentBlue : Theme.borderDefault
                    border.width: isSelected ? 2 : 1

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

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

        // Fine-tuning Stepper with [-] and [+] Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Decrement Button
            Rectangle {
                implicitWidth: 42
                implicitHeight: 38
                radius: 6
                color: decHover.hovered ? Theme.surfaceCardHover : Theme.surfaceInput
                border.color: Theme.borderDefault
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "− 5m"
                    font.pixelSize: 12
                    font.bold: true
                    color: Theme.textPrimary
                }

                HoverHandler { id: decHover }
                TapHandler {
                    onTapped: {
                        if (durationSpinBox.value >= 10) durationSpinBox.value -= 5
                    }
                }
            }

            // Central SpinBox display
            SpinBox {
                id: durationSpinBox
                Layout.fillWidth: true
                implicitHeight: 38
                from: 5
                to: 480
                value: 30
                stepSize: 5
                editable: true
                font.pixelSize: 13
                activeFocusOnTab: true
                KeyNavigation.tab: addBtn

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
                    border.color: durationSpinBox.activeFocus ? Theme.accentBlue : Theme.borderDefault
                    border.width: durationSpinBox.activeFocus ? 2 : 1
                }
            }

            // Increment Button
            Rectangle {
                implicitWidth: 42
                implicitHeight: 38
                radius: 6
                color: incHover.hovered ? Theme.surfaceCardHover : Theme.surfaceInput
                border.color: Theme.borderDefault
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "+ 5m"
                    font.pixelSize: 12
                    font.bold: true
                    color: Theme.textPrimary
                }

                HoverHandler { id: incHover }
                TapHandler {
                    onTapped: {
                        if (durationSpinBox.value <= 475) durationSpinBox.value += 5
                    }
                }
            }
        }
    }

    // ── Add Button ────────────────────────────────────────────────────────────
    Button {
        id: addBtn
        Layout.fillWidth: true
        Layout.topMargin: 6
        implicitHeight: 46
        text: "+ Log Activity"
        font.pixelSize: 14
        font.bold: true
        activeFocusOnTab: true
        KeyNavigation.tab: nameField

        enabled: nameField.text.trim().length > 0

        contentItem: RowLayout {
            anchors.centerIn: parent
            spacing: 6
            LucideIcon {
                name: "plus"
                size: 14
                color: addBtn.enabled ? "#FFFFFF" : Theme.textMuted
            }
            Text {
                text: "Log Activity"
                font: addBtn.font
                color: addBtn.enabled ? "#FFFFFF" : Theme.textMuted
            }
            Text {
                text: "↵"
                font.pixelSize: 13
                font.bold: true
                color: addBtn.enabled ? "#BAE6FD" : Theme.textMuted
                visible: addBtn.enabled
            }
        }

        background: Rectangle {
            radius: 8
            color: addBtn.enabled 
                   ? (addBtn.down ? Qt.darker(Theme.accentBlue, 1.2) : (btnHover.hovered ? Qt.lighter(Theme.accentBlue, 1.1) : Theme.accentBlue)) 
                   : Theme.surfaceBadge
            border.color: addBtn.enabled ? Theme.accentBlueBorder : Theme.borderDefault
            border.width: 1

            HoverHandler { id: btnHover }
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        onClicked: {
            activityService.addActivity(
                nameField.text.trim(),
                formRoot.selectedCategory,
                durationSpinBox.value,
                formRoot.selectedPriority
            )
            nameField.text = ""
            nameField.forceActiveFocus()
        }
    }

    // Bottom filler spacer
    Item { Layout.fillHeight: true }
}
