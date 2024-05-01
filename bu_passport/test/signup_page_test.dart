import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bu_passport/pages/signup_page.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'event_widget_test.mocks.dart';
import 'mock.dart';

void main() {
  MockFirebaseService mockFirebaseService = MockFirebaseService();

  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });
  testWidgets('SignUpPage test', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: SignUpPage(),
    ));
    expect(find.byType(TextField), findsNWidgets(7));
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Last Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('BU ID'), findsOneWidget);
    expect(find.text('School'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
  });
}
