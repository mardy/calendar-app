import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt

PathView {
    id: eventView

    property var currentDayStart: (new Date()).midnight()

    signal incrementCurrentDay
    signal decrementCurrentDay

    property bool expanded: false

    signal compress()
    signal expand()
    signal newEvent()

    readonly property real visibleHeight: parent.height - y

    QtObject {
        id: intern
        property int currentIndexSaved: 0
        property int currentIndex: 0
        property var currentDayStart: (new Date()).midnight()
    }

    onCurrentIndexChanged: {
        var delta = currentIndex - intern.currentIndexSaved
        if (intern.currentIndexSaved == count - 1 && currentIndex == 0) delta = 1
        if (intern.currentIndexSaved == 0 && currentIndex == count - 1) delta = -1
        intern.currentIndexSaved = currentIndex
        if (delta > 0) incrementCurrentDay()
        else decrementCurrentDay()
    }

    onCurrentDayStartChanged: {
        if (!moving) intern.currentDayStart = currentDayStart
    }

    onMovementEnded: {
        intern.currentDayStart = currentDayStart
        intern.currentIndex = currentIndex
    }

    preferredHighlightBegin: 0.5
    preferredHighlightEnd: 0.5
    highlightRangeMode: PathView.StrictlyEnforceRange

    path: Path {
        startX: -eventView.width; startY: eventView.height / 2
        PathLine { relativeX: eventView.width; relativeY: 0 }
        PathLine { relativeX: eventView.width; relativeY: 0 }
        PathLine { relativeX: eventView.width; relativeY: 0 }
    }

    snapMode: PathView.SnapOneItem

    model: 3

    delegate: DiaryView {
        id: diaryView

        width: eventView.width
        height: eventView.height

        dayStart: {
            if (index == intern.currentIndex) return intern.currentDayStart
            var previousIndex = intern.currentIndex > 0 ? intern.currentIndex - 1 : 2
            if (index == previousIndex) return intern.currentDayStart.addDays(-1)
            return intern.currentDayStart.addDays(1)
        }

        expanded: eventView.expanded

        onExpand: eventView.expand()
        onCompress: eventView.compress()
        onNewEvent: eventView.newEvent()
    }
}