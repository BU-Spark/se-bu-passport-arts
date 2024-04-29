import 'package:bu_passport/classes/user.dart';
import 'package:bu_passport/classes/categorized_events.dart';
import 'package:bu_passport/classes/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore db;

  const FirebaseService({required this.db});

  Future<List<Event>> fetchEvents() async {
    List<Event> eventList = [];

    try {
      QuerySnapshot snapshot = await this.db.collection('events').get();
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
          eventPoints: eventData['eventPoints'] ?? 0,
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

  List<Event> fetchEventsForDay(DateTime date, List<Event> events) {
    return events.where((event) {
      return event.eventStartTime.day == date.day &&
          event.eventStartTime.month == date.month &&
          event.eventStartTime.year == date.year;
    }).toList();
  }

  List<Event> filterEvents(List<Event> events, String query) {
    if (query.isEmpty) {
      return events;
    }
    return events.where((event) {
      return event.eventTitle.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<Users?> fetchUser(String userUID) async {
    try {
      DocumentSnapshot snapshot =
          await this.db.collection('users').doc(userUID).get();

      if (snapshot.exists) {
        print('Snapshot exists');
        final userData = snapshot.data() as Map<String, dynamic>;
        print('User Data: $userData'); // Print userData to see its contents

        Users user = Users(
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          userProfileURL: userData['userProfileURL'],
          userBUID: userData['userBUID'],
          userEmail: userData['userEmail'],
          userSchool: userData['userSchool'],
          userUID: userData['userUID'],
          userYear: userData['userYear'],
          userPoints: userData['userPoints'],
          userSavedEvents:
              Map<String, dynamic>.from(userData['userSavedEvents'] ?? {}),
        );
        print(user);
        return user;
      } else {
        print('Snapshot does not exist');
      }
    } catch (error) {
      print("Failed to fetch user details: $error");
    }
    return null;
  }

  Future<void> saveEvent(String eventId) async {
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final userDoc = this.db.collection('users').doc(userUID);

    try {
      // Atomically add the new event ID to the user's saved events list
      // Atomically add the new event ID to the user's saved events map with value `false`
      await userDoc.update({
        'userSavedEvents.$eventId': false,
      });
      await this.db.collection('events').doc(eventId).update({
        'savedUsers': FieldValue.arrayUnion([userUID]),
      });
      print("Event saved successfully");
    } catch (error) {
      print("Failed to save event: $error");
    }
  }

  Future<void> unsaveEvent(String eventId) async {
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final userDoc = this.db.collection('users').doc(userUID);

    try {
      // Atomically remove the event ID from the user's saved events list
      await userDoc.update({
        'userSavedEvents.$eventId': FieldValue.delete(),
      });
      await this.db.collection('events').doc(eventId).update({
        'savedUsers': FieldValue.arrayRemove([userUID]),
      });
      print("Event unsaving successful");
    } catch (error) {
      print("Failed to unsave event: $error");
    }
  }

  Future<bool> hasUserSavedEvent(String userUID, String eventId) async {
    DocumentSnapshot userDocSnapshot =
        await this.db.collection('users').doc(userUID).get();

    if (userDocSnapshot.exists) {
      final userData = userDocSnapshot.data() as Map<String, dynamic>;
      print(userData['userSavedEvents']);
      if (userData['userSavedEvents'] is Map) {
        Map<String, dynamic> savedEvents = userData['userSavedEvents'] != null
            ? Map<String, dynamic>.from(userData['userSavedEvents'])
            : {};

        // Check if the eventId exists in the list
        return savedEvents.containsKey(eventId);
      }
    }
    return false;
  }

  Future<CategorizedEvents> fetchAndCategorizeEvents() async {
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

    Map<String, dynamic> savedEvents = userData!['userSavedEvents'] ?? {};

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
        DateTime startOfDayEvent = DateTime(event.eventStartTime.year,
            event.eventStartTime.month, event.eventStartTime.day);
        if ((startOfDayEvent.isBefore(now) ||
                startOfDayEvent.isAtSameMomentAs(today)) &&
            isCheckedIn) {
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

  Future<Event?> fetchEventById(String eventId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await this.db.collection('events').doc(eventId).get();
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
        eventPoints: eventData['eventPoints'] ?? 0,
        savedUsers: List<String>.from(eventData['savedUsers'] ?? []),
      );
      return event;
    }
    throw Exception("Event not found");
  }

  void checkInUserForEvent(String eventID, int eventPoints) {
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    if (userUID == null) {
      throw Exception("User is not logged in");
    }

    final userDoc = this.db.collection('users').doc(userUID);

    try {
      // Atomically add the new event ID to the user's saved events list
      userDoc.update({
        'userSavedEvents.$eventID': true,
      });
      userDoc.update({
        'userPoints': FieldValue.increment(eventPoints),
      });
      print("Event check-in successful");
    } catch (error) {
      print("Failed to check-in for event: $error");
    }
  }

  Future<bool> isUserCheckedInForEvent(String userUID, String eventId) async {
    DocumentSnapshot userDocSnapshot =
        await this.db.collection('users').doc(userUID).get();

    if (userDocSnapshot.exists) {
      final userData = userDocSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> savedEvents = userData['userSavedEvents'] ?? {};

      // Check if the eventId exists in the list
      return savedEvents.containsKey(eventId) && savedEvents[eventId];
    }
    return false;
  }

  Future<void> updateUserProfileURL(String profileURL) async {
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    if (userUID == null) {
      throw Exception("User is not logged in");
    }

    final userDoc = this.db.collection('users').doc(userUID);

    try {
      await userDoc.update({
        'userProfileURL': profileURL,
      });
      print("Profile URL updated successfully");
    } catch (error) {
      print("Failed to update profile URL: $error");
    }
  }

  Future<List<Event>> fetchEventsFromNow() async {
    final now = DateTime.now();
    List<Event> eventList = [];

    try {
      QuerySnapshot snapshot = await this.db.collection('events').get();
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
          eventPoints: eventData['eventPoints'] ?? 0,
          savedUsers: List<String>.from(eventData['savedUsers'] ?? []),
        );

        eventList.add(event);
      });
      eventList =
          eventList.where((event) => event.eventEndTime.isAfter(now)).toList();
      return eventList;
    } catch (error) {
      print("Failed to fetch events: $error");
      return [];
    }
  }

  Future<List<Users>> fetchAllUsers() async {
    List<Users> users = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await this.db.collection('users').get();
      snapshot.docs.forEach((doc) {
        final userData = doc.data();
        print(userData);
        Users user = Users(
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          userBUID: userData['userBUID'],
          userEmail: userData['userEmail'],
          userSchool: userData['userSchool'],
          userUID: userData['userUID'],
          userYear: userData['userYear'],
          userSavedEvents:
              Map<String, dynamic>.from(userData['userSavedEvents'] ?? {}),
          userPoints: userData['userPoints'],
          userProfileURL: userData['userProfileURL'],
        );
        users.add(user);
      });
      return users;
    } catch (error) {
      print("Failed to fetch all users: $error");
      return [];
    }
  }
}
