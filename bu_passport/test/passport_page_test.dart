import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bu_passport/pages/passport_page.dart';
import 'package:bu_passport/components/sticker_widget.dart';
import 'mock_services.dart';

void main() {
  testWidgets('PassportPage displays user stickers', (WidgetTester tester) async {
    // Create mock services
    final mockFirestore = MockFirestore();
    final mockFirebaseAuth = MockFirebaseAuth();
    final mockUser = MockUser();

    // Mock Firestore data
    final mockDocumentSnapshot = MockDocumentSnapshot({
      'userCollectedStickers': [1, 2, 3],
    });
    when(mockFirestore.collection('users').doc(any).get()).thenAnswer((_) async => mockDocumentSnapshot as DocumentSnapshot<Map<String, dynamic>>);
    when(mockDocumentSnapshot.exists).thenReturn(true);
    when(mockDocumentSnapshot.data()).thenReturn({
      'userCollectedStickers': [1, 2, 3],
    });

    // Mock FirebaseAuth data
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('testUserId');

    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: PassportPage(
        ),
      ),
    );

    // Verify the loading indicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the async operations to complete
    await tester.pumpAndSettle();

    // Verify the stickers are displayed
    expect(find.byType(StickerWidget), findsOneWidget);
    expect(find.text('Stickers'), findsOneWidget);
  });
}