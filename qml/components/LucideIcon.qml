// LucideIcon.qml — Reusable, vector-sharp Lucide SVG icon with dynamic theme tinting
import QtQuick
import QtQuick.Effects
import ActivityTracker 1.0

Item {
    id: iconRoot

    property string name: ""
    property int size: 16
    property color color: Theme.textPrimary

    implicitWidth: size
    implicitHeight: size

    Image {
        id: rawIcon
        anchors.fill: parent
        source: iconRoot.name.length > 0 ? ("qrc:/ActivityTracker/resources/icons/" + iconRoot.name + ".svg") : ""
        sourceSize.width: iconRoot.size * 2
        sourceSize.height: iconRoot.size * 2
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
