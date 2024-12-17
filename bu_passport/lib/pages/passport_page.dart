import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:bu_passport/services/firebase_service.dart';
import 'package:bu_passport/components/passport_widget.dart';
import 'package:bu_passport/components/sticker_widget.dart';
import 'package:bu_passport/classes/passport.dart';

// The PassportPage is a StatefulWidget that allows users to view their passport.
class PassportPage extends StatefulWidget {
  const PassportPage({Key? key}) : super(key: key);

  @override
  _PassportPageState createState() => _PassportPageState();
}

// The _PassportPageState handles the state of the PassportPage.
class _PassportPageState extends State<PassportPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = true; // Indicates if the page is currently loading data.
  FirebaseService firebaseService = FirebaseService(
      db: FirebaseFirestore
          .instance); // Firebase service instance for database operations.

  User? finalUser = FirebaseAuth.instance.currentUser;
  late Future<DocumentSnapshot>
      _userProfileFuture; // Future for retrieving user data from Firestore.

  List<int> userStickerIds = [];

  @override
  void initState() {
    super.initState();
    if (finalUser != null) {
      _userProfileFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(finalUser!.uid)
          .get();
      fetchUserStickers();
    }
  }

  Future<void> fetchUserStickers() async {
    try {
      if (finalUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(finalUser!.uid)
            .get();
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          List<dynamic> collectedStickers = userData['userCollectedStickers'] ?? [];
          List<int> stickerIds = collectedStickers.cast<int>();
          setState(() {
            userStickerIds = stickerIds;
            isLoading = false;
          });
        } else {
          print("User document does not exist");
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user stickers: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double sizedBoxHeight = screenHeight * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Passport', style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 0.5,
                letterSpacing: -0.33,)
        ),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: sizedBoxHeight),
                // Passport book widget
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.0),
                    child: PassportBookWidget(),
                  ),
                ),
                // Stickers
                const Text("Stickers", textAlign: TextAlign.left, 
                  style: TextStyle(color: Color(0xFF847F8B),
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  height: 3,
                  letterSpacing: 0.10,)
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: StickerWidget(
                      stickerIds: userStickerIds,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}