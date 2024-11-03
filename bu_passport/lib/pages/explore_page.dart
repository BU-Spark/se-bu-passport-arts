import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/components/event_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../classes/new_event.dart';
import '../services/new_firebase_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);
  @override
  State<ExplorePage> createState() => _HomePageState();
}

class _HomePageState extends State<ExplorePage> {
  final user = FirebaseAuth.instance.currentUser?.uid ?? "";
  final db = FirebaseFirestore.instance;
  List<Event> eventList = []; // List to store events data
  String _searchQuery = '';
  late Future<List<NewEvent>> fetchEventsFuture;
  int _selectedIndex = 0;
  NewFirebaseService firebaseService =
      NewFirebaseService(db: FirebaseFirestore.instance);
  @override
  void initState() {
    super.initState();
    fetchEventsFuture = firebaseService.fetchEventsFromNow();
  }

  // not the most effiicent solution need to improve **

  // Update event list in explore page with events from now to future
  void updateEventPage() {
    setState(() {
      fetchEventsFuture = firebaseService.fetchEventsFromNow();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.05);
    double edgeInsets = (MediaQuery.of(context).size.width * 0.02);

    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
      ),
      body: Center(
        child: ListView(
          children: [
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
            FutureBuilder<List<NewEvent>>(
              future: fetchEventsFuture, // Call fetchEvents() to get events
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator while fetching events
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // If events are fetched successfully, display them
                  List<NewEvent>? events = snapshot.data;
                  if (events != null && events.isNotEmpty) {
                    List<NewEvent> filteredEvents =
                        firebaseService.filterEvents(events, _searchQuery);
                    return Padding(
                      padding: EdgeInsets.all(edgeInsets * 1.5),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: filteredEvents.length,
                        separatorBuilder: (BuildContext context, int index) {
                          // Add vertical space between items
                          return SizedBox(height: sizedBoxHeight * 0.4);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          // Return your EventWidget
                          return EventWidget(
                            event: filteredEvents[index],
                            onUpdateEventPage: updateEventPage,
                          );
                        },
                      ),
                    );
                  } else {
                    // When there are no events to show
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
