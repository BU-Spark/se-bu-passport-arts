//import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/components/sessionCheckList.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bu_passport/services/geocoding_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import '../components/ChipList.dart';
import '../components/checkin_options_dialog.dart';
import '../components/checkin_success_dialog.dart';
import '../components/time_span.dart';
import '../config/secrets.dart';
import '../services/firebase_service.dart';
import '../services/web_image_service.dart';

import 'package:http/http.dart' as http;

class EventPage extends StatefulWidget {
  final Event event;

  const EventPage(
      {Key? key, required this.event, required this.onUpdateEventPage})
      : super(key: key);
  final Function onUpdateEventPage;

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  FirebaseService firebaseService =
      FirebaseService(db: FirebaseFirestore.instance);
  GeocodingService geocodingService = GeocodingService();

  bool _isSaved = false; // Track whether the user is interested in the event
  String? _savedSession = null;
  bool _isCheckedIn = false; // To track if the user has checked in
  String photoUrl = "";
  bool _isSessionListVisible = false;
  String? _selectedSession = null;
  bool _eventHasUpcomingSessions = true;


  Future<ui.Image> _loadImage(File file) async {
    final bytes = await file.readAsBytes();
    return await decodeImageFromList(bytes);
  }

  Future<ui.Image> _loadImageFromAssets(String path) async {
    // Load the image data from the assets
    final ByteData data = await rootBundle.load(path);
    final List<int> bytes = data.buffer.asUint8List();

    // Decode the image data to a ui.Image
    return await decodeImageFromList(Uint8List.fromList(bytes));
  }

