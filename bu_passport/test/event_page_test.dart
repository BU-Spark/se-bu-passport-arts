import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bu_passport/pages/event_page.dart';
import 'package:bu_passport/classes/event.dart';
import 'package:mockito/mockito.dart';

import 'event_widget_test.dart';
import 'event_widget_test.mocks.dart';
import 'mock.dart';

void main() {
  MockFirebaseService mockFirebaseService = MockFirebaseService();

  when(mockFirebaseService.hasUserSavedEvent(any, any))
      .thenAnswer((_) async => true); // or any other desired response
  when(mockFirebaseService.isUserCheckedInForEvent(any, any))
      .thenAnswer((_) async => true); // Example response, adjust as needed

  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });
  testWidgets('EventPage UI Test', (WidgetTester tester) async {
    // Create a test event
    final testEvent = Event(
      eventID: '1',
      eventTitle: 'Test Event',
      eventPhoto: "assets/images/arts/image9.jpeg",
      eventLocation: 'Test Location',
      eventStartTime: DateTime(2024, 4, 18, 10, 0),
      eventEndTime: DateTime(2024, 4, 18, 12, 0),
      eventDescription: 'Test Description',
      eventPoints: 30,
      eventURL: 'http://example.com',
      savedUsers: ['user1', 'user2'],
      attendedUsers: [],
    );

    // Build our widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: EventPage(
        event: testEvent,
        onUpdateEventPage: () {},
      ),
    ));

    expect(find.byType(ElevatedButton),
        findsNWidgets(2)); // There are two ElevatedButtons
  });
}
