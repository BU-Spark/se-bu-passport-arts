import 'package:bu_passport/classes/user.dart';
import 'package:bu_passport/classes/categorized_events.dart';
import 'package:bu_passport/classes/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore db;

  const FirebaseService({required this.db});

  // Function to fetch events from Firestore

  Future<List<Event>> fetchEvents() async {
    // TODO: Update this function to get new field from event doc
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

  // Function to fetch events for a specific date from a list of events

  List<Event> fetchEventsForDay(DateTime date, List<Event> events) {
    return events.where((event) {
      return event.eventStartTime.day == date.day &&
          event.eventStartTime.month == date.month &&
          event.eventStartTime.year == date.year;
    }).toList();
  }

  // Function to filter events based on a search query

  List<Event> filterEvents(List<Event> events, String query) {
    if (query.isEmpty) {
      return events;
    }
    return events.where((event) {
      return event.eventTitle.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Function to fetch user details from Firestore

  Future<Users?> fetchUser(String userUID) async {
    // TODO: Update this function to get new field from user doc
    try {
      DocumentSnapshot snapshot =
          await this.db.collection('users').doc(userUID).get();

      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;

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
        return user;
      } else {
        print('Snapshot does not exist');
      }
    } catch (error) {
      print("Failed to fetch user details: $error");
    }
    return null;
  }

  // Function to save an event to userSavedEvents

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
    } catch (error) {
      print("Failed to save event: $error");
    }
  }

  // Function to unsave an event from userSavedEvents

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
    } catch (error) {
      print("Failed to unsave event: $error");
    }
  }

  // Function to check if a user has saved an event
  Future<bool> hasUserSavedEvent(String userUID, String eventId) async {
    DocumentSnapshot userDocSnapshot =
        await this.db.collection('users').doc(userUID).get();

    if (userDocSnapshot.exists) {
      final userData = userDocSnapshot.data() as Map<String, dynamic>;
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

  // Function to categorize events into attended and saved events

  Future<CategorizedEvents> fetchAndCategorizeEvents() async {
    //TODO: Update Display Logic
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

  // Function to fetch an event by its ID

  Future<Event?> fetchEventById(String eventId) async {
    // TODO: Update this function to get new field from event doc
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

  // Function to check in a user for an event
  void checkInUserForEvent(String eventID, int eventPoints) {
    // TODO: Update this function to separate check-ins from saved events
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

  // Function to check if a user has checked in for an event

  Future<bool> isUserCheckedInForEvent(String userUID, String eventId) async {
    // TODO: Update this function to check check-in status from the new separate field
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

  // Function to update the user's profile URL

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
    } catch (error) {
      print("Failed to update profile URL: $error");
    }
  }

  // Function to fetch events after current time for explore page

  Future<List<Event>> fetchEventsFromNow() async {
    // TODO: Update this function to get new field from event doc
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

  // Function to fetch all users

  Future<List<Users>> fetchAllUsers() async {
    // TODO: Update this function to get new field from user doc
    List<Users> users = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await this.db.collection('users').get();
      snapshot.docs.forEach((doc) {
        final userData = doc.data();
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
