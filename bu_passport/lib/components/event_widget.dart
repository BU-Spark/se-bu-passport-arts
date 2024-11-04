import 'package:bu_passport/classes/new_event.dart';
import 'package:bu_passport/components/time_span.dart';
import 'package:bu_passport/pages/event_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../services/new_firebase_service.dart';
import '../services/web_image_service.dart';

class EventWidget extends StatefulWidget {
  final NewEvent event;
  final Function onUpdateEventPage;
  const EventWidget(
      {Key? key, required this.event, required this.onUpdateEventPage})
      : super(key: key);

  @override
  _EventWidgetState createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {
  bool _isSaved = false;
  bool _isCheckedIn = false;
  String userUID = FirebaseAuth.instance.currentUser?.uid ?? "";
  // Ensure there's a user logged in
  NewFirebaseService firebaseService =
      NewFirebaseService(db: FirebaseFirestore.instance);

  @override
  void initState() {
    checkIfUserSaved();
    checkIfUserCheckedIn();
    super.initState();
  }

  // Function to check if user has saved the event

  void checkIfUserSaved() async {
    // Ensure there's a user logged in
    if (userUID.isEmpty) {
      print("User is not logged in.");
      return;
    }
    bool isSaved =
        await firebaseService.hasUserSavedEvent(userUID, widget.event.eventID);
    setState(() {
      // changing save to saved
      _isSaved = isSaved;
    });
  }

  // Function to check if user has checked in to the event
  void checkIfUserCheckedIn() async {
    // Ensure there's a user logged in
    if (userUID.isEmpty) {
      print("User is not logged in.");
      return;
    }
    bool isCheckedIn = await firebaseService.isUserCheckedInForEvent(
        userUID, widget.event.eventID);
    setState(() {
      // changing save to saved
      _isCheckedIn = isCheckedIn;
    });
  }

  // Function to update the event page
  void updateEventPage() {
    checkIfUserSaved();
    checkIfUserCheckedIn();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.02);
    double edgeInsets = (MediaQuery.of(context).size.width * 0.02);
    double widgetHeight = (MediaQuery.of(context).size.height * 0.25);

    return GestureDetector(
      onTap: () {
        // Navigate to the event page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventPage(
                event: widget.event,
                onUpdateEventPage: widget.onUpdateEventPage),
          ),
        );
      },
      child: Container(
        height: widgetHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey),
          image: DecorationImage(
            image: WebImageService.buildImageProvider(widget.event.eventPhoto),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3), BlendMode.multiply),
          ),
          // put a black gradient
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: widgetHeight * 0.01,
              left: edgeInsets,
              right: edgeInsets,
              child: Container(
                padding: EdgeInsets.all(edgeInsets),
                decoration: BoxDecoration(
                  color: Colors.transparent, // Make background transparent
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text left
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: screenWidth * 0.65,
                              child: Text(
                                widget.event.eventTitle,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: sizedBoxHeight * 0.5),
                            EventDateRangeDisplay(
                              sessions: widget.event.eventSessions,
                            ),
                          ],
                        ),
                        RichText(
                          text: TextSpan(
                            text: '${widget.event.eventPoints}',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: ' pts',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sizedBoxHeight * 0.5),
                  ],
                ),
              ),
            ),
            // Positioned Heart Icon remains the same
            Positioned(
              top: sizedBoxHeight,
              right: sizedBoxHeight,
              child: GestureDetector(
                onTap: () async {
                  _isSaved = await firebaseService.hasUserSavedEvent(
                      userUID, widget.event.eventID);
                  if (_isSaved) {
                    firebaseService.unsaveEvent(widget.event.eventID);
                  } else {
                    firebaseService.saveEvent(widget.event.eventID);
                  }
                  setState(() {
                    _isSaved = !_isSaved; // Toggle saved status
                  });
                },
                child: Icon(
                  _isSaved ? Icons.favorite : Icons.favorite_border,
                  color: _isSaved ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
