import 'package:bu_passport/pages/profile_page.dart';
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
  // testWidgets('ProfilePage test', (WidgetTester tester) async {
  //   // Build our widget and trigger a frame.
  //   await tester.pumpWidget(MaterialApp(
  //     home: ProfilePage(),
  //   ));

  //   // // Wait for the widgets to load.
  //   // await tester.pumpAndSettle();
  //   // // Verify that the Saved tab is displayed.
  //   // expect(find.text('Saved'), findsOneWidget);

  //   // // Verify that the Attended tab is displayed.
  //   // expect(find.text('Attended'), findsOneWidget);
  // });
}
