import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/classes/user.dart';
import 'package:bu_passport/pages/login_page.dart';
import 'package:bu_passport/services/firebase_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'mock.dart';

void main() {
  group('FirestoreService', () {
    FakeFirebaseFirestore? fakeFirebaseFirestore;
    setupFirebaseAuthMocks();

    setUp(() {
      fakeFirebaseFirestore = FakeFirebaseFirestore();
    });

    // Testing for fetchEvents in firebase_service
    test('fetchEvents gets data from a given collection', () async {
      final FirebaseService firebaseService =
          FirebaseService(db: fakeFirebaseFirestore!);

      const String collectionPath = 'events';
      const String documentPath = 'event1';

      Map<String, dynamic> data = {
        "eventID": "1",
        "eventTitle": "Test Event",
        "eventPhoto": "assets/images/arts/image9.jpeg",
        "eventLocation": "Test Location",
        "eventStartTime": DateTime(2024, 4, 18, 10, 0),
        "eventEndTime": DateTime(2024, 4, 18, 12, 0),
        "eventDescription": "Test Description",
        "eventPoints": 30,
        "eventURL": "http://example.com",
        "savedUsers": ["user1", "user2"]
      };

      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(documentPath)
          .set(data);

      final List<Event> eventList = (await firebaseService.fetchEvents());
      print(eventList[0].eventID);
      expect(eventList.length, 1); // Make sure only one event is fetched
    });

    // Testing for fetchUser in firebase_service
    test('fetchUser gets data from a given collection', () async {
      final FirebaseService firebaseService =
          FirebaseService(db: fakeFirebaseFirestore!);

      const String collectionPath = 'users';
      const String documentPath = 'user1';

      final Map<String, dynamic> userData = {
        'firstName': 'John',
        'lastName': 'Doe',
        'userProfileURL': 'https://example.com/profile.jpg',
        'userBUID': 'BU123456',
        'userEmail': 'john@example.com',
        'userSchool': 'School of Engineering',
        'userUID': 'user1',
        'userYear': 2024,
        'userPoints': 100,
        'userSavedEvents': {'event1': true, 'event2': false},
      };
      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(documentPath)
          .set(userData);

      // get the user

      final Users? fetchedUser = await firebaseService.fetchUser('user1');
      expect(fetchedUser?.userUID, 'user1');
    });

    test('fetchEventsForDay gets data from a given collection', () async {
      final FirebaseService firebaseService =
          FirebaseService(db: fakeFirebaseFirestore!);

      const String collectionPath = 'events';
      const String documentId1 = 'event1';
      const String documentId2 = 'event2';

      Map<String, dynamic> data1 = {
        "eventID": "1",
        "eventTitle": "Event on Target Date",
        "eventPhoto": "assets/images/arts/image9.jpeg",
        "eventLocation": "Test Location",
        "eventStartTime": DateTime(2024, 4, 29, 10, 0),
        "eventEndTime": DateTime(2024, 4, 29, 12, 0),
        "eventDescription": "Test Description",
        "eventPoints": 30,
        "eventURL": "http://example.com",
        "savedUsers": []
      };

      Map<String, dynamic> data2 = {
        "eventID": "2",
        "eventTitle": "Event Not on Target Date",
        "eventPhoto": "assets/images/arts/image9.jpeg",
        "eventLocation": "Test Location",
        "eventStartTime": DateTime(2024, 4, 28, 10, 0),
        "eventEndTime": DateTime(2024, 4, 28, 12, 0),
        "eventDescription": "Test Description",
        "eventPoints": 30,
        "eventURL": "http://example.com",
        "savedUsers": []
      };

      final targetDate = DateTime(2024, 4, 29);

      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(documentId1)
          .set(data1);
      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(documentId2)
          .set(data2);

      List<Event> allEvents = await firebaseService.fetchEvents();

      final filteredEvents =
          firebaseService.fetchEventsForDay(targetDate, allEvents);

      print(allEvents[0].eventID);
      print(allEvents[1].eventID);

      expect(filteredEvents.length, 1); // Should only contain one event
      expect(filteredEvents[0].eventID, "event1");
      expect(filteredEvents[0].eventTitle, "Event on Target Date");
      expect(filteredEvents[0].eventStartTime, DateTime(2024, 4, 29, 10, 0));
    });
  });
}
