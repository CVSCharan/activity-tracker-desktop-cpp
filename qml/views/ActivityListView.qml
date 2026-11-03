// ActivityListView.qml — scrollable list of activity cards

import QtQuick
import QtQuick.Controls
import "../components" as Components

ListView {
    id: listView
    clip: true
    spacing: 10

    model: activityModel

    topMargin:    16
    bottomMargin: 16
    leftMargin:   16
    rightMargin:  16

    delegate: Components.ActivityCard {
        width: listView.width - listView.leftMargin - listView.rightMargin

        // Explicit model.role binding ensures Qt 6 resolves model roles reliably
        activityName:      model.name
        activityCategory:  model.category
        activityDuration:  model.durationMinutes
        activityDone:      model.done
        activityIndex:     model.index

        onRemoveRequested: activityService.removeActivity(activityIndex)
        onCompleteRequested: activityService.markComplete(activityIndex)
    }

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
    }
}
