import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/classes/user.dart';
import 'package:bu_passport/pages/login_page.dart';
import 'package:bu_passport/services/firebase_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'mock.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

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
      print('Fetching events only happening on target date...');
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

      expect(filteredEvents.length, 1); // Should only contain one event
      expect(filteredEvents[0].eventID, "event1");
      expect(filteredEvents[0].eventTitle, "Event on Target Date");
      expect(filteredEvents[0].eventStartTime, DateTime(2024, 4, 29, 10, 0));
    });

    // test('saveEvent saves an event to user and updates event document',
    //     () async {
    //   print("Saving events at request...");

    //   final FirebaseService firebaseService =
    //       FirebaseService(db: fakeFirebaseFirestore!);

    //   const String userCollectionPath = 'users';
    //   const String userDocumentPath = 'user1';
    //   const String eventCollectionPath = 'events';
    //   const String eventDocumentPath = 'event1';

    //   final Map<String, dynamic> userData = {
    //     'firstName': 'John',
    //     'lastName': 'Doe',
    //     'userProfileURL': 'https://example.com/profile.jpg',
    //     'userBUID': 'BU123456',
    //     'userEmail': 'john@example.com',
    //     'userSchool': 'School of Engineering',
    //     'userUID': 'user1',
    //     'userYear': 2024,
    //     'userPoints': 100,
    //     'userSavedEvents': {},
    //   };

    //   await fakeFirebaseFirestore!
    //       .collection(userCollectionPath)
    //       .doc(userDocumentPath)
    //       .set(userData);

    //   Map<String, dynamic> eventData = {
    //     "eventID": "1",
    //     "eventTitle": "Event Save",
    //     "eventPhoto": "assets/images/arts/image9.jpeg",
    //     "eventLocation": "Test Location",
    //     "eventStartTime": DateTime(2024, 4, 29, 10, 0),
    //     "eventEndTime": DateTime(2024, 4, 29, 12, 0),
    //     "eventDescription": "Test Description",
    //     "eventPoints": 30,
    //     "eventURL": "http://example.com",
    //     "savedUsers": []
    //   };

    //   await fakeFirebaseFirestore!
    //       .collection(eventCollectionPath)
    //       .doc(eventDocumentPath)
    //       .set(eventData);

    //   await firebaseService.saveEvent(eventDocumentPath);

    //   final userDoc = await fakeFirebaseFirestore!
    //       .collection(userCollectionPath)
    //       .doc(userDocumentPath)
    //       .get();
    //   final eventDoc = await fakeFirebaseFirestore!
    //       .collection(eventCollectionPath)
    //       .doc(eventDocumentPath)
    //       .get();
    //   // Verify that the event ID is added to the user's saved events
    //   expect(userDoc.data()?['userSavedEvents'][eventDocumentPath], false);
    //   // Verify that the user ID is added to the event's saved users
    //   expect(eventDoc.data()?['savedUsers'], contains('user1'));
    // });

    test(
        'hasUserSavedEvent returns true if the event is saved for a given user',
        () async {
      print("Checking if user has saved event...");
      final FirebaseService firebaseService =
          FirebaseService(db: fakeFirebaseFirestore!);
      const String userId = 'user1';
      const String eventId1 = 'event1';

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
          .collection('users')
          .doc(userId)
          .set(userData);

      bool hasSaved = await firebaseService.hasUserSavedEvent(userId, eventId1);
      expect(hasSaved, isTrue);
    });
    test(
        'hasUserSavedEvent returns false if the event is not saved for a given user',
        () async {
      print("Checking if user has not saved event...");
      final FirebaseService firebaseService =
          FirebaseService(db: fakeFirebaseFirestore!);
      const String userId = 'user1';
      const String eventId1 = 'event1';

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
        'userSavedEvents': {},
      };
      await fakeFirebaseFirestore!
          .collection('users')
          .doc(userId)
          .set(userData);

      bool hasSaved = await firebaseService.hasUserSavedEvent(userId, eventId1);
      expect(hasSaved, isFalse);
    });

    test('fetchEventById successfully fetches an event from a valid event ID',
        () async {
      print("Fetching event from valid ID...");
      final FirebaseService firebaseService =
          FirebaseService(db: fakeFirebaseFirestore!);
      const String collectionPath = 'events';
      const String documentId1 = 'event1';

      Map<String, dynamic> data1 = {
        "eventID": documentId1,
        "eventTitle": "Test Event",
        "eventPhoto": "assets/images/arts/image9.jpeg",
        "eventLocation": "Test Location",
        "eventStartTime": DateTime(2024, 4, 29, 10, 0),
        "eventEndTime": DateTime(2024, 4, 29, 12, 0),
        "eventDescription": "Test Description",
        "eventPoints": 30,
        "eventURL": "http://example.com",
        "savedUsers": ['user1']
      };

      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(documentId1)
          .set(data1);

      Event? event = await firebaseService.fetchEventById(documentId1);

      expect(event, isNotNull);
      expect(event!.eventID, equals(documentId1));
      expect(event.eventTitle, equals('Test Event'));
      expect(event.savedUsers, contains('user1'));
    });

    test('fetchEventById catches error if event does not exist', () async {
      print("Fetching event from an invalid ID...");
      final FirebaseService firebaseService =
          FirebaseService(db: fakeFirebaseFirestore!);
      const String collectionPath = 'events';
      const String documentId1 = 'event1';

      Map<String, dynamic> data1 = {
        "eventID": documentId1,
        "eventTitle": "Test Event",
        "eventPhoto": "assets/images/arts/image9.jpeg",
        "eventLocation": "Test Location",
        "eventStartTime": DateTime(2024, 4, 29, 10, 0),
        "eventEndTime": DateTime(2024, 4, 29, 12, 0),
        "eventDescription": "Test Description",
        "eventPoints": 30,
        "eventURL": "http://example.com",
        "savedUsers": ['user1']
      };

      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(documentId1)
          .set(data1);

      expect(firebaseService.fetchEventById('nonexistent id'),
          throwsA(isA<Exception>()));
    });

    test(
        'isUserCheckedInForEvent returns true if the user is checked in to a given event',
        () async {
      print(
          'Checking if user is checked in for an event they are checked in to...');
      final FirebaseService firebaseService =
          FirebaseService(db: fakeFirebaseFirestore!);
      const String collectionPath = 'users';
      const String userId = 'user1';
      const String documentId1 = 'event1';

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
          .doc(userId)
          .set(userData);

      bool isCheckedIn =
          await firebaseService.isUserCheckedInForEvent(userId, documentId1);

      expect(isCheckedIn, isTrue);
    });

    test(
        'isUserCheckedInForEvent returns false if the user is not checked in to a given event',
        () async {
      print(
          'Checking if user is checked in for an event they are not checked in to...');
      final FirebaseService firebaseService =
          FirebaseService(db: fakeFirebaseFirestore!);
      const String collectionPath = 'users';
      const String userId = 'user1';
      const String documentId1 = 'event1';

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
        'userSavedEvents': {'event1': false, 'event2': false},
      };

      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(userId)
          .set(userData);

      bool isCheckedIn =
          await firebaseService.isUserCheckedInForEvent(userId, documentId1);

      expect(isCheckedIn, isFalse);
    });

    test(
        'fetchEventsFromNow only returns events that end after the current time',
        () async {
      print('Checking if events from now to the future are fetched...');
      final FirebaseService firebaseService =
          FirebaseService(db: fakeFirebaseFirestore!);
      final DateTime now = DateTime.now();

      const String collectionPath = 'events';
      const String eventId1 = 'event1';
      const String eventId2 = 'event2';

      Map<String, dynamic> data1 = {
        "eventID": eventId1,
        "eventTitle": "Past Event",
        "eventPhoto": "assets/images/arts/image9.jpeg",
        "eventLocation": "Test Location",
        "eventStartTime": Timestamp.fromDate(now.subtract(Duration(days: 2))),
        "eventEndTime": Timestamp.fromDate(now.subtract(Duration(days: 1))),
        "eventDescription": "Test Description",
        "eventPoints": 30,
        "eventURL": "http://example.com",
        "savedUsers": ['user1']
      };

      Map<String, dynamic> data2 = {
        "eventID": eventId2,
        "eventTitle": "Now/Future Event",
        "eventPhoto": "assets/images/arts/image9.jpeg",
        "eventLocation": "Test Location",
        "eventStartTime": Timestamp.fromDate(now.add(Duration(hours: 1))),
        "eventEndTime": Timestamp.fromDate(now.add(Duration(days: 1))),
        "eventDescription": "Test Description",
        "eventPoints": 30,
        "eventURL": "http://example.com",
        "savedUsers": ['user1']
      };

      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(eventId1)
          .set(data1);
      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(eventId2)
          .set(data2);

      List<Event> events = await firebaseService.fetchEventsFromNow();
      expect(events.length, 1);
      expect(events.first.eventTitle, 'Now/Future Event');
    });

    test('fetchAllUsers retrieves and constructs User object correctly',
        () async {
      print('Checking if all users are retrievable...');
      final FirebaseService firebaseService =
          FirebaseService(db: fakeFirebaseFirestore!);

      const String collectionPath = 'users';
      const String userId1 = 'user1';
      const String userId2 = 'user2';
      const String userId3 = 'user3';

      final Map<String, dynamic> data1 = {
        'firstName': 'John',
        'lastName': 'Doe',
        'userProfileURL': 'https://example.com/profile.jpg',
        'userBUID': 'BU123456',
        'userEmail': 'john@example.com',
        'userSchool': 'School of Engineering',
        'userUID': 'user1',
        'userYear': 2024,
        'userPoints': 100,
        'userSavedEvents': {'event1': false, 'event2': false},
      };

      final Map<String, dynamic> data2 = {
        'firstName': 'Ben',
        'lastName': 'Clark',
        'userProfileURL': 'https://example.com/profile.jpg',
        'userBUID': 'BU654321',
        'userEmail': 'ben@example.com',
        'userSchool': 'School of Arts',
        'userUID': 'user2',
        'userYear': 2024,
        'userPoints': 100,
        'userSavedEvents': {'event1': false, 'event2': false},
      };

      final Map<String, dynamic> data3 = {
        'firstName': 'Marc',
        'lastName': 'Malone',
        'userProfileURL': 'https://example.com/profile.jpg',
        'userBUID': 'BU132446',
        'userEmail': 'marc@example.com',
        'userSchool': 'School of Communications',
        'userUID': 'user3',
        'userYear': 2024,
        'userPoints': 100,
        'userSavedEvents': {'event1': false, 'event2': false},
      };

      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(userId1)
          .set(data1);
      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(userId2)
          .set(data2);
      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(userId3)
          .set(data3);

      List<Users> users = await firebaseService.fetchAllUsers();
      expect(users.length, 3);
      expect(users[0].firstName, 'John');
      expect(users[0].lastName, 'Doe');
      expect(users[1].firstName, 'Ben');
      expect(users[1].lastName, 'Clark');
      expect(users[2].firstName, 'Marc');
      expect(users[2].lastName, 'Malone');

      expect(users.any((user) => user.userUID == 'user1'), isTrue);
      expect(users.any((user) => user.userUID == 'user2'), isTrue);
      expect(users.any((user) => user.userUID == 'user3'), isTrue);
      expect(users.any((user) => user.userUID == 'nonexistent'), isFalse);
    });
  });

  // Tests for filterEvents group -- have 4 test cases
  group('Event Filtering Tests', () {
    late FakeFirebaseFirestore fakeFirebaseFirestore;
    setupFirebaseAuthMocks();
    late FirebaseService firebaseService;

    setUpAll(() async {
      fakeFirebaseFirestore = FakeFirebaseFirestore();
      firebaseService = FirebaseService(db: fakeFirebaseFirestore);

      const String collectionPath = 'events';
      const String documentId1 = 'event1';
      const String documentId2 = 'event2';
      const String documentId3 = 'event3';

      Map<String, dynamic> data1 = {
        "eventID": "1",
        "eventTitle": "Annual Art Conference",
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
        "eventTitle": "Theatre Show",
        "eventPhoto": "assets/images/arts/image9.jpeg",
        "eventLocation": "Test Location",
        "eventStartTime": DateTime(2024, 4, 28, 10, 0),
        "eventEndTime": DateTime(2024, 4, 28, 12, 0),
        "eventDescription": "Test Description",
        "eventPoints": 30,
        "eventURL": "http://example.com",
        "savedUsers": []
      };

      Map<String, dynamic> data3 = {
        "eventID": "3",
        "eventTitle": "Art Exhibit",
        "eventPhoto": "assets/images/arts/image9.jpeg",
        "eventLocation": "Test Location",
        "eventStartTime": DateTime(2024, 4, 28, 10, 0),
        "eventEndTime": DateTime(2024, 4, 28, 12, 0),
        "eventDescription": "Test Description",
        "eventPoints": 30,
        "eventURL": "http://example.com",
        "savedUsers": []
      };

      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(documentId1)
          .set(data1);
      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(documentId2)
          .set(data2);
      await fakeFirebaseFirestore!
          .collection(collectionPath)
          .doc(documentId3)
          .set(data3);
    });

    test('filterEvents returns all events when query is empty', () async {
      print("Filtering events with an empty query...");
      final List<Event> eventList = (await firebaseService.fetchEvents());
      final filteredEvents = firebaseService.filterEvents(eventList, "");
      expect(filteredEvents.length, 3);
    });

    test('filterEvents returns correct events for specific query', () async {
      print("Filtering events with an exact event title query...");
      final List<Event> eventList = (await firebaseService.fetchEvents());
      final filteredEvents =
          firebaseService.filterEvents(eventList, "Annual Art Conference");
      expect(filteredEvents.length, 1);
      expect(filteredEvents.first.eventTitle, "Annual Art Conference");
    });

    test('filterEvents is case insensitive', () async {
      print("Filtering events when query is case insensitive...");
      final List<Event> eventList = (await firebaseService.fetchEvents());
      final filteredEvents =
          firebaseService.filterEvents(eventList, "theatre show");
      expect(filteredEvents.length, 1);
      expect(filteredEvents.first.eventTitle, "Theatre Show");
    });

    test('filterEvents returns no events when query does not match', () async {
      print("Filtering events when query doesn't match any events...");
      final List<Event> eventList = (await firebaseService.fetchEvents());
      final filteredEvents =
          firebaseService.filterEvents(eventList, "nonexistent event");
      expect(filteredEvents.isEmpty, true);
    });
  });
}
