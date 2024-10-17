import 'package:bu_passport/pages/event_page.dart';
import 'package:bu_passport/services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/components/event_widget.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'event_widget_test.mocks.dart';
import 'mock.dart';

final event = Event(
  eventID: '1',
  realEventID: '1',
  eventTitle: 'Test Event',
  eventPhoto: "assets/images/arts/image9.jpeg",
  eventLocation: 'Test Location',
  eventStartTime: DateTime(2024, 4, 18, 10, 0), // April 18, 2024, 10:00 AM
  eventEndTime: DateTime(2024, 4, 18, 12, 0), // April 18, 2024, 12:00 PM
  eventDescription: 'Test Description',
  eventPoints: 30,
  eventURL: 'http://example.com',
  savedUsers: ['user1', 'user2'],
  eventCategories: [],
);

@GenerateMocks([FirebaseService])
void main() async {
  MockFirebaseService mockFirebaseService = MockFirebaseService();

  when(mockFirebaseService.hasUserSavedEvent(any, any))
      .thenAnswer((_) async => true); // or any other desired response
  when(mockFirebaseService.isUserCheckedInForEvent(any, any))
      .thenAnswer((_) async => true); // Example response, adjust as needed

  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('EventWidget displays and navigates correctly',
      (WidgetTester tester) async {
    // Wrap EventWidget in MaterialApp or Directionality
    await tester.pumpWidget(
      MaterialApp(
        home: EventWidget(event: event, onUpdateEventPage: () {}),
      ),
    );

    // Verify that the event title is displayed correctly
    expect(find.text('Test Event'), findsOneWidget);

    // Verify that the favorite icon is displayed
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byType(EventWidget));

    // Wait for animations to complete
    await tester.pumpAndSettle();

    // Verify that EventPage is pushed
    expect(find.byType(EventPage), findsOneWidget);
  });
}
