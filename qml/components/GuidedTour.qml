// GuidedTour.qml — Interactive spotlight walkthrough for executive workstation onboarding
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import ActivityTracker 1.0

Item {
    id: tourRoot
    anchors.fill: parent
    z: 99999 // Always on top of all workspace views

    property bool active: false
    property int currentStep: 0

    // References to target components passed from main.qml
    property var stepTargets: []

    signal tourCompleted()
    signal tourSkipped()

    visible: opacity > 0.01
    opacity: active ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    focus: active

    // ── Tour Steps Definition ─────────────────────────────────────────────────
    readonly property var steps: [
        {
            title: "Floating Task Deck",
            icon: "plus",
            desc: "Rapidly capture your work with instant category tags and duration shortcuts (+15m, +30m, +45m, +60m). You can dock this deck to the left or right, or collapse it into a slim rail.",
            shortcut: "Keyboard: Press 'Tab' to move between fields, 'Enter' to submit."
        },
        {
            title: "Executive KPI Dashboard",
            icon: "flame",
            desc: "Monitor your high-level progress at a glance: total activities logged, goal completion percentage, active pending items, and total minutes tracked.",
            shortcut: "Live metric computations automatically synchronize with C++ model."
        },
        {
            title: "Instant Filters & Search",
            icon: "search",
            desc: "Zero-latency filtering across all tasks. Switch between 'In Progress', 'Done', and categories, or query by timeframe: 'Today', 'Last 7 Days', or 'All Time'.",
            shortcut: "Shortcut: Press 'Ctrl+F' to jump directly to instant search."
        },
        {
            title: "Interactive Task Lifecycle",
            icon: "zap",
            desc: "Manage tasks smoothly with full lifecycle badges: Todo ▾, In Progress ▾, and Completed ▾. Quickly extend durations with '+15m' or reopen finished activities with one click.",
            shortcut: "Click the status badge on any card to switch state or create extensions."
        },
        {
            title: "Workstation Customization",
            icon: "sun",
            desc: "Tailor your workstation experience: toggle high-contrast Dark & Light themes, dock the sidebar on the Left or Right, or trigger database refresh with F5.",
            shortcut: "Shortcut: Press 'F5' to refresh, 'Ctrl+Z' to undo accidental deletions."
        }
    ]

    function startTour() {
        currentStep = 0
        active = true
        forceActiveFocus()
    }

    function nextStep() {
        if (currentStep < steps.length - 1) {
            currentStep++
        } else {
            finishTour()
        }
    }

    function prevStep() {
        if (currentStep > 0) {
            currentStep--
        }
    }

    function finishTour() {
        active = false
        tourCompleted()
    }

    function skipTour() {
        active = false
        tourSkipped()
    }

    // ── Keyboard Traversal ────────────────────────────────────────────────────
    Keys.onEscapePressed: (event) => { skipTour(); event.accepted = true; }
    Keys.onRightPressed: (event) => { nextStep(); event.accepted = true; }
    Keys.onLeftPressed: (event) => { prevStep(); event.accepted = true; }
    Keys.onReturnPressed: (event) => { nextStep(); event.accepted = true; }
    Keys.onSpacePressed: (event) => { nextStep(); event.accepted = true; }

    // ── Dimmed Canvas Backdrop ────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: Theme.isDark ? "#D0070B12" : "#B80F172A"
        Behavior on color { ColorAnimation { duration: 200 } }

        // Clicking outside advances or closes
        MouseArea {
            anchors.fill: parent
            onClicked: { /* Keep modal focused */ }
        }
    }

    // ── Active Target Geometry Tracking ───────────────────────────────────────
    readonly property var currentTarget: (stepTargets && stepTargets.length > currentStep) ? stepTargets[currentStep] : null

    readonly property rect targetRect: {
        if (!currentTarget || !tourRoot.active) {
            return Qt.rect(tourRoot.width / 2 - 100, tourRoot.height / 2 - 50, 200, 100)
        }
        try {
            const pt = currentTarget.mapToItem(tourRoot, 0, 0)
            return Qt.rect(pt.x, pt.y, currentTarget.width, currentTarget.height)
        } catch (e) {
            return Qt.rect(tourRoot.width / 2 - 100, tourRoot.height / 2 - 50, 200, 100)
        }
    }

    // ── Spotlight Cutout & Animated Beacon Ring ───────────────────────────────
    Rectangle {
        id: spotlightRing
        x: targetRect.x - 8
        y: targetRect.y - 8
        width: targetRect.width + 16
        height: targetRect.height + 16
        radius: 16
        color: "transparent"
        border.color: Theme.accentBlue
        border.width: 2

        Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        // Subtle glowing pulse
        SequentialAnimation on border.color {
            loops: Animation.Infinite
            ColorAnimation { from: Theme.accentBlue; to: Theme.accentBlueBorder; duration: 1000 }
            ColorAnimation { from: Theme.accentBlueBorder; to: Theme.accentBlue; duration: 1000 }
        }
    }

    // ── Floating Tour Dialog Card ─────────────────────────────────────────────
    Rectangle {
        id: dialogCard
        width: 440
        implicitHeight: dialogLayout.implicitHeight + 36
        radius: 16
        color: Theme.surfaceCard
        border.color: Theme.accentBlueBorder
        border.width: 1

        // Drop shadow for elevated depth
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Theme.isDark ? "#80000000" : "#25000000"
            shadowBlur: 0.8
            shadowVerticalOffset: 6
        }

        // Intelligently position dialog relative to the spotlighted area
        x: {
            const idealX = targetRect.x + (targetRect.width - width) / 2
            return Math.max(20, Math.min(tourRoot.width - width - 20, idealX))
        }

        y: {
            // If target is in top half of screen, place dialog below it; otherwise place above
            if (targetRect.y + targetRect.height + height + 24 < tourRoot.height) {
                return targetRect.y + targetRect.height + 16
            } else if (targetRect.y - height - 16 > 10) {
                return targetRect.y - height - 16
            } else {
                return (tourRoot.height - height) / 2
            }
        }

        Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        ColumnLayout {
            id: dialogLayout
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            // Header: Step Badge + Progress Dots + Close Button
            RowLayout {
                Layout.fillWidth: true

                // Step Badge
                Rectangle {
                    radius: 10
                    implicitWidth: stepRow.implicitWidth + 14
                    implicitHeight: 22
                    color: Theme.accentBlueBg
                    border.color: Theme.accentBlueBorder
                    border.width: 1

                    RowLayout {
                        id: stepRow
                        anchors.centerIn: parent
                        spacing: 4
                        LucideIcon {
                            name: "sparkles"
                            size: 11
                            color: Theme.accentBlue
                        }
                        Text {
                            text: "Step " + (tourRoot.currentStep + 1) + " of " + tourRoot.steps.length
                            font.pixelSize: 11
                            font.bold: true
                            color: Theme.accentBlue
                        }
                    }
                }

                // Progress Indicator Dots
                Row {
                    Layout.leftMargin: 8
                    spacing: 5
                    Repeater {
                        model: tourRoot.steps.length
                        delegate: Rectangle {
                            width: index === tourRoot.currentStep ? 16 : 6
                            height: 6
                            radius: 3
                            color: index === tourRoot.currentStep ? Theme.accentBlue : Theme.borderDefault
                            Behavior on width { NumberAnimation { duration: 150 } }
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Close / Skip Button (X)
                Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: 13
                    color: closeHover.hovered ? Theme.surfaceBadge : "transparent"
                    LucideIcon {
                        anchors.centerIn: parent
                        name: "x"
                        size: 13
                        color: Theme.textMuted
                    }
                    HoverHandler { id: closeHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: tourRoot.skipTour() }
                    ToolTip.visible: closeHover.hovered
                    ToolTip.text: "Close Tour (Esc)"
                    ToolTip.delay: 200
                }
            }

            // Title with Icon
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    width: 32
                    height: 32
                    radius: 8
                    color: Theme.accentBlueBg
                    border.color: Theme.accentBlueBorder
                    border.width: 1

                    LucideIcon {
                        anchors.centerIn: parent
                        name: tourRoot.steps[tourRoot.currentStep].icon
                        size: 16
                        color: Theme.accentBlue
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: tourRoot.steps[tourRoot.currentStep].title
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.textPrimary
                }
            }

            // Educational Description
            Text {
                Layout.fillWidth: true
                text: tourRoot.steps[tourRoot.currentStep].desc
                font.pixelSize: 13
                color: Theme.textSecondary
                wrapMode: Text.WordWrap
                lineHeight: 1.35
            }

            // Shortcut / Pro-Tip Callout
            Rectangle {
                Layout.fillWidth: true
                radius: 8
                implicitHeight: tipRow.implicitHeight + 14
                color: Theme.isDark ? "#141C2B" : "#F1F5F9"
                border.color: Theme.borderSubtle
                border.width: 1

                RowLayout {
                    id: tipRow
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    LucideIcon {
                        Layout.alignment: Qt.AlignVCenter
                        name: "zap"
                        size: 13
                        color: Theme.accentAmber
                    }

                    Text {
                        Layout.fillWidth: true
                        text: tourRoot.steps[tourRoot.currentStep].shortcut
                        font.pixelSize: 11
                        font.bold: false
                        color: Theme.textMuted
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // Bottom Navigation Actions
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 8

                // Skip button
                Text {
                    text: "Skip Tour"
                    font.pixelSize: 12
                    font.bold: true
                    color: skipHover.hovered ? Theme.textPrimary : Theme.textMuted
                    HoverHandler { id: skipHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: tourRoot.skipTour() }
                }

                Item { Layout.fillWidth: true }

                // Back button (shown if not first step)
                Rectangle {
                    visible: tourRoot.currentStep > 0
                    implicitWidth: 80
                    implicitHeight: 32
                    radius: 8
                    color: backHover.hovered ? Theme.surfaceBadge : "transparent"
                    border.color: Theme.borderDefault
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "← Back"
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.textSecondary
                    }

                    HoverHandler { id: backHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: tourRoot.prevStep() }
                }

                // Next / Finish button
                Rectangle {
                    implicitWidth: tourRoot.currentStep === tourRoot.steps.length - 1 ? 120 : 96
                    implicitHeight: 32
                    radius: 8
                    color: nextHover.hovered ? Qt.lighter(Theme.accentBlue, 1.1) : Theme.accentBlue

                    scale: nextHover.hovered ? 1.04 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: tourRoot.currentStep === tourRoot.steps.length - 1 ? "Finish Tour 🎉" : "Next →"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#FFFFFF"
                        }
                    }

                    HoverHandler { id: nextHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: tourRoot.nextStep() }
                }
            }
        }
    }
}
