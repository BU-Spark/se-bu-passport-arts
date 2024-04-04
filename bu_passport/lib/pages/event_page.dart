import 'package:flutter/material.dart';
import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventPage extends StatefulWidget {
  final Event event;

  const EventPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
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
//

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
            child: ElevatedButton(
              onPressed: () async {
                String userUID = FirebaseAuth.instance.currentUser?.uid ?? "";
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
                  _isRegistered = !_isRegistered; // Toggle registration status
                });
              },
              child: Text(_isRegistered ? 'Unregister' : 'Register'),
            ),
          ),
        ],
      ),
    );
  }
}
