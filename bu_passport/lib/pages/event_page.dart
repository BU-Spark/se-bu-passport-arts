import 'package:flutter/material.dart';
import 'package:bu_passport/services/geocoding_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class EventPage extends StatefulWidget {
  final Event event;

  const EventPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  GeocodingService geocodingService = GeocodingService();

  bool _isRegistered =
      false; // Track whether the user is registered for the event

// Checks if user is registered -- if so, the button will reflect that
  @override
  void initState() {
    super.initState();
    checkIfUserIsRegistered();
  }

  void checkIfUserIsRegistered() async {
    String userUID = FirebaseAuth.instance.currentUser?.uid ?? "";
    // Ensure there's a user logged in
    if (userUID.isEmpty) {
      print("User is not logged in.");
      return;
    }
    bool isRegistered = await FirebaseService.isUserRegisteredForEvent(
        userUID, widget.event.eventID);
    setState(() {
      _isRegistered = isRegistered;
    });
  }

  DateTime? convertEventStartTime(String startTime) {
    // Date format is always <time> <am/pm> on <day of week>, <M> <D>, <Y>
    print(startTime);
    final format = DateFormat("h:mm a 'on' EEEE, MMMM d, yyyy");

    try {
      // Parse the string into a DateTime type with the format
      final DateTime dateTime = format.parse(startTime, true);
      return dateTime;
    } catch (e) {
      // Handle or log error if parsing fails
      print("Error parsing date time: $e");
      return null;
    }
  }

  bool isEventToday(String eventDateTimeStartStr) {
    DateTime? eventDateTimeStart = convertEventStartTime(eventDateTimeStartStr);
    // Ensuring that it is EST

    if (eventDateTimeStart != null) {
      final eventDateTimeLocal =
          tz.TZDateTime.from(eventDateTimeStart, tz.local);
      final nowLocal = tz.TZDateTime.now(tz.local);

      return nowLocal.year == eventDateTimeLocal.year &&
          nowLocal.month == eventDateTimeLocal.month &&
          nowLocal.day == eventDateTimeLocal.day;
    } else {
      print("Datetime parsing error");
      return false;
    }
  }

  Future<void> checkIn() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permission not granted");
        return;
      }

      // Calling getAddressCoordinates to calculate event location coords
      final eventCoords = await geocodingService
          .getAddressCoordinates(widget.event.eventLocation);
      if (eventCoords == null) {
        throw Exception("Failed to get event coordinates.");
      }

      // User's current location
      final currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Calculate the distance between event to user
      final double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        eventCoords['lat'],
        eventCoords['lng'],
      );

      // Distance radius checking
      if (distance <= 400) {
        // Check-in success
        print("Checked in successfully!");
      } else {
        // Too far from location
        print("Too far from the event location to check in.");
      }
    } catch (e) {
      print("An error occurred during check-in: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.02);
    double edgeInsets = (MediaQuery.of(context).size.width * 0.02);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.eventTitle),
      ),
      body: ListView(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            widget.event.eventPhoto,
            fit: BoxFit.cover,
            width: double.infinity,
            height: screenHeight * 0.4, // Adjust the height as needed
          ),
          Padding(
            padding: EdgeInsets.all(edgeInsets),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.eventTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: sizedBoxHeight),
                Text(
                  'Location: ${widget.event.eventLocation}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: sizedBoxHeight),
                Text(
                  'Start Time: ${widget.event.eventStartTime.toString()}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: sizedBoxHeight),
                Text(
                  'End Time: ${widget.event.eventEndTime.toString()}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: sizedBoxHeight),
                Text(
                  'Description: ${widget.event.eventDescription}',
                  style: TextStyle(fontSize: 16),
                ),
                // Add more event details as needed
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(edgeInsets),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _isRegistered &&
                          isEventToday(widget.event.eventStartTime)
                      ? checkIn
                      : null, // Check-in function is called here if registered
                  child: Text('Check In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRegistered
                        ? Colors.blue
                        : Colors
                            .grey, // Change color based on registration status
                  ),
                ),
                SizedBox(height: sizedBoxHeight), // Optional spacing
                ElevatedButton(
                  onPressed: () async {
                    String userUID =
                        FirebaseAuth.instance.currentUser?.uid ?? "";
                    String eventId = widget.event.eventID;
                    bool isRegistered =
                        await FirebaseService.isUserRegisteredForEvent(
                            userUID, eventId);
                    if (isRegistered) {
                      FirebaseService.unregisterFromEvent(userUID, eventId);
                    } else {
                      FirebaseService.registerForEvent(userUID, eventId);
                    }
                    setState(() {
                      _isRegistered =
                          !_isRegistered; // Toggle registration status
                    });
                  },
                  child: Text(_isRegistered ? 'Unregister' : 'Register'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
