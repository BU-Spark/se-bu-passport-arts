class Event {
  final String eventId;
  final String eventName;
  final String eventPhoto;
  final String eventLocation;
  final DateTime eventTime;
  final List<String> eventTags;
  final List<String> registeredUsers;

  Event({
    required this.eventId,
    required this.eventName,
    required this.eventPhoto,
    required this.eventLocation,
    required this.eventTime,
    required this.eventTags,
    required this.registeredUsers,
  });
}
