import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bu_passport/models/events.dart';
import 'package:flutter/widgets.dart';
import 'package:bu_passport/widgets/event_card.dart';
import 'package:bu_passport/util/profile_pic.dart';
import 'dart:io'; // This is required for using the File class

// This is just tempory: hardcoding event information (based on the Event model)
// Eventually: will be able to pull this information from Firebase - hopefully
List<Event> mockEvents = [
  Event(
    eventName: 'Boston Youth Symphony Orchestras Concert',
    location: '808 Commonwealth',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/se-bu-passport.appspot.com/o/IMG_6490.jpg?alt=media&token=9a318eba-73a5-49d8-bbcf-2672ff8544af',
  ),
  Event(
      eventName: 'BU Student Composers Concert',
      location: '808 Commonwealth',
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/se-bu-passport.appspot.com/o/IMG_6490.jpg?alt=media&token=9a318eba-73a5-49d8-bbcf-2672ff8544af'),
];

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  File? selectedImageFile;
  bool _isEditing = false;
  final ImageService _imageService = ImageService();
  String? userProfileImageUrl;

  void _manualRefresh() {
    setState(() {
      // Increment a counter or update a timestamp state variable
      // Or simply reassign userProfileImageUrl to trigger a rebuild
      // Assuming userProfileImageUrl is already updated, just not reflected due to caching
      userProfileImageUrl = FirebaseAuth.instance.currentUser?.photoURL;
    });
  }

  void _saveProfileChanges(String firstName, String lastName) async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(finalUser!.uid);
    await userDoc.update({
      'firstName': firstName,
      'lastName': lastName,
    });

    // Optionally, update Firebase Auth display name
    final user = FirebaseAuth.instance.currentUser;
    await user?.updateProfile(displayName: "$firstName $lastName");
    await user?.reload();

    // Update local state to reflect changes
    setState(() {
      userProfileImageUrl =
          user?.photoURL; // Update in case the photoURL changed
      // You might also update local variables storing the user's name
    });
  }

  void _handleImageSelection() async {
    File? imageFile = await _imageService.pickImage();
    if (imageFile != null) {
      String? imageUrl = await _imageService.uploadImage(imageFile);
      if (imageUrl != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Update the user's profile photo URL in Firebase Authentication
          await user.updatePhotoURL(imageUrl);

          await user.reload();

          // Optional: Update the user's profile in Firestore or any other database you're using
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'profileImageUrl': imageUrl,
          });
          if (!mounted) return;
          // final updatedUser = FirebaseAuth.instance.currentUser;
          // Update the state to reflect the new profile image
          setState(() {
            userProfileImageUrl = user.photoURL;
          });
        }
      }
    }
  }

  // void _handleImageSelection() async {
  //   File? imageFile = await _imageService.pickImage();
  //   if (imageFile != null) {
  //     // Store the selected image in the state and update the UI to show a preview
  //     setState(() {
  //       selectedImageFile = imageFile;
  //     });
  //     // Don't upload the image yet. Wait for user confirmation.
  //   }
  // }

  // void _handleImageUpload() async {
  //   if (selectedImageFile != null) {
  //     String? imageUrl = await _imageService.uploadImage(selectedImageFile!);
  //     if (imageUrl != null) {
  //       final user = FirebaseAuth.instance.currentUser;
  //       if (user != null) {
  //         await user.updatePhotoURL(imageUrl);
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(user.uid)
  //             .update({
  //           'profileImageUrl': imageUrl,
  //         });
  //         await user.reload();

  //         if (!mounted) return;

  //         setState(() {
  //           userProfileImageUrl = imageUrl;
  //           selectedImageFile = null; // Reset or clear the selected image file
  //         });
  //       }
  //     }
  //   }
  // }

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
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Assuming 'finalUser' is not null
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(finalUser!.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
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
        ],
      ),
      body: Column(
        children: <Widget>[
          // Name and Profile Photo
          Expanded(
            flex:
                3, // Adjust flex as needed to size the top and bottom parts of the screen appropriately
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
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (selectedImageFile != null) ...[
                      Image.file(selectedImageFile!),
                      SizedBox(height: 8),
                      // ElevatedButton(
                      //   onPressed: _handleImageUpload,
                      //   child: Text('Confirm Upload'),
                      // ),
                    ],
                    // backgroundImage: finalUser?.photoURL != null
                    //     ? NetworkImage(finalUser!.photoURL!)
                    //     : NetworkImage('https://via.placeholder.com/150'),
                    //   backgroundImage: NetworkImage(userProfileImageUrl ??
                    //       'https://via.placeholder.com/150'),
                    // ),

                    CircleAvatar(
                      key: ValueKey(DateTime.now()
                          .millisecondsSinceEpoch), // Use a unique key
                      radius: 50,
                      backgroundImage: selectedImageFile != null
                          ? FileImage(selectedImageFile!) as ImageProvider<
                              Object> // Use ! to assert it's not null
                          : (userProfileImageUrl != null
                                  ? NetworkImage(
                                      userProfileImageUrl!) // This is fine as is
                                  : NetworkImage(
                                      'https://via.placeholder.com/150'))
                              as ImageProvider<Object>,
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                        onPressed: _handleImageSelection,
                        child: Text('Upload Profile Picture')),

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
                    ],

                    // Text(fullName, style: TextStyle(fontSize: 20)),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: _manualRefresh,
                      tooltip: 'Refresh Profile Picture',
                    ),
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
                    _buildMockEventList(
                        'Attended'), // Replace with your data source
                    _buildMockEventList(
                        'Upcoming'), // Replace with your data source
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Building the Widget that displays the event (mostly hardcoded at the moment, except for
  // the event photo, which is uploaded to Firebase Storage)
  Widget _buildMockEventList(String type) {
    return ListView.builder(
      itemCount: mockEvents.length,
      itemBuilder: (BuildContext context, int index) {
        Event event = mockEvents[index];

        // Displaying the event card
        return EventCard(
          title: event.eventName,
          location: event.location,
          imageUrl: event.imageUrl,
          date: '09/13/2023', // Placeholder date, replace with actual date
          points: 25, // Placeholder points, replace with actual points
          rating: 3, // Placeholder rating, replace with actual rating
        );
      },
    );
  }
}
