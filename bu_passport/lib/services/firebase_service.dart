import 'dart:typed_data';

import 'package:bu_passport/classes/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../classes/categorized_events.dart';
import '../classes/event.dart';
import '../classes/session.dart';
import '../classes/sticker.dart';

class FirebaseService {
  final FirebaseFirestore db;
  static const EVENT_COLLECTION = "new_events";
  static const USER_COLLECTION = "users";
  static const ATTENDANCE_COLLECTION = "attendances";

  static const CHECKIN_PHOTO_PATH = "checkinPhotos";

  const FirebaseService({required this.db});

  // Function to fetch events from Firestore
  Future<List<Event>> fetchEvents() async {
    List<Event> eventList = [];

    try {
      QuerySnapshot snapshot = await this.db.collection(EVENT_COLLECTION).get();
      snapshot.docs.forEach((doc) {
        final eventData = doc.data() as Map<String, dynamic>;
        final sessionData = eventData['eventSessions'] as Map<String, dynamic>;

        List<Session> sessions = [];
        if (sessionData != null) {
          sessions = sessionData.entries.map((entry) {
            final sessionID = entry.key;
            final sessionDetails = entry.value as Map<String, dynamic>;

            return Session(
              sessionID: sessionID,
              sessionStartTime: sessionDetails['startTime'] != null
                  ? (sessionDetails['startTime'] as Timestamp).toDate()
                  : DateTime.now(), // Default if startTime is null
              sessionEndTime: sessionDetails['endTime'] != null
                  ? (sessionDetails['endTime'] as Timestamp).toDate()
                  : DateTime.now(), // Default if endTime is null
              savedUsers: sessionDetails['savedUsers'] != null
                  ? List<String>.from(sessionDetails['savedUsers'])
                  : [], // Default if null
            );
          }).toList();
        }

        Event event = Event(
          eventID: doc.id,
          eventTitle: eventData['eventTitle'] ?? '',
          eventURL: eventData['eventURL'] ?? '',
          eventPhoto: eventData['eventPhoto'] ?? '',
          eventLocation: eventData['eventLocation'] ?? '',
          eventDescription: eventData['eventDescription'] ?? '',
          eventPoints: eventData['eventPoints'] ?? 0,
          savedUsers: List<String>.from(eventData['savedUsers'] ?? []),
          eventSessions: sessions,
          eventStickers: (eventData['eventStickers'] as List<dynamic>?)
              ?.map((stickerName) => Sticker(name: stickerName as String))
              .toList() ?? [],
        );

        eventList.add(event);
      });
      return eventList;
    } catch (error) {
      print("Failed to fetch events: $error");
      return [];
    }
  }



