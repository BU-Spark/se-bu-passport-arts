import 'package:bu_passport/classes/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static Future<List<Event>> fetchEvents() async {
    final db = FirebaseFirestore.instance;
    List<Event> eventList = [];

    try {
      QuerySnapshot snapshot = await db.collection('events').get();
      snapshot.docs.forEach((doc) {
        final eventData = doc.data() as Map<String, dynamic>;
        Event event = Event(
          eventID: doc.id,
          eventTitle: eventData['eventTitle'],
          eventPhoto: eventData['eventPhoto'],
          eventLocation: eventData['eventLocation'],
          eventStartTime: eventData['eventStartTime'],
          eventEndTime: eventData['eventEndTime'],
          eventDescription: eventData['eventDescription'],
          // eventTags: List<String>.from(eventData['eventTags'] ?? []),
          registeredUsers:
              List<String>.from(eventData['registeredUsers'] ?? []),
        );
        eventList.add(event);
      });
      return eventList;
    } catch (error) {
      print("Failed to fetch events: $error");
      return [];
    }
  }

  static List<Event> filterEvents(List<Event> events, String query) {
    if (query.isEmpty) {
      return events;
    }
    return events.where((event) {
      return event.eventTitle.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
