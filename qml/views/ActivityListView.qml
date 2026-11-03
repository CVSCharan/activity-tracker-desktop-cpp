// ActivityListView.qml — scrollable list of activity cards

import QtQuick
import QtQuick.Controls
import "../components" as Components

ListView {
    id: listView
    clip: true
    spacing: 10

    model: activityModel

    topMargin:    0
    bottomMargin: 10
    leftMargin:   0
    rightMargin:  0

    delegate: Components.ActivityCard {
        width: listView.width

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
