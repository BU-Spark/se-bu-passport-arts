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
  final List<String> savedUsers;

  Event({
    required this.eventID,
    required this.eventTitle,
    required this.eventPhoto,
    required this.eventLocation,
    required this.eventStartTime,
    required this.eventEndTime,
    required this.eventDescription,
    required this.eventURL,
    required this.savedUsers,
  });
}
