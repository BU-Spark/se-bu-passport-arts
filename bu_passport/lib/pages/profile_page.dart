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
import 'package:bu_passport/services/firebase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  List<Event> attendedEvents = [];
  List<Event> upcomingEvents = [];
  bool isLoading = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  File? selectedImageFile;
  bool _isEditing = false;
  final ImageService _imageService = ImageService();
  String? userProfileImageUrl;

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
  late TabController _tabController;
  late Future<DocumentSnapshot> _userProfileFuture;

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

  void fetchAndDisplayEvents() async {
    try {
      CategorizedEvents categorizedEvents =
          await FirebaseService.fetchAndCategorizeEvents();
      setState(() {
        attendedEvents = categorizedEvents.attendedEvents;
        upcomingEvents = categorizedEvents.upcomingEvents;
      });
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Uint8List? _image;

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

  void updateFirebaseUserProfile(String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.updatePhotoURL(imageUrl);
      await user.reload(); // Reload the user profile to reflect the update
    }
  }

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

  Widget _buildEventsList(List<Event> events) {
    print(events);
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventWidget(
            event: event); // Use your EventWidget to display each event
      },
    );
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
              Navigator.of(context).pushReplacementNamed(
                  '/login'); // Replace with your login route
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
                int userPoints = userData['points'] ?? 0;
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
                    Tab(text: 'Attended'),
                    Tab(text: 'Upcoming'),
                  ],
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEventsList(attendedEvents), // Attended events list
                    _buildEventsList(upcomingEvents), // Upcoming events list
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
