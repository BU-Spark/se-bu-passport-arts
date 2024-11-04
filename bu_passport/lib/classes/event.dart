import 'package:bu_passport/classes/session.dart';
import 'package:bu_passport/classes/sticker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String eventID;
  final String eventTitle;
  final String eventPhoto;
  final String eventLocation;
  final String eventDescription;
  final String eventURL;
  final int eventPoints;
  final List<Session> eventSessions;
  final List<Sticker> eventStickers;

  Event({
    required this.eventID,
    required this.eventTitle,
    required this.eventPhoto,
    required this.eventLocation,
    required this.eventDescription,
    required this.eventPoints,
    required this.eventURL,
    required this.eventSessions,
    required this.eventStickers,
  });

  @override
  String toString() {
    return 'NewEvent\n'
        '(ID: $eventID,\n'
        ' Title: $eventTitle, \n'
        'Photo URL: $eventPhoto, \n'
        'Location: $eventLocation, \n'
        //'Description: $eventDescription, \n'
        'Points: $eventPoints, \n'
        'Event URL: $eventURL, \n'
        'Sessions: [\n${eventSessions.map((session) => '  ${session.toString()}').join(',\n')}\n])';
  }

  bool hasSessionOnDay(DateTime date) {
    return eventSessions.any((session) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      return (session.sessionStartTime.isAfter(startOfDay) &&
          session.sessionStartTime.isBefore(endOfDay)) ||
          (session.sessionEndTime.isAfter(startOfDay) &&
              session.sessionEndTime.isBefore(endOfDay));
    });
  }

  bool hasUpcomingSessions(DateTime time) {

    // Check if there are any sessions that haven't ended
    for (var session in eventSessions) {
      if (session.sessionEndTime.isAfter(time)) {
        return true; // There's at least one active session
      }
    }
    return false; // No active sessions
  }
  bool isEventHappening() {
    DateTime now = DateTime.now();
    for (var session in eventSessions) {
      if (session.sessionStartTime.isBefore(now) && session.sessionEndTime.isAfter(now)) {
        return true; // Event is happening
      }
    }
    return false; // Event is not happening
  }
}
