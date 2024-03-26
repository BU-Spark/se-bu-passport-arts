import "package:bu_passport/classes/event.dart";

class Users {
  final String firstName;
  final String lastName;
  final String profileImageUrl;
  final String userBUID;
  final String userEmail;
  final String userSchool;
  final String userUID;
  final int userYear;
  final List<String> userPreferences;
  final List<String> userRegisteredEvents;

  Users({
    required this.firstName,
    required this.lastName,
    required this.profileImageUrl,
    required this.userBUID,
    required this.userEmail,
    required this.userSchool,
    required this.userUID,
    required this.userYear,
    required this.userPreferences,
    required this.userRegisteredEvents,
  });
}
