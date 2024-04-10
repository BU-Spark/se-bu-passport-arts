class Users {
  final String firstName;
  final String lastName;
  final String profileImageUrl;
  final String userBUID;
  final String userEmail;
  final String userSchool;
  final String userUID;
  final int userYear;
  final int userPoints;
  final List<String> userPreferences;
  final Map<String, dynamic> userSavedEvents;

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
    required this.userSavedEvents,
    required this.userPoints,
  });
}
