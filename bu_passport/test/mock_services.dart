import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockDocumentSnapshot {
  final Map<String, dynamic> mockData;

  MockDocumentSnapshot(this.mockData);

  @override
  Map<String, dynamic>? data() {
    return mockData;
  }

  @override
  bool get exists => data()?.isNotEmpty ?? false;
}