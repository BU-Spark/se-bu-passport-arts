import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String sessionID;
  final DateTime sessionStartTime;
  final DateTime sessionEndTime;
  final List<String> savedUsers;

  Session({
    required this.sessionID,
    required this.sessionStartTime,
    required this.sessionEndTime,
    required this.savedUsers,

  });
  @override
  String toString() {
    return 'Session('
        'ID: $sessionID, '
        'Start Time: $sessionStartTime, '
        'End Time: $sessionEndTime, '
        'Saved Users: $savedUsers'
        ')';
  }
}
