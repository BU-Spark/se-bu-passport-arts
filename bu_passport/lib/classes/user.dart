import 'package:bu_passport/classes/sticker.dart';

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
  final bool admin;
  final Map<Sticker, bool> userStickerCollection;

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
    required this.admin,
    required this.userStickerCollection,
  });
}
