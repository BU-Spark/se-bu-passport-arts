import 'package:bu_passport/components/event_widget.dart';
import 'package:bu_passport/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bu_passport/pages/explore_page.dart';
import 'package:bu_passport/classes/event.dart';
import 'package:mockito/mockito.dart';
import 'event_widget_test.mocks.dart';
import 'mock.dart';

// Not set up to verify the sign in process, just the state of the page

void main() {
  MockFirebaseService mockFirebaseService = MockFirebaseService();
  
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });
  testWidgets('LoginPage test', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: LoginPage(),
    ));
    // Tap the sign in button
    await tester.tap(find.text('Sign In with BU Gmail'));
    await tester.pump();
  });
}
