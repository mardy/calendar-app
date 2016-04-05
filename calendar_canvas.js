.pragma library
.import "dateExt.js" as DateExt

function minutesSince(since, until)
{
    var sinceTime = new Date(since)
    sinceTime.setSeconds(0)
    var untilTime =  new Date(until)
    untilTime.setSeconds(0)

    // We need that to avoid problems with DST times
    // Without this the event will be showed in the wrong time on the day that the DST occur
    // Example: 27/03 (Europe/Paris)
    if (sinceTime.isSameDay(untilTime)) {
        return (untilTime.getHours() * 60) + untilTime.getMinutes();
    }

    var sinceTimeInSecs = sinceTime.getTime()
    var untilTimeInSecs = untilTime.getTime()

    // limit to since day minutes
    untilTimeInSecs = Math.min(sinceTime.endOfDay().getTime(), untilTimeInSecs)

    // calculate the time in minutes of this event
    var totalSecs =  untilTimeInSecs - sinceTimeInSecs
    if (totalSecs > 0)
        return (totalSecs / 60000)

    return 0
}

function parseDayEvents(date, itemsOfTheDay)
{
    var eventsInfo = []
    for(var c=0; c < itemsOfTheDay.length; c++) {
        var event = itemsOfTheDay[c]
        if (event.allDay)
            continue

        var eventStartTimeInMinutes = minutesSince(date, event.startDateTime)
        var eventEndTimeInMinutes = minutesSince(date, isNaN(event.endDateTime.getTime()) ? event.startDateTime : event.endDateTime)

        // avoid to draw events too small
        if ((eventEndTimeInMinutes - eventStartTimeInMinutes) < 20)
            eventEndTimeInMinutes = eventStartTimeInMinutes + 20

        eventsInfo.push({'eventId': event.itemId,
                         'eventStartTime': event.startDateTime.getTime(),
                         'eventEndTime': isNaN(event.endDateTime.getTime()) ? event.startDateTime.getTime() : event.endDateTime.getTime(),
                         'startTime': eventStartTimeInMinutes,
                         'endTime': eventEndTimeInMinutes,
                         'endTimeInSecs': event.endDateTime.getTime(),
                         'y': -1,
                         'intersectionCount': 0,
                         'width': 1.0})
    }

    return eventsInfo
}
