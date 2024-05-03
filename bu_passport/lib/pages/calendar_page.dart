import 'package:bu_passport/components/event_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:bu_passport/services/firebase_service.dart';
import 'package:bu_passport/classes/event.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  List<Event> _allEvents = []; // List to store events
  FirebaseService firebaseService = FirebaseService(
      db: FirebaseFirestore
          .instance); // List to store events for the selected day
  late Future<List<Event>> _allEventsFuture;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _fetchEvents(); // Initialize the future to fetch events
    _allEventsFuture = firebaseService.fetchEvents();
  }

  // Function to fetch events

  Future<void> _fetchEvents() async {
    List<Event> allEvents = await firebaseService.fetchEvents();
    setState(() {
      _allEvents = allEvents;
    });
  }

  void updateEventPage() {}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double defaultPadding = screenWidth * 0.02;
    double itemVerticalMargin = screenHeight * 0.005;
    double itemHorizontalMargin = screenWidth * 0.02;

    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.05);

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: FutureBuilder<List<Event>>(
        future: _allEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Event>? events = snapshot.data;
            if (events == null || events.isEmpty) {
              return Center(
                child: Text('No events found.'),
              );
            }
            // Filter events for the selected day
            List<Event> selectedEvents =
                firebaseService.fetchEventsForDay(_selectedDay, events);
            return Column(
              children: [
                TableCalendar(
                  calendarFormat: _calendarFormat,
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  // Provide events to the calendar
                  eventLoader: (day) {
                    return _allEvents
                        .where((event) =>
                            event.eventStartTime.year == day.year &&
                            event.eventStartTime.month == day.month &&
                            event.eventStartTime.day == day.day)
                        .toList();
                  },
                ),
                SizedBox(height: sizedBoxHeight),
                Text(
                  '${DateFormat('EEEE, MMMM d, y').format(_selectedDay)}',
                  style: TextStyle(fontSize: 20),
                ),
                Expanded(
                  child: selectedEvents.isEmpty
                      ? Center(
                          child: Text('No events for today.',
                              style: TextStyle(fontSize: 20)))
                      : Padding(
                          padding: EdgeInsets.all(defaultPadding),
                          child: ListView.builder(
                            itemCount: selectedEvents.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: itemVerticalMargin,
                                  horizontal: itemHorizontalMargin,
                                ),
                                child: EventWidget(
                                    event: selectedEvents[index],
                                    onUpdateEventPage: updateEventPage),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
