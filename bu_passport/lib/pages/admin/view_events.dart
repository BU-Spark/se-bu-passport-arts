import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/services/firebase_service.dart';

class UpdateEventInfoPage extends StatefulWidget {
  const UpdateEventInfoPage({Key? key}) : super(key: key);

  @override
  _UpdateEventInfoPageState createState() => _UpdateEventInfoPageState();
}

class _UpdateEventInfoPageState extends State<UpdateEventInfoPage> {
  final db = FirebaseFirestore.instance;
  FirebaseService firebaseService = FirebaseService(db: FirebaseFirestore.instance);
  late Future<List<Event>> fetchEventsFuture;

  @override
  void initState() {
    super.initState();
    fetchEventsFuture = firebaseService.fetchEventsFromNow();
  }

  // Function to navigate to the edit event page or open a dialog
  void navigateToEditEvent(Event event) {
    // You can add code here to open a dialog or navigate to a detailed editing page
    // For now, we'll use a placeholder action
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Event"),
        content: Text("Edit options for ${event.eventTitle}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Event Info"),
      ),
      body: FutureBuilder<List<Event>>(
        future: fetchEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No events found."));
          } else {
            List<Event> events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                Event event = events[index];
                String formattedDate = DateFormat('yyyy/MM/dd HH:mm').format(event.eventStartTime);
                return ListTile(
                  title: Text(event.eventTitle),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date: ${formattedDate}"), // Display event date
                      Text("Points: ${event.eventPoints}"),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => navigateToEditEvent(event),
                    child: Text("Edit"),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
