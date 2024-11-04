import 'dart:typed_data';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bu_passport/classes/categorized_events.dart';
import 'package:bu_passport/components/event_widget.dart';
import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/util/profile_pic.dart';
import 'package:bu_passport/util/image_select.dart';

import '../classes/new_categorized_events.dart';
import '../classes/new_event.dart';
import '../services/new_firebase_service.dart';

// The ProfilePage is a StatefulWidget that allows users to view and edit their profile.
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

// The _ProfilePageState handles the state of the ProfilePage, including user data and events.
class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  List<NewEvent> attendedEvents = [];
  List<NewEvent> userSavedEvents = [];
  bool isLoading = true; // Indicates if the page is currently loading data.
  NewFirebaseService firebaseService = NewFirebaseService(
      db: FirebaseFirestore
          .instance); // Firebase service instance for database operations.

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  File? selectedImageFile; // The file for a selected profile image.
  bool _isEditing =
      false; // Flag to check if the user is editing their profile.
  final ImageService _imageService = ImageService();
  String? userProfileImageUrl; // URL for the user's profile image.

  // Method to save profile changes to Firestore and Firebase Auth.
  void _saveProfileChanges(String firstName, String lastName) async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(finalUser!.uid);
    await userDoc.update({
      'firstName': firstName,
      'lastName': lastName,
    });
    final user = FirebaseAuth.instance.currentUser;
    await user?.updateDisplayName("$firstName $lastName");
    await user?.reload();

    setState(() {
      userProfileImageUrl =
          user?.photoURL; // Update in case the photoURL changed
    });
  }

  User? finalUser = FirebaseAuth.instance.currentUser;
  late TabController _tabController; // Controller for managing tabs.
  late Future<DocumentSnapshot>
      _userProfileFuture; // Future for retrieving user data from Firestore.

  @override
  void initState() {
    super.initState();
    userProfileImageUrl = FirebaseAuth.instance.currentUser?.photoURL;
    _tabController = TabController(length: 2, vsync: this);
    if (finalUser != null) {
      _userProfileFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(finalUser!.uid)
          .get();
    }
    fetchAndDisplayEvents();
  }

  // Fetches and displays events categorized into attended and saved.
  void fetchAndDisplayEvents() async {
    try {
      NewCategorizedEvents categorizedEvents =
          await firebaseService.fetchAndCategorizeEvents();
      setState(() {
        attendedEvents = categorizedEvents.attendedEvents;
        userSavedEvents = categorizedEvents.userSavedEvents;
      });
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  // Refresh the events when returning from EventPage
  void updateEventPage() {
    fetchAndDisplayEvents();
    setState(() {
      _userProfileFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(finalUser!.uid)
          .get();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Uint8List? _image;

  // Uploads an image to Firebase Storage and returns the URL.
  Future<String?> uploadImageToFirebase(Uint8List imageBytes) async {
    // Unique file name for the image
    String fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";

    // Attempt to upload image to Firebase Storage
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);
      UploadTask uploadTask = ref.putData(imageBytes);

      // Await completion of the upload task
      TaskSnapshot snapshot = await uploadTask;
      // Get the download URL of the uploaded file
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Updates the Firebase user profile with a new image URL.
  void updateFirebaseUserProfile(String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.updatePhotoURL(imageUrl);
      await firebaseService.updateUserProfileURL(imageUrl);
      await user.reload(); // Reload the user profile to reflect the update
    }
  }

  // Selects an image using the Image Picker and uploads it to Firebase.
  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });

    // Upload the image to Firebase Storage and get the URL
    String? imageUrl = await uploadImageToFirebase(img);
    if (imageUrl != null) {
      // Update the Firebase user's photoURL with the new image URL
      updateFirebaseUserProfile(imageUrl);
    }
  }

  // Builds a list of event widgets based on the passed events list.
  Widget _buildEventsList(List<NewEvent> events, String message) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double verticalMargin = screenHeight * 0.01; // 1% of screen height
    double horizontalMargin = screenWidth * 0.035; // 2% of screen width

    if (events.isEmpty) {
      return Center(child: Text(message, style: TextStyle(fontSize: 20)));
    } else {
      return ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final uniqueKey =
              '${events[index].eventID}-${DateTime.now().millisecondsSinceEpoch.hashCode}';
          final event = events[index];
          return Card(
              margin: EdgeInsets.symmetric(
                  vertical: verticalMargin, horizontal: horizontalMargin),
              child: EventWidget(
                  key: ValueKey(uniqueKey),
                  event: event, onUpdateEventPage: updateEventPage));
          // Use your EventWidget to display each event
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.05);

    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(finalUser!.uid);

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () async {
              if (_isEditing) {
                _saveProfileChanges(
                  _firstNameController.text,
                  _lastNameController.text,
                );
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Name and Profile Photo
          Expanded(
            flex: 2,
            child: FutureBuilder<DocumentSnapshot>(
              future: _userProfileFuture,
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error fetching user data"));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text("User data not found"));
                }
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                String fullName =
                    '${userData['firstName'] ?? 'Not set'} ${userData['lastName'] ?? ''}';
                int userPoints = userData['userPoints'] ?? 0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (selectedImageFile != null) ...[
                      Image.file(selectedImageFile!),
                      SizedBox(height: sizedBoxHeight),
                    ],
                    GestureDetector(
                      onTap: () {
                        selectImage(); // Invoke the method for image selection and upload
                      },
                      child: CircleAvatar(
                        key: ValueKey(DateTime.now()
                            .millisecondsSinceEpoch), // Use a unique key
                        radius: 50,
                        backgroundImage: _image != null
                            ? MemoryImage(
                                _image!) // Use MemoryImage if _image is not null
                            : (userProfileImageUrl != null
                                    ? NetworkImage(
                                        userProfileImageUrl!) // Use the network image if available
                                    : NetworkImage(
                                        'https://via.placeholder.com/150') // Default image
                                ) as ImageProvider,
                      ),
                    ),
                    SizedBox(height: sizedBoxHeight),
                    if (_isEditing) ...[
                      TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(labelText: 'First Name'),
                      ),
                      TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(labelText: 'Last Name'),
                      ),
                    ] else ...[
                      Text(fullName, style: TextStyle(fontSize: 20)),
                      Text(userPoints.toString() + ' points'),
                    ],
                  ],
                );
              },
            ),
          ),
          // This is the Events Menu
          Expanded(
            flex: 3,
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Saved'),
                    Tab(text: 'Attended'),
                  ],
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEventsList(userSavedEvents,
                        "No saved events."), // Saved events list
                    _buildEventsList(attendedEvents,
                        "No attended events."), // Attended events list
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
