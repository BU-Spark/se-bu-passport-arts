// home page welcoming user with sign out button

import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/components/EventWidget.dart';
import 'package:bu_passport/pages/calendar_page.dart';
import 'package:bu_passport/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  late Future<List<Event>> _fetchEventsFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchEventsFuture = fetchEvents();
  }

  Future<List<Event>> fetchEvents() {
    eventList.clear();
    CollectionReference events = db.collection('events');

    return events.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        final eventData = doc.data() as Map<String, dynamic>;
        Event event = Event(
          eventId: doc.id,
          eventName: eventData['eventName'],
          eventPhoto: eventData['eventPhoto'],
          eventLocation: eventData['eventLocation'],
          eventTime: (eventData['eventTime'] as Timestamp).toDate(),
          eventTags: List<String>.from(eventData['eventTags'] ?? []),
          registeredUsers:
              List<String>.from(eventData['registeredUsers'] ?? []),
        );
        eventList.add(event); // Add the event data to the list
      });
      // print('Events in eventList: $eventList');
      return eventList;
    }).catchError((error) => print("Failed to fetch events: $error"));
  }

  // Function to filter events based on search query
  List<Event> _filterEvents(List<Event> events, String query) {
    print('EventList: ${events}');
    if (query.isEmpty) {
      return events; // If query is empty, return all events
    }
    // Filter events based on the search query
    return events.where((event) {
      return event.eventName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome ${user.email!}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('Sign Out'),
            ),
            const SizedBox(height: 20),
            Text(
              'Events',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
              future: _fetchEventsFuture, // Call fetchEvents() to get events
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
                        _filterEvents(events, _searchQuery);
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
