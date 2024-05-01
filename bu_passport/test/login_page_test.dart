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
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    // Enter test email and password
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');

    // Tap the sign in button
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    
  });
}
