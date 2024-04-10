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
          userRegisteredEvents:
              Map<String, dynamic>.from(userData['userRegisteredEvents'] ?? {}),
        );
        return user;
      }
    } catch (error) {
      print("Failed to fetch user details: $error");
    }
    return null;
  }

  static Future<void> registerForEvent(String eventId) async {
    final db = FirebaseFirestore.instance;
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final userDoc = db.collection('users').doc(userUID);

    try {
      // Atomically add the new event ID to the user's registered events list
      // Atomically add the new event ID to the user's registered events map with value `false`
      await userDoc.update({
        'userRegisteredEvents.$eventId': false,
      });
      await db.collection('events').doc(eventId).update({
        'registeredUsers': FieldValue.arrayUnion([userUID]),
      });
      print("Event registration successful");
    } catch (error) {
      print("Failed to register for event: $error");
    }
  }

  static Future<void> unregisterFromEvent(String eventId) async {
    final db = FirebaseFirestore.instance;
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final userDoc = db.collection('users').doc(userUID);

    try {
      // Atomically remove the event ID from the user's registered events list
      await userDoc.update({
        'userRegisteredEvents.$eventId': FieldValue.delete(),
      });
      await db.collection('events').doc(eventId).update({
        'registeredUsers': FieldValue.arrayRemove([userUID]),
      });
      print("Event unregistration successful");
    } catch (error) {
      print("Failed to unregister from event: $error");
    }
  }

  static Future<bool> isUserRegisteredForEvent(
      String userUID, String eventId) async {
    final db = FirebaseFirestore.instance;
    DocumentSnapshot userDocSnapshot =
        await db.collection('users').doc(userUID).get();

    if (userDocSnapshot.exists) {
      final userData = userDocSnapshot.data() as Map<String, dynamic>;
      print(userData['userRegisteredEvents']);
      Map<String, dynamic> registeredEvents =
          userData['userRegisteredEvents'] ?? [];

      // Check if the eventId exists in the list
      return registeredEvents.containsKey(eventId);
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

    Map<String, dynamic> registeredEvents =
        userData!['userRegisteredEvents'] ?? [];

    final now = DateTime.now();

    final List<Event> attendedEvents = [];
    final List<Event> upcomingEvents = [];

    await Future.forEach(registeredEvents.entries,
        (MapEntry<String, dynamic> entry) async {
      String eventId = entry.key;
      bool isCheckedIn = entry.value;

      Event? event = await fetchEventById(eventId);
      print(event?.eventTitle);
      if (event != null) {
        if (event.eventStartTime.isBefore(now) && isCheckedIn) {
          // Event has already occurred (attended)
          attendedEvents.add(event);
        } else {
          // Event is upcoming
          upcomingEvents.add(event);
        }
      }
    });

    return CategorizedEvents(
        attendedEvents: attendedEvents, upcomingEvents: upcomingEvents);
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
        registeredUsers: List<String>.from(eventData['registeredUsers'] ?? []),
      );
      return event;
    }
    throw Exception("Event not found");
  }

  static Future<List<String>> fetchUserRegisteredEventIds(String userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    List<String> registeredEventIds =
        List<String>.from(userDoc.data()?['registeredEvents'] ?? []);
    return registeredEventIds;
  }

  static void checkInUserForEvent(String eventID) {
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    if (userUID == null) {
      throw Exception("User is not logged in");
    }

    final db = FirebaseFirestore.instance;
    final userDoc = db.collection('users').doc(userUID);

    try {
      // Atomically add the new event ID to the user's registered events list
      userDoc.update({
        'userRegisteredEvents.$eventID': true,
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
      Map<String, dynamic> registeredEvents =
          userData['userRegisteredEvents'] ?? [];

      // Check if the eventId exists in the list
      return registeredEvents.containsKey(eventId) && registeredEvents[eventId];
    }
    return false;
  }
}