  // Function to fetch events which have sessions happening on a particular day
  List<Event> fetchEventsForDay(DateTime date, List<Event> events) {
    return events.where((event) => event.hasSessionOnDay(date)).toList();
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
    try {
      DocumentSnapshot snapshot =
      await this.db.collection('users').doc(userUID).get();

      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;

        Map<String, bool> stickerData = Map<String, bool>.from(userData['userCollectedStickers'] ?? {});

        // Convert Map<String, bool> to Map<Sticker, bool>
        Map<Sticker, bool> stickerCollection = stickerData.map((name, owned) => MapEntry(Sticker(name: name), owned));
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
          admin: userData['admin'],
          userStickerCollection: stickerCollection,
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
      await this.db.collection(EVENT_COLLECTION).doc(eventId).update({
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
      await this.db.collection(EVENT_COLLECTION).doc(eventId).update({
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

    final List<Event> attendedEvents = [];
    final List<Event> userSavedEvents = [];

    await Future.forEach(savedEvents.entries,
            (MapEntry<String, dynamic> entry) async {
          String eventId = entry.key;
          Event? event = await fetchEventById(eventId);
          if (event != null) {
            userSavedEvents.add(event);
          }
        });

    final attendanceQuerySnapshot = await this.db.collection(ATTENDANCE_COLLECTION)
        .where('userID', isEqualTo: userUID)
        .get();

    for (var attendanceDoc in attendanceQuerySnapshot.docs) {
      final eventId = attendanceDoc['eventID'];

      // Fetch the event details using the event ID
      Event? event = await fetchEventById(eventId);
      if (event != null) {
        attendedEvents.add(event);
      }
    }

    return CategorizedEvents(
        attendedEvents: attendedEvents, userSavedEvents: userSavedEvents);
  }

  // Function to fetch an event by its ID
  Future<Event?> fetchEventById(String eventId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await this.db.collection(EVENT_COLLECTION).doc(eventId).get();
    if (snapshot.exists && snapshot.data() != null) {
      final eventData = snapshot.data() as Map<String, dynamic>;
      final sessionData = eventData['eventSessions'] as Map<String, dynamic>;

      List<Session> sessions = [];
      if (sessionData != null) {
        sessions = sessionData.entries.map((entry) {
          final sessionID = entry.key;
          final sessionDetails = entry.value as Map<String, dynamic>;

          return Session(
            sessionID: sessionID,
            sessionStartTime: sessionDetails['startTime'] != null
                ? (sessionDetails['startTime'] as Timestamp).toDate()
                : DateTime.now(), // Default if startTime is null
            sessionEndTime: sessionDetails['endTime'] != null
                ? (sessionDetails['endTime'] as Timestamp).toDate()
                : DateTime.now(), // Default if endTime is null
            savedUsers: sessionDetails['savedUsers'] != null
                ? List<String>.from(sessionDetails['savedUsers'])
                : [], // Default if null
          );
        }).toList();
      }

      Event event = Event(
        eventID: eventId,
        eventTitle: eventData['eventTitle'] ?? '',
        eventURL: eventData['eventURL'] ?? '',
        eventPhoto: eventData['eventPhoto'] ?? '',
        eventLocation: eventData['eventLocation'] ?? '',
        eventDescription: eventData['eventDescription'] ?? '',
        eventPoints: eventData['eventPoints'] ?? 0,
        savedUsers: List<String>.from(eventData['savedUsers'] ?? []),
        eventSessions: sessions,
        eventStickers: (eventData['eventStickers'] as List<dynamic>?)
            ?.map((stickerName) => Sticker(name: stickerName as String))
            .toList() ?? [],
      );
      return event;
    }
    throw Exception("Event not found");
  }



  // Function to check in a user for an event
  void checkInUserForEvent(String eventID, int eventPoints, List<Sticker> stickers) {
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final attendanceDocID = '${eventID}_$userUID';
    final attendanceDoc = this.db.collection(ATTENDANCE_COLLECTION).doc(attendanceDocID);
    if (userUID == null) {
      throw Exception("User is not logged in");
    }

    final userDoc = this.db.collection('users').doc(userUID);

    try {
      userDoc.update({
        'userPoints': FieldValue.increment(eventPoints),
      });
      attendanceDoc.set({
        'checkInTime': FieldValue.serverTimestamp(),
        'eventID': eventID,
        'userID': userUID,
      });
      for(Sticker s in stickers){
        addStickerToUserCollection(userUID, s);
      }
      //
    } catch (error) {
      print("Failed to check-in for event: $error");
    }
  }

  // Function to check if a user has checked in for an event
  Future<bool> isUserCheckedInForEvent(String userUID, String eventId) async {
    final attendanceDocID = '${eventId}_$userUID';
    final attendanceDoc = this.db.collection(ATTENDANCE_COLLECTION).doc(attendanceDocID);

    try {
      final docSnapshot = await attendanceDoc.get();
      return docSnapshot.exists;
    } catch (error) {
      print("Error checking attendance: $error");
      return true; // Return true in case of error (user not checked in)
    }
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
    final now = DateTime.now();
    List<Event> eventList = [];

    try {
      QuerySnapshot snapshot = await this.db.collection(EVENT_COLLECTION).get();
      snapshot.docs.forEach((doc) {
        final eventData = doc.data() as Map<String, dynamic>;
        final sessionData = eventData['eventSessions'] as Map<String, dynamic>;

        List<Session> sessions = [];
        if (sessionData != null) {
          sessions = sessionData.entries.map((entry) {
            final sessionID = entry.key;
            final sessionDetails = entry.value as Map<String, dynamic>;

            return Session(
              sessionID: sessionID,
              sessionStartTime: sessionDetails['startTime'] != null
                  ? (sessionDetails['startTime'] as Timestamp).toDate()
                  : DateTime.now(), // Default if startTime is null
              sessionEndTime: sessionDetails['endTime'] != null
                  ? (sessionDetails['endTime'] as Timestamp).toDate()
                  : DateTime.now(), // Default if endTime is null
              savedUsers: sessionDetails['savedUsers'] != null
                  ? List<String>.from(sessionDetails['savedUsers'])
                  : [], // Default if null
            );
          }).toList();
        }

        Event event = Event(
          eventID: doc.id,
          eventTitle: eventData['eventTitle'] ?? '',
          eventURL: eventData['eventURL'] ?? '',
          eventPhoto: eventData['eventPhoto'] ?? '',
          eventLocation: eventData['eventLocation'] ?? '',
          eventDescription: eventData['eventDescription'] ?? '',
          eventPoints: eventData['eventPoints'] ?? 0,
          savedUsers: List<String>.from(eventData['savedUsers'] ?? []),
          eventSessions: sessions,
          eventStickers: (eventData['eventStickers'] as List<dynamic>?)
              ?.map((stickerName) => Sticker(name: stickerName as String))
              .toList() ?? [],
        );

        eventList.add(event);
      });
      eventList =
          eventList.where((event) => event.hasUpcomingSessions(now)).toList();
      return eventList;
    } catch (error) {
      print("Failed to fetch events: $error");
      return [];
    }
  }

  // Function to fetch all users
  Future<List<Users>> fetchAllUsers() async {
    List<Users> users = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await this.db.collection('users').get();
      snapshot.docs.forEach((doc) {
        final userData = doc.data();
        Map<String, bool> stickerData = Map<String, bool>.from(userData['userCollectedStickers'] ?? {});

        // Convert Map<String, bool> to Map<Sticker, bool>
        Map<Sticker, bool> stickerCollection = stickerData.map((name, owned) => MapEntry(Sticker(name: name), owned));
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
          admin: userData['admin'],
          userStickerCollection: stickerCollection,
        );
        users.add(user);
      });
      return users;
    } catch (error) {
      print("Failed to fetch all users: $error");
      return [];
    }
  }


  Future<String> uploadCheckinImage(String eventID, Uint8List imageBytes) async {
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    String fileName = "checkin_${userUID}_${eventID}.jpg";

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(CHECKIN_PHOTO_PATH)
          .child(fileName);
      UploadTask uploadTask = ref.putData(imageBytes);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      final attendanceDoc = FirebaseFirestore.instance
          .collection('attendances')
          .doc('${eventID}_$userUID');

      await attendanceDoc.update({
        'checkInPhoto': downloadUrl,
      });
      return downloadUrl;

    } catch (e) {
      print("Error uploading image: $e");
      return "null";
    }
  }

  Future<void> addStickerToUserCollection(String userID, Sticker sticker) async {
    try {
      final userDocRef = db.collection(USER_COLLECTION).doc(userID);

      await db.runTransaction((transaction) async {
        final userDoc = await transaction.get(userDocRef);

        if (userDoc.exists) {
           Map<String, bool> stickers =
              (userDoc.data()?['userCollectedStickers'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value as bool)) ?? {};

          if (!stickers.containsKey(sticker.name)) {
            stickers[sticker.name] = true;

            transaction.set(userDocRef, {'userCollectedStickers': stickers}, SetOptions(merge: true));
          }
        } else {
          throw Exception("User document does not exist.");
        }
      });

      print("Sticker '${sticker.name}' added to user $userID's collection.");
    } catch (e) {
      print("Failed to add sticker: $e");
      throw Exception("Failed to add sticker to user's collection.");
    }
  }


}