  Future<ui.Image> _loadImageFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    final Uint8List bytes = response.bodyBytes;
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }
// Checks if user saved event -- if so, the button will reflect that
  @override
  void initState() {
    super.initState();
    checkIfUserSaved();
    checkIfUserIsCheckedIn();
    _eventHasUpcomingSessions = widget.event.hasUpcomingSessions(DateTime.now());
  }


  String saveButtonText(){
    if(_isCheckedIn){
      return "Save";
    }else{
      if(_eventHasUpcomingSessions){
        if(_isSessionListVisible){
          return "Save";
        }else{
          if(_isSaved){
            return "Edit schedule";
          }else{
            return "Add to schedule";
          }
        }
      }else{// Event expired
        if(_isSaved){
          return "Remove from schedule";
        }else{
          return "Event expired";
        }
      }
    }
  }

  bool saveButtonStatus(){
    if(_isCheckedIn||(!_eventHasUpcomingSessions&&(!_isSaved))){
      return false;
    }
    return true;
  }
  // Function to check if user has saved the event

  void checkIfUserSaved() async {
    String userUID = FirebaseAuth.instance.currentUser?.uid ?? "";
    // Ensure there's a user logged in
    if (userUID.isEmpty) {
      print("User is not logged in.");
      return;
    }
    bool isSaved =
        await firebaseService.hasUserSavedEvent(userUID, widget.event.eventID);
    String? savedSession = await firebaseService.userSavedSession(userUID, widget.event.eventID);
    setState(() {
      // changing save to saved
      _isSaved = isSaved;
      _savedSession = savedSession;
    });
  }

  void onSelectionChanges(String? selectedSession){
    setState(() {
      _selectedSession = selectedSession;
    });
    print("selected is $_selectedSession");
  }

  // Function to check if user has checked in to the event

  void checkIfUserIsCheckedIn() async {
    String userUID = FirebaseAuth.instance.currentUser?.uid ?? "";
    // Ensure there's a user logged in
    if (userUID.isEmpty) {
      print("User is not logged in.");
      return;
    }
    bool isCheckedIn = await firebaseService.isUserCheckedInForEvent(
        userUID, widget.event.eventID);
    setState(() {
      _isCheckedIn = isCheckedIn;
    });
  }

  // Function to check if the event is happening today
  bool isEventToday(DateTime eventDateTimestamp) {
    final eventDateTimeLocal = tz.TZDateTime.from(eventDateTimestamp, tz.local);
    final nowLocal = tz.TZDateTime.now(tz.local);
    return nowLocal.year == eventDateTimeLocal.year &&
        nowLocal.month == eventDateTimeLocal.month &&
        nowLocal.day == eventDateTimeLocal.day;
  }

  // Function to check in
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

  Future<void> checkInWithPhoto() async {
    try{
      firebaseService.checkInUserForEvent(
          widget.event.eventID, widget.event.eventPoints+5, widget.event.eventStickers);
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if(pickedFile!=null){
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        firebaseService.uploadCheckinImage(widget.event.eventID, imageBytes);
        final photo = await _loadImage(File(pickedFile.path));
        final frame = await _loadImageFromAssets('assets/images/stickers/frame.png');
        ui.Image? sticker1;
        ui.Image? sticker2;
        if (widget.event.eventStickers.isNotEmpty) sticker1 = await _loadImageFromAssets('assets/images/stickers/'+widget.event.eventStickers[0].name+".png");
        if (widget.event.eventStickers.length > 1) sticker2 = await _loadImageFromAssets('assets/images/stickers/'+widget.event.eventStickers[1].name+".png");
        widget.onUpdateEventPage();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SuccessDialog(
              points: widget.event.eventPoints+5,
              eventTitle: widget.event.eventTitle,
              image: photo,
              frame: frame,
              sticker1: sticker1,
              sticker2: sticker2,
            );
          },
        );

        firebaseService.unsaveEvent(widget.event.eventID);
      }else{

      }

    }catch(e){
      print("Unable to checkin: ${e.toString()}");
      return;
    }

  }

  Future<void> checkInWithoutPhoto()async {
    try{
      firebaseService.checkInUserForEvent(
          widget.event.eventID, widget.event.eventPoints, widget.event.eventStickers);
      ui.Image? sticker1;
      ui.Image? sticker2;
      if (widget.event.eventStickers.isNotEmpty) sticker1 = await _loadImageFromAssets('assets/images/stickers/'+widget.event.eventStickers[0].name+".png");
      if (widget.event.eventStickers.length > 1) sticker2 = await _loadImageFromAssets('assets/images/stickers/'+widget.event.eventStickers[1].name+".png");
      final icon = await _loadImageFromUrl(widget.event.eventPhoto);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SuccessDialog(
            points: widget.event.eventPoints,
            eventTitle: widget.event.eventTitle,
            logo: icon,
            sticker1: sticker1,
            sticker2: sticker2,
          );
        },
      );
      firebaseService.unsaveEvent(widget.event.eventID);
    }catch(e){
      return;
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
      body: Stack(
        children: [
          ListView(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image(
              image: WebImageService.buildImageProvider(widget.event.eventPhoto), // Use the helper function
              fit: BoxFit.cover,
              width: double.infinity,
              height: screenHeight * 0.4,
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
                  //SizedBox(height: sizedBoxHeight),
                  ChipList(
                    labels: widget.event.eventCategories,
                    onChipPressed: (label) {
                      //print("Selected label: $label");
                    },
                  ),
                  SizedBox(height: sizedBoxHeight*0.8),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  //TODO: Add attending users
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  SizedBox(height: sizedBoxHeight),
                  // AllSessionsDisplay(
                  //   sessions: widget.event.eventSessions,
                  // ),
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
                          WidgetSpan(
                            child: Icon(Icons.link),
                          ),
                          TextSpan(
                            text: "  ${widget.event.eventURL}",
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
                          text: 'Description: \n\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: widget.event.eventDescription,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: sizedBoxHeight),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3, // 1 part
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 16.0, color: Colors.black),
                            children: [
                              TextSpan(
                                text: 'Hours: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 8, // 4 parts
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
                          children: widget.event.eventSessions.map<Widget>((session) {
                            // Format the start and end times with month abbreviation
                            final startTime = DateFormat('MMM d, yyyy, hh:mma').format(session.sessionStartTime);
                            final endTime = DateFormat('hh:mma').format(session.sessionEndTime);

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                              child: Align(
                                alignment: Alignment.centerLeft,  // Align text to the left
                                child: Text(
                                  "$startTime - $endTime",
                                  style: TextStyle(fontSize: 14.0), // Adjust the text size as needed
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: sizedBoxHeight),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.location_on),
                        ),
                        TextSpan(
                          text: " ${widget.event.eventLocation}",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sizedBoxHeight*4,),

          ],
        ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, -2), // Offset shadow upwards
                  )
                ]
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(edgeInsets, edgeInsets * 2, edgeInsets, edgeInsets * 6),
                child: Column(
                  children: [
                    AnimatedSize(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _isSessionListVisible
                          ? SessionCheckList(sessions: widget.event.eventSessions, onSelectionChanges: onSelectionChanges, lastSavedSession: _savedSession,) // Your custom widget
                          : SizedBox.shrink(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: (
                              !widget.event.isEventHappening() ||
                                  _isCheckedIn)
                              ? null
                              : () async {
                            bool success = await checkIn();
                            if (success) {
                              bool withPhoto = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CheckInOptionsDialog();
                                },
                              );
                              if(withPhoto){
                                checkInWithPhoto();
                              } else {
                                checkInWithoutPhoto();
                              }

                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text(
                                      "Unable to check in: location too far or permission denied.")));
                            }
                          },
                          child: Text(_isCheckedIn ? 'Checked In' : 'Check In'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCheckedIn
                                ? Colors.grey
                                : (Colors.red),
                          ),
                        ),
                        SizedBox(width: sizedBoxHeight * 3),
                        ElevatedButton(
                          onPressed: (!saveButtonStatus())?null:() async {
                            if(!widget.event.hasUpcomingSessions(DateTime.now())){
                              String eventId = widget.event.eventID;
                              if(_isSaved){
                                firebaseService.unsaveEvent(eventId);
                              }
                              checkIfUserSaved();
                              widget.onUpdateEventPage();
                              return;
                            }
                            if(_isSessionListVisible){
                              String userUID =
                                  FirebaseAuth.instance.currentUser?.uid ?? "";
                              String eventId = widget.event.eventID;
                              String? sessionId = _selectedSession;
                              bool isSaved = await firebaseService.hasUserSavedEvent(
                                  userUID, eventId);
                              if (sessionId!=null) {
                                print("update: $sessionId");
                                firebaseService.saveEvent(eventId, sessionId);
                              } else {
                                firebaseService.unsaveEvent(eventId);
                              }
                              checkIfUserSaved();
                              widget.onUpdateEventPage();
                            }
                            setState(() {
                              _isSessionListVisible = !_isSessionListVisible;
                            });
                          },
                          child:Text(saveButtonText())
                          //child: Text(_eventHasUpcomingSessions?(_isSessionListVisible ? 'Save' : (_isSaved?"Edit schedule":"Add to schedule")):(_isSaved?"Remove from schedule":"Event expired")),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
        )
              ]
      ),
    );
  }
}
