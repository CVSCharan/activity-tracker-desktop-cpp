// LoginView.qml — executive split-pane authentication screen
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ActivityTracker 1.0

Rectangle {
    id: loginRoot
    color: Theme.bgCanvas

    signal navigateToSignUp()
    signal navigateToForgotPassword()

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ── Left Brand & Value Proposition Hero Pane ──────────────────────────
        Rectangle {
            Layout.preferredWidth: parent.width > 900 ? 400 : 340
            Layout.fillHeight: true
            color: Theme.isDark ? "#090D16" : "#0F172A"
            border.color: Theme.borderDefault
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 40
                spacing: 24

                // Top Logo & App Title
                RowLayout {
                    spacing: 12
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 12
                        color: Theme.accentBlue
                        Text {
                            anchors.centerIn: parent
                            text: "⏱️"
                            font.pixelSize: 22
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: "CVS Tracker"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#FFFFFF"
                        }
                        Text {
                            text: "Executive Productivity Workstation"
                            font.pixelSize: 11
                            color: "#94A3B8"
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Inspirational Headline
                ColumnLayout {
                    spacing: 10
                    Text {
                        text: "Master your focus.\nOwn your workday."
                        font.pixelSize: 26
                        font.bold: true
                        color: "#F8FAFC"
                        lineHeight: 1.2
                    }
                    Text {
                        text: "Track high-leverage activities, run real-time focus timers, and sync effortlessly with serverless Neon PostgreSQL."
                        font.pixelSize: 13
                        color: "#94A3B8"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }

                // Feature Highlights Pills
                ColumnLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: 8
                        color: "#1E293B"
                        border.color: "#334155"
                        border.width: 1
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            spacing: 8
                            Text { text: "☁️"; font.pixelSize: 14 }
                            Text { text: "Neon Serverless Cloud Database"; color: "#E2E8F0"; font.pixelSize: 12; font.bold: true }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: 8
                        color: "#1E293B"
                        border.color: "#334155"
                        border.width: 1
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            spacing: 8
                            Text { text: "⏱️"; font.pixelSize: 14 }
                            Text { text: "Live Interactive Focus Countdown"; color: "#E2E8F0"; font.pixelSize: 12; font.bold: true }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: 8
                        color: "#1E293B"
                        border.color: "#334155"
                        border.width: 1
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            spacing: 8
                            Text { text: "📋"; font.pixelSize: 14 }
                            Text { text: "1-Click Daily Standup Markdown Export"; color: "#E2E8F0"; font.pixelSize: 12; font.bold: true }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Footer quote
                Text {
                    text: "Built with C++17, Qt 6.8 & QML"
                    color: "#64748B"
                    font.pixelSize: 11
                }
            }
        }

        // ── Right Authentication Form Card ────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.bgCanvas

            // Form container centered in right pane
            Item {
                id: formContainer
                anchors.centerIn: parent
                width: Math.min(parent.width - 60, 420)
                height: formColumn.implicitHeight

                // Shake animation on invalid login
                SequentialAnimation {
                    id: shakeAnimation
                    NumberAnimation { target: formContainer; property: "x"; to: formContainer.x - 12; duration: 40; easing.type: Easing.OutQuad }
                    NumberAnimation { target: formContainer; property: "x"; to: formContainer.x + 12; duration: 60; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: formContainer; property: "x"; to: formContainer.x - 8; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: formContainer; property: "x"; to: formContainer.x + 8; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: formContainer; property: "x"; to: formContainer.x; duration: 40; easing.type: Easing.InQuad }
                }

                ColumnLayout {
                    id: formColumn
                    anchors.fill: parent
                    spacing: 16

                    // Title
                    ColumnLayout {
                        spacing: 4
                        Text {
                            text: "Welcome Back"
                            font.pixelSize: 24
                            font.bold: true
                            color: Theme.textPrimary
                        }
                        Text {
                            text: "Enter your credentials to access your activity dashboard"
                            font.pixelSize: 13
                            color: Theme.textSecondary
                        }
                    }

                    // Error Banner (if error message exists)
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: errorRow.implicitHeight + 16
                        radius: 6
                        color: Theme.accentRedBg
                        border.color: Theme.accentRedBorder
                        border.width: 1
                        visible: authService.errorMessage.length > 0

                        RowLayout {
                            id: errorRow
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8
                            Text { text: "⚠️"; font.pixelSize: 13 }
                            Text {
                                text: authService.errorMessage
                                color: Theme.accentRed
                                font.pixelSize: 12
                                font.bold: true
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Email Field
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Email Address"; color: Theme.textSecondary; font.pixelSize: 12; font.bold: true }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 44
                            radius: 8
                            color: emailInput.activeFocus ? (Theme.isDark ? "#121A28" : "#F8FAFC") : Theme.surfaceInput
                            border.color: emailInput.activeFocus ? Theme.accentBlue : Theme.borderDefault
                            border.width: emailInput.activeFocus ? 2 : 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                Text { text: "✉️"; font.pixelSize: 13; opacity: emailInput.activeFocus ? 1.0 : 0.6 }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "charan@cvs.com"
                                        color: Theme.textMuted
                                        font.pixelSize: 13
                                        visible: emailInput.text.length === 0
                                        opacity: emailInput.activeFocus ? 0.35 : 0.75
                                    }

                                    TextField {
                                        id: emailInput
                                        anchors.fill: parent
                                        verticalAlignment: TextInput.AlignVCenter
                                        color: Theme.textPrimary
                                        font.pixelSize: 13
                                        background: null
                                        placeholderText: ""
                                        selectByMouse: true
                                        text: "charan@cvs.com" // Pre-filled with seed user for convenience
                                    }
                                }
                            }
                        }
                    }

                    // Password Field
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Password"; color: Theme.textSecondary; font.pixelSize: 12; font.bold: true }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 44
                            radius: 8
                            color: passwordInput.activeFocus ? (Theme.isDark ? "#121A28" : "#F8FAFC") : Theme.surfaceInput
                            border.color: passwordInput.activeFocus ? Theme.accentBlue : Theme.borderDefault
                            border.width: passwordInput.activeFocus ? 2 : 1

                            property bool showPassword: false

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                Text { text: "🔒"; font.pixelSize: 13; opacity: passwordInput.activeFocus ? 1.0 : 0.6 }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "••••••••••••"
                                        color: Theme.textMuted
                                        font.pixelSize: 13
                                        visible: passwordInput.text.length === 0
                                        opacity: passwordInput.activeFocus ? 0.35 : 0.75
                                    }

                                    TextField {
                                        id: passwordInput
                                        anchors.fill: parent
                                        verticalAlignment: TextInput.AlignVCenter
                                        color: Theme.textPrimary
                                        font.pixelSize: 13
                                        background: null
                                        placeholderText: ""
                                        selectByMouse: true
                                        echoMode: parent.parent.showPassword ? TextInput.Normal : TextInput.Password
                                        text: "Password123!" // Pre-filled with seed password for easy testing

                                        onAccepted: submitBtn.clicked()
                                    }
                                }

                                // Show / Hide Password Eye Toggle
                                Rectangle {
                                    implicitWidth: 24
                                    implicitHeight: 24
                                    radius: 12
                                    color: eyeHover.hovered ? Theme.surfaceCardHover : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.parent.parent.showPassword ? "👁️" : "👁️‍🗨️"
                                        font.pixelSize: 12
                                        opacity: eyeHover.hovered ? 1.0 : 0.6
                                    }

                                    HoverHandler { id: eyeHover }
                                    TapHandler {
                                        onTapped: parent.parent.parent.showPassword = !parent.parent.parent.showPassword
                                    }
                                }
                            }
                        }
                    }

                    // Remember Me & Forgot Password Row
                    RowLayout {
                        Layout.fillWidth: true

                        CheckBox {
                            id: rememberBox
                            checked: true
                            text: "Remember me"
                            font.pixelSize: 12
                            Material.accent: Theme.accentBlue
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "Forgot password?"
                            font.pixelSize: 12
                            color: forgotHover.hovered ? Theme.accentBlue : Theme.textSecondary
                            font.bold: true

                            HoverHandler { id: forgotHover }
                            TapHandler { onTapped: loginRoot.navigateToForgotPassword() }
                        }
                    }

                    // Submit Button
                    Button {
                        id: submitBtn
                        Layout.fillWidth: true
                        implicitHeight: 46
                        font.pixelSize: 14
                        font.bold: true

                        contentItem: Text {
                            text: "Sign In →"
                            color: "#FFFFFF"
                            font.bold: true
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 8
                            color: submitBtn.down ? Qt.darker(Theme.accentBlue, 1.2) : (subHover.hovered ? Qt.lighter(Theme.accentBlue, 1.1) : Theme.accentBlue)
                            HoverHandler { id: subHover }
                        }

                        onClicked: {
                            const ok = authService.login(emailInput.text, passwordInput.text, rememberBox.checked);
                            if (!ok) {
                                shakeAnimation.start()
                            }
                        }
                    }

                    // Divider: or Quick Demo
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        Layout.bottomMargin: 4
                        spacing: 12

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderDefault }
                        Text { text: "or test instantly"; font.pixelSize: 11; color: Theme.textMuted }
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderDefault }
                    }

                    // 1-Click Quick Demo Mode Button
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 40
                        radius: 8
                        color: demoHover.hovered ? Theme.surfaceCardHover : Theme.surfaceBadge
                        border.color: Theme.accentBlueBorder
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Text { text: "⚡"; font.pixelSize: 13 }
                            Text {
                                text: "1-Click Demo Login (Charan Developer)"
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.accentBlue
                            }
                        }

                        HoverHandler { id: demoHover }
                        TapHandler {
                            onTapped: authService.loginDemoUser()
                        }
                    }

                    // Navigate to Sign Up Link
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 8
                        spacing: 4

                        Text {
                            text: "Don't have an account?"
                            color: Theme.textSecondary
                            font.pixelSize: 12
                        }

                        Text {
                            text: "Create account"
                            color: Theme.accentBlue
                            font.pixelSize: 12
                            font.bold: true

                            HoverHandler { id: signUphover }
                            TapHandler { onTapped: loginRoot.navigateToSignUp() }
                        }
                    }
                }
            }
        }
    }
}
