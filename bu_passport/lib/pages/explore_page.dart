// home page welcoming user with sign out button

import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/components/event_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bu_passport/services/firebase_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);
  @override
  State<ExplorePage> createState() => _HomePageState();
}

class _HomePageState extends State<ExplorePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  List<Event> eventList = []; // List to store events data
  String _searchQuery = '';
  late Future<List<Event>> fetchEventsFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchEventsFuture = FirebaseService.fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.05);

    return Scaffold(
      body: Center(
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: sizedBoxHeight),
            Text(
              'Events',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: sizedBoxHeight),
            // Search bar
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // Update search query
                });
              },
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            FutureBuilder<List<Event>>(
              future: fetchEventsFuture, // Call fetchEvents() to get events
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator while fetching events
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // If events are fetched successfully, display them
                  List<Event>? events = snapshot.data;
                  if (events != null && events.isNotEmpty) {
                    List<Event> filteredEvents =
                        FirebaseService.filterEvents(events, _searchQuery);
                    return ListView(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      children: filteredEvents.map((event) {
                        return EventWidget(event: event);
                      }).toList(),
                    );
                  } else {
                    return Text('No events found');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
