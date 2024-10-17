import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String eventID;
  final String eventTitle;
  final String eventPhoto;
  final String eventLocation;
  final String eventDescription;
  final String eventURL;
  final DateTime eventStartTime;
  final DateTime eventEndTime;
  final int eventPoints;
  final List<String> savedUsers;
  final List<String> attendedUsers;

  Event({
    required this.eventID,
    required this.eventTitle,
    required this.eventPhoto,
    required this.eventLocation,
    required this.eventStartTime,
    required this.eventEndTime,
    required this.eventDescription,
    required this.eventPoints,
    required this.eventURL,
    required this.savedUsers,
    required this.attendedUsers,
  });
}
