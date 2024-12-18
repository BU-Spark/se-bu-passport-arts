import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String firstName;
  final String lastName;
  final String userBUID;
  final String userEmail;
  final String userSchool;
  final String userUID;
  final int userYear;
  final int userPoints;
  final String userProfileURL;
  final Map<String, dynamic> userSavedEvents;
  final Map<int, bool> userCollectedStickers;
  final List<String> userPhotos;
  final Timestamp userCreatedAt;

  Users({
    required this.firstName,
    required this.lastName,
    required this.userBUID,
    required this.userEmail,
    required this.userSchool,
    required this.userUID,
    required this.userYear,
    required this.userSavedEvents,
    required this.userPoints,
    required this.userProfileURL,
    required this.userCollectedStickers,
    required this.userPhotos,
    required this.userCreatedAt,
  });

// Method to convert Users object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'userBUID': userBUID,
      'userEmail': userEmail,
      'userSchool': userSchool,
      'userUID': userUID,
      'userYear': userYear,
      'userPoints': userPoints,
      'userProfileURL': userProfileURL,
      'userSavedEvents': userSavedEvents,
      'userCollectedStickers': userCollectedStickers,
      'userPhotos': userPhotos,
      'userCreatedAt': userCreatedAt,
    };
  }

  // Method to create Users object from a map
  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      firstName: map['firstName'],
      lastName: map['lastName'],
      userBUID: map['userBUID'],
      userEmail: map['userEmail'],
      userSchool: map['userSchool'],
      userUID: map['userUID'],
      userYear: map['userYear'],
      userPoints: map['userPoints'],
      userProfileURL: map['userProfileURL'],
      userSavedEvents: Map<String, dynamic>.from(map['userSavedEvents']),
      userCollectedStickers: Map<int, bool>.from(map['userCollectedStickers']),
      userPhotos: List<String>.from(map['userPhotos']),
      userCreatedAt: map['userCreatedAt'],
    );
  }

}
