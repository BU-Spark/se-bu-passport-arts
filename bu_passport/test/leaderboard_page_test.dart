import 'package:bu_passport/classes/user.dart';
import 'package:bu_passport/pages/leaderboard_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'event_widget_test.mocks.dart';
import 'mock.dart';

void main() {
  final List<Users> mockUsers = [
    Users(
        firstName: 'John',
        lastName: 'Doe',
        userBUID: '123456',
        userEmail: 'john.doe@example.com',
        userSchool: 'Example School',
        userUID: 'user1',
        userYear: 3,
        userSavedEvents: {},
        userPoints: 100,
        userProfileURL: '',
        userCollectedStickers: {},
        userPhotos: [],
        userCreatedAt: Timestamp.now(),
      ),
    Users(
        firstName: 'Jane',
        lastName: 'Smith',
        userBUID: '654321',
        userEmail: 'jane.smith@example.com',
        userSchool: 'Another School',
        userUID: 'user2',
        userYear: 2,
        userSavedEvents: {},
        userPoints: 150,
        userProfileURL: '',
        userCollectedStickers: {},
        userPhotos: [],
        userCreatedAt: Timestamp.now(),
      ),
  ];
  MockFirebaseService mockFirebaseService = MockFirebaseService();

  when(mockFirebaseService.hasUserSavedEvent(any, any))
      .thenAnswer((_) async => true); // or any other desired response
  when(mockFirebaseService.isUserCheckedInForEvent(any, any))
      .thenAnswer((_) async => true); // Example response, adjust as needed

  // Set up mock behavior
  when(mockFirebaseService.fetchAllUsers()).thenAnswer((_) async => mockUsers);

  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('LeaderboardPage Test', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: LeaderboardPage(),
    ));

    final LeaderboardPageState state =
        tester.state(find.byType(LeaderboardPage));
    state.allUsers = mockUsers;
    state.topUsers = mockUsers;

    await tester.pumpAndSettle();

    // Verify that the app bar title is displayed correctly
    expect(find.text('Leaderboard'), findsOneWidget);
  });
}
