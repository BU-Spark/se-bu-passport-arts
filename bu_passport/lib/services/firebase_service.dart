import 'package:bu_passport/classes/user.dart';
import 'package:bu_passport/classes/categorized_events.dart';
import 'package:bu_passport/classes/event.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          eventTitle: eventData['eventTitle'] ?? '',
          eventURL: eventData['eventURL'] ?? '',
          eventPhoto: eventData['eventPhoto'] ?? '',
          eventLocation: eventData['eventLocation'] ?? '',
          eventStartTime: (eventData['eventStartTime'] as Timestamp?)!.toDate(),
          eventEndTime: (eventData['eventEndTime'] as Timestamp?)!.toDate(),
          eventDescription: eventData['eventDescription'] ?? '',
          savedUsers: List<String>.from(eventData['savedUsers'] ?? []),
        );

        eventList.add(event);
      });
      return eventList;
    } catch (error) {
      print("Failed to fetch events: $error");
      return [];
    }
  }

  static List<Event> fetchEventsForDay(DateTime date, List<Event> events) {
    return events.where((event) {
      return event.eventStartTime.day == date.day &&
          event.eventStartTime.month == date.month &&
          event.eventStartTime.year == date.year;
    }).toList();
  }

  static List<Event> filterEvents(List<Event> events, String query) {
    if (query.isEmpty) {
      return events;
    }
    return events.where((event) {
      return event.eventTitle.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  static Future<Users?> fetchUser(String userUID) async {
    final db = FirebaseFirestore.instance;

    try {
      DocumentSnapshot snapshot =
          await db.collection('users').doc(userUID).get();

      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        Users user = Users(
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          profileImageUrl: userData['profileImageUrl'],
          userBUID: userData['userBUID'],
          userEmail: userData['userEmail'],
          userSchool: userData['userSchool'],
          userUID: userData['userUID'],
          userYear: userData['userYear'],
          userPoints: userData['userPoints'],
          userPreferences: List<String>.from(userData['userPreferences'] ?? []),
          userSavedEvents:
              Map<String, dynamic>.from(userData['userSavedEvents'] ?? {}),
        );
        return user;
      }
    } catch (error) {
      print("Failed to fetch user details: $error");
    }
    return null;
  }

  static Future<void> saveEvent(String eventId) async {
    final db = FirebaseFirestore.instance;
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final userDoc = db.collection('users').doc(userUID);

    try {
      // Atomically add the new event ID to the user's saved events list
      // Atomically add the new event ID to the user's saved events map with value `false`
      await userDoc.update({
        'userSavedEvents.$eventId': false,
      });
      await db.collection('events').doc(eventId).update({
        'savedUsers': FieldValue.arrayUnion([userUID]),
      });
      print("Event saved successfully");
    } catch (error) {
      print("Failed to save event: $error");
    }
  }

  static Future<void> unsaveEvent(String eventId) async {
    final db = FirebaseFirestore.instance;
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final userDoc = db.collection('users').doc(userUID);

    try {
      // Atomically remove the event ID from the user's saved events list
      await userDoc.update({
        'userSavedEvents.$eventId': FieldValue.delete(),
      });
      await db.collection('events').doc(eventId).update({
        'savedUsers': FieldValue.arrayRemove([userUID]),
      });
      print("Event unsaving successful");
    } catch (error) {
      print("Failed to unsave event: $error");
    }
  }

  static Future<bool> hasUserSavedEvent(String userUID, String eventId) async {
    final db = FirebaseFirestore.instance;
    DocumentSnapshot userDocSnapshot =
        await db.collection('users').doc(userUID).get();

    if (userDocSnapshot.exists) {
      final userData = userDocSnapshot.data() as Map<String, dynamic>;
      print(userData['userSavedEvents']);
      Map<String, dynamic> savedEvents = userData['userSavedEvents'] ?? [];

      // Check if the eventId exists in the list
      return savedEvents.containsKey(eventId);
    }
    return false;
  }

  static Future<CategorizedEvents> fetchAndCategorizeEvents() async {
    final userUID = FirebaseAuth.instance.currentUser?.uid;

    if (userUID == null) {
      throw Exception("User is not logged in");
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userUID).get();
    if (!userDoc.exists) {
      throw Exception("User document does not exist");
    }

    final userData = userDoc.data();

    Map<String, dynamic> savedEvents = userData!['userSavedEvents'] ?? [];

    final now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final List<Event> attendedEvents = [];
    final List<Event> userSavedEvents = [];

    await Future.forEach(savedEvents.entries,
        (MapEntry<String, dynamic> entry) async {
      String eventId = entry.key;
      bool isCheckedIn = entry.value;

      Event? event = await fetchEventById(eventId);
      print(event?.eventTitle);
      if (event != null) {
        DateTime startOfDayEvent = DateTime(event.eventStartTime.year, event.eventStartTime.month, event.eventStartTime.day);
        if ((startOfDayEvent.isBefore(now) || startOfDayEvent.isAtSameMomentAs(today)) && isCheckedIn) {
          // Event has already occurred (attended)
          attendedEvents.add(event);
        } else {
          // Event is upcoming
          userSavedEvents.add(event);
        }
      }
    });

    return CategorizedEvents(
        attendedEvents: attendedEvents, userSavedEvents: userSavedEvents);
  }

  static Future<Event?> fetchEventById(String eventId) async {
    final FirebaseFirestore _db = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _db.collection('events').doc(eventId).get();
    if (snapshot.exists && snapshot.data() != null) {
      Map<String, dynamic> eventData = snapshot.data()!;
      Event event = Event(
        eventID: eventData['eventID'] ?? '',
        eventTitle: eventData['eventTitle'] ?? '',
        eventPhoto: eventData['eventPhoto'] ?? '',
        eventLocation: eventData['eventLocation'] ?? '',
        eventStartTime: (eventData['eventStartTime'] as Timestamp?)!.toDate(),
        eventEndTime: (eventData['eventEndTime'] as Timestamp?)!.toDate(),
        eventURL: eventData['eventURL'] ?? '',
        eventDescription: eventData['eventDescription'] ?? '',
        savedUsers: List<String>.from(eventData['savedUsers'] ?? []),
      );
      return event;
    }
    throw Exception("Event not found");
  }

  static void checkInUserForEvent(String eventID) {
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    if (userUID == null) {
      throw Exception("User is not logged in");
    }

    final db = FirebaseFirestore.instance;
    final userDoc = db.collection('users').doc(userUID);

    try {
      // Atomically add the new event ID to the user's saved events list
      userDoc.update({
        'userSavedEvents.$eventID': true,
      });
      print("Event check-in successful");
    } catch (error) {
      print("Failed to check-in for event: $error");
    }
  }

  static Future<bool> isUserCheckedInForEvent(
      String userUID, String eventId) async {
    final db = FirebaseFirestore.instance;
    DocumentSnapshot userDocSnapshot =
        await db.collection('users').doc(userUID).get();

    if (userDocSnapshot.exists) {
      final userData = userDocSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> savedEvents = userData['userSavedEvents'] ?? [];

      // Check if the eventId exists in the list
      return savedEvents.containsKey(eventId) && savedEvents[eventId];
    }
    return false;
  }
}
