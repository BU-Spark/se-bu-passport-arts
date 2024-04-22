// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:bu_passport/pages/signup_page.dart';
// import 'package:mockito/mockito.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'mock.dart'; 

// void main() {
//   group('SignUpPage Tests', () {
//     late MockFirebaseAuth mockAuth;
//     late MockFirebaseFirestore mockFirestore;
//     late MockUserCredential mockUserCredential;
//     late MockUser mockUser;

//     setUp(() {
//       mockAuth = MockFirebaseAuth();
//       mockFirestore = MockFirebaseFirestore();
//       mockUserCredential = MockUserCredential();
//       mockUser = MockUser();

//       // Set up mocks
//       when(mockUserCredential.user).thenReturn(mockUser);
//       when(mockUser.uid).thenReturn("1234567890");
//       when(mockFirestore.collection('users')).thenReturn(MockCollectionReference());
//     });

//     testWidgets('renders SignUpPage and allows user registration', (WidgetTester tester) async {
//       await tester.pumpWidget(MaterialApp(home: SignUpPage()));

//       // Check all input fields are present
//       expect(find.byType(TextField), findsNWidgets(7));
//       expect(find.text('First Name'), findsOneWidget);
//       expect(find.text('Last Name'), findsOneWidget);
//       expect(find.text('Email'), findsOneWidget);
//       expect(find.text('Password'), findsOneWidget);
//       expect(find.text('BU ID'), findsOneWidget);
//       expect(find.text('School'), findsOneWidget);
//       expect(find.text('Year'), findsOneWidget);

//       // Simulate user input
//       await tester.enterText(find.byType(TextField).at(0), 'John');
//       await tester.enterText(find.byType(TextField).at(1), 'Doe');
//       await tester.enterText(find.byType(TextField).at(2), 'john.doe@example.com');
//       await tester.enterText(find.byType(TextField).at(3), '123456');
//       await tester.enterText(find.byType(TextField).at(4), 'BU12345678');
//       await tester.enterText(find.byType(TextField).at(5), 'Engineering');
//       await tester.enterText(find.byType(TextField).at(6), '2024');

//       // Simulate form submission
//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump();

//       // Verify that Firestore and FirebaseAuth were used to create the user
//       verify(mockAuth.createUserWithEmailAndPassword(email: 'john.doe@example.com', password: '123456')).called(1);
//       verify(mockFirestore.collection('users')).called(1);
//     });
//   });
// }

