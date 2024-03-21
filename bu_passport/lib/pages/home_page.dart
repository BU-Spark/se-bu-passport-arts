// home page welcoming user with sign out button

import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/components/EventWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  List<Event> eventList = []; // List to store events data

  @override
  void initState() {
    super.initState();
  }

  Future<List<Event>> fetchEvents() {
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
      print('Events in eventList: $eventList');
      return eventList;
    }).catchError((error) => print("Failed to fetch events: $error"));
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
            FutureBuilder<List<Event>>(
              future: fetchEvents(), // Call fetchEvents() to get events
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator while fetching events
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // If events are fetched successfully, display them
                  List<Event>? events = snapshot.data;
                  if (events != null && events.isNotEmpty) {
                    return ListView(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      children: events.map((event) {
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
