// LucideIcon.qml — Reusable, vector-sharp Lucide SVG icon with dynamic theme tinting
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import ActivityTracker 1.0

Item {
    id: iconRoot

    property string name: ""
    property int size: 16
    property color color: Theme.textPrimary

    width: size
    height: size
    implicitWidth: size
    implicitHeight: size
    Layout.preferredWidth: size
    Layout.preferredHeight: size

    Image {
        id: rawIcon
        anchors.fill: parent
        // Qt 6 QTP0001 places resources under qrc:/qt/qml/ActivityTracker/, relative is ../../resources/icons/
        source: iconRoot.name.length > 0 ? ("../../resources/icons/" + iconRoot.name + ".svg") : ""
        sourceSize.width: Math.max(32, iconRoot.size * 2)
        sourceSize.height: Math.max(32, iconRoot.size * 2)
        smooth: true
        mipmap: true
        fillMode: Image.PreserveAspectFit
        visible: false
    }

    MultiEffect {
        anchors.fill: rawIcon
        source: rawIcon
        colorization: 1.0
        colorizationColor: iconRoot.color
        visible: rawIcon.status === Image.Ready
    }
}
