import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bu_passport/pages/explore_page.dart';
import 'package:bu_passport/classes/event.dart';
import 'package:mockito/mockito.dart';

import 'event_widget_test.mocks.dart';
import 'mock.dart';

void main() {
  final testEvent2 = Event(
    eventID: '2',
    eventTitle: 'Test Event 2',
    eventPhoto: "assets/images/arts/image9.jpeg",
    eventLocation: 'Test Location 2',
    eventStartTime: DateTime(2024, 4, 18, 10, 0),
    eventEndTime: DateTime(2024, 4, 18, 12, 0),
    eventDescription: 'Test Description 2',
    eventPoints: 30,
    eventURL: 'http://example.com',
    savedUsers: ['user1', 'user2'],
  );

  MockFirebaseService mockFirebaseService = MockFirebaseService();

  when(mockFirebaseService.hasUserSavedEvent(any, any))
      .thenAnswer((_) async => true); // or any other desired response
  when(mockFirebaseService.isUserCheckedInForEvent(any, any))
      .thenAnswer((_) async => true); // Example response, adjust as needed
  when(mockFirebaseService.fetchEventsFromNow())
      .thenAnswer((_) => Future.value([testEvent2]));

  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
    final FakeFirebaseFirestore fakeFirebaseFirestore = FakeFirebaseFirestore();

    const String collectionPath = 'events';
    const String documentPath = 'event1';

    Map<String, dynamic> data = {
      "eventID": 1,
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

    await fakeFirebaseFirestore
        .collection(collectionPath)
        .doc(documentPath)
        .set(data);
  });
  testWidgets('ExplorePage UI Test', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: ExplorePage(),
    ));

    // Verify that the app bar title is displayed correctly
    expect(find.text('Events'), findsOneWidget);

    // Verify that the search bar is displayed
    expect(find.byType(TextField), findsOneWidget);
  });
}
