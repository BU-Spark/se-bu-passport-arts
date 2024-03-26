import "package:bu_passport/classes/event.dart";

class CategorizedEvents {
  final List<Event> attendedEvents;
  final List<Event> upcomingEvents;

  CategorizedEvents({
    required this.attendedEvents, 
    required this.upcomingEvents,
  });
}
