import 'package:flutter/material.dart';
import 'package:bu_passport/services/geocoding_service.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventPage extends StatefulWidget {
  final Event event;

  const EventPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  GeocodingService geocodingService = GeocodingService();

  bool _isSaved = false; // Track whether the user is interested in the event
  bool _isCheckedIn = false; // To track if the user has checked in

// Checks if user is registered -- if so, the button will reflect that
  @override
  void initState() {
    super.initState();
    checkIfUserIsRegistered();
    checkIfUserIsCheckedIn();
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
      // changing registered to saved
      _isSaved = isRegistered;
    });
  }

  void checkIfUserIsCheckedIn() async {
    String userUID = FirebaseAuth.instance.currentUser?.uid ?? "";
    // Ensure there's a user logged in
    if (userUID.isEmpty) {
      print("User is not logged in.");
      return;
    }
    bool isCheckedIn = await FirebaseService.isUserCheckedInForEvent(
        userUID, widget.event.eventID);
    setState(() {
      _isCheckedIn = isCheckedIn;
    });
  }

  bool isEventToday(DateTime eventDateTimestamp) {
    // DateTime? eventDateTimeStart = convertEventStartTime(eventDateTimeStartStr);
    // Ensuring that it is EST

    // DateTime eventDateTimeStart = eventDateTimestamp.toDate();

    final eventDateTimeLocal = tz.TZDateTime.from(eventDateTimestamp, tz.local);
    final nowLocal = tz.TZDateTime.now(tz.local);
    return nowLocal.year == eventDateTimeLocal.year &&
        nowLocal.month == eventDateTimeLocal.month &&
        nowLocal.day == eventDateTimeLocal.day;
  }

  Future<bool> checkIn() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permission not granted");
        return false;
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
      print("Event coords: $eventCoords");
      print("Current position: $currentPosition");

      // Calculate the distance between event to user
      final double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        eventCoords['lat'],
        eventCoords['lng'],
      );
      print("Distance: $distance meters");

      // Distance radius checking
      if (distance <= 400) {
        // Check-in success
        setState(() {
          _isCheckedIn = true;
        });
        print("Checked in successfully!");
        return true;
      } else {
        // Too far from location
        print("Too far from the event location to check in.");
        return false;
      }
    } catch (e) {
      print("An error occurred during check-in: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.02);
    double edgeInsets = (MediaQuery.of(context).size.width * 0.02);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            widget.event.eventPhoto,
            fit: BoxFit.cover,
            width: double.infinity,
            height: screenHeight * 0.4, // Adjust the height as needed
          ),
          Padding(
            padding: EdgeInsets.all(edgeInsets * 2.5),
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
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Location: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: widget.event.eventLocation,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sizedBoxHeight),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Start Time: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: DateFormat('h:mm a, EEEE, MMMM d, y')
                            .format(widget.event.eventStartTime),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sizedBoxHeight),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'End Time: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: DateFormat('h:mm a, EEEE, MMMM d, y')
                            .format(widget.event.eventEndTime),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sizedBoxHeight),
                GestureDetector(
                  onTap: () async {
                    var url = Uri.parse(widget.event.eventURL);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Event URL: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: widget.event.eventURL,
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: sizedBoxHeight),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Description: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: widget.event.eventDescription,
                      ),
                    ],
                  ),
                ),

                // Add more event details as needed
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(edgeInsets),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: (!_isSaved ||
                          !isEventToday(widget.event.eventStartTime) ||
                          _isCheckedIn)
                      ? null
                      : () async {
                          // Your check-in logic here. On successful check-in, update the _isCheckedIn state.
                          bool success = await checkIn();
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Checked in successfully!")));
                            FirebaseService.checkInUserForEvent(
                                widget.event.eventID);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Unable to check in: location too far or permission denied.")));
                          }
                        },
                  child: Text(_isCheckedIn ? 'Checked In' : 'Check In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCheckedIn
                        ? Colors.grey
                        : (_isSaved ? Colors.red : Colors.grey),
                  ),
                ),
                SizedBox(width: sizedBoxHeight * 3), // Optional spacing
                ElevatedButton(
                  onPressed: () async {
                    String userUID =
                        FirebaseAuth.instance.currentUser?.uid ?? "";
                    String eventId = widget.event.eventID;
                    bool isRegistered =
                        await FirebaseService.isUserRegisteredForEvent(
                            userUID, eventId);
                    if (isRegistered) {
                      FirebaseService.unregisterFromEvent(eventId);
                    } else {
                      FirebaseService.registerForEvent(eventId);
                    }
                    setState(() {
                      _isSaved = !_isSaved; // Toggle registration status
                    });
                  },
                  child: Text(_isSaved ? 'Unsave' : 'Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
