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
  late TabController _tabController; // Controller for managing tabs.
  late Future<DocumentSnapshot>
      _userProfileFuture; // Future for retrieving user data from Firestore.

  List<Sticker> dummy_stickers = [Sticker(id: 2)];

  @override
  void initState() {
    super.initState();
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
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double sizedBoxHeight = screenHeight * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Passport'),
      ),
      body: Column(
        children: [
          SizedBox(height: sizedBoxHeight),
          // Passport book widget
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(bottom: 16.0),
              child: PassportBookWidget(),
            ),
          ),
          SizedBox(height: sizedBoxHeight),
          // Stickers
          Expanded(
            flex: 3,
            child: Center(
              child: StickerWidget(
                stickers: dummy_stickers,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
