import 'package:bu_passport/pages/calendar_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'event_widget_test.mocks.dart';
import 'mock.dart';

void main() {
  MockFirebaseService mockFirebaseService = MockFirebaseService();

  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });
  testWidgets('CalenderPage test', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: CalendarPage(),
    ));
  });

  // check if Calendar text is in app bar
  expect(find.text('Calendar'), findsOneWidget);
}
