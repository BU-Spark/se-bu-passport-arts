//import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bu_passport/classes/new_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bu_passport/services/geocoding_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bu_passport/classes/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'dart:typed_data' as typed_data;
import 'dart:ui' as ui;
import '../components/checkin_options_dialog.dart';
import '../components/checkin_success_dialog.dart';
import '../components/time_span.dart';
import '../services/new_firebase_service.dart';
import '../services/web_image_service.dart';

import 'package:http/http.dart' as http;

class EventPage extends StatefulWidget {
  final NewEvent event;

  const EventPage(
      {Key? key, required this.event, required this.onUpdateEventPage})
      : super(key: key);
  final Function onUpdateEventPage;

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  NewFirebaseService firebaseService =
      NewFirebaseService(db: FirebaseFirestore.instance);
  GeocodingService geocodingService = GeocodingService();

  bool _isSaved = false; // Track whether the user is interested in the event
  bool _isCheckedIn = false; // To track if the user has checked in
  String photoUrl = "";


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
    setState(() {
      // changing save to saved
      _isSaved = isSaved;
    });
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
            icon: icon,
            sticker1: sticker1,
            sticker2: sticker2,
          );
        },
      );
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
      body: ListView(
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
                SizedBox(height: sizedBoxHeight),
                AllSessionsDisplay(
                  sessions: widget.event.eventSessions,
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
                        text: 'Description: \n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: widget.event.eventDescription,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(edgeInsets),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: (
                          !widget.event.isEventHappening() ||
                          _isCheckedIn)
                      ? null
                      : () async {

                          // Your check-in logic here. On successful check-in, update the _isCheckedIn state.
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
                SizedBox(width: sizedBoxHeight * 3), // Optional spacing
                ElevatedButton(
                  onPressed: () async {
                    String userUID =
                        FirebaseAuth.instance.currentUser?.uid ?? "";
                    String eventId = widget.event.eventID;
                    bool isSaved = await firebaseService.hasUserSavedEvent(
                        userUID, eventId);
                    if (isSaved) {
                      firebaseService.unsaveEvent(eventId);
                    } else {
                      firebaseService.saveEvent(eventId);
                    }
                    setState(() {
                      _isSaved = !_isSaved; // Toggle saved status
                    });
                    widget.onUpdateEventPage();
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
