import "package:bu_passport/classes/event.dart";
import "package:bu_passport/classes/new_event.dart";

class NewCategorizedEvents {
  final List<NewEvent> attendedEvents;
  final List<NewEvent> userSavedEvents;

  NewCategorizedEvents({
    required this.attendedEvents, 
    required this.userSavedEvents,
  });
}
