import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String eventId;
  final String eventName;
  final String eventPhoto;
  final String eventLocation;
  final DateTime eventTime;
  final List<String> eventTags;
  final List<String> registeredUsers;

  Event({
    required this.eventId,
    required this.eventName,
    required this.eventPhoto,
    required this.eventLocation,
    required this.eventTime,
    required this.eventTags,
    required this.registeredUsers,
  });

  factory Event.fromFirestore(Map<String, dynamic> data) {
    return Event(
      eventId: data[
          'eventID'], // Ensure you have an 'eventId' or similar identifier in Firestore
      eventName: data['eventName'] as String? ?? 'Default Name',
      eventPhoto: data['eventPhoto'],
      eventLocation: data['eventLocation'] as String? ?? 'Default Location',
      eventTime: (data['eventTime'] as Timestamp)
          .toDate(), // Converting Timestamp to DateTime
      eventTags: List<String>.from(data['eventTags'] ?? []),
      registeredUsers: List<String>.from(data['registeredUsers'] ?? []),
    );
  }
}
