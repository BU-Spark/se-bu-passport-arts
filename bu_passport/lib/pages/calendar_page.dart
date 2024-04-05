import 'package:bu_passport/components/event_widget.dart';
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
  late List<Event> _allEvents; // List to store events
  late List<Event> _selectedEvents; // List to store events for the selected day

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _allEvents = []; // Initialize the events list
    _selectedEvents = []; // Initialize the events list
    _fetchEvents(); // Fetch all events
    _fetchEventsForSelectedDay(); // Fetch events for the selected day
  }

  Future<void> _fetchEvents() async {
    List<Event> allEvents = await FirebaseService.fetchEvents();
    setState(() {
      _allEvents = allEvents;
    });
  }

  Future<void> _fetchEventsForSelectedDay() async {
    List<Event> selectedEvents =
        await FirebaseService.fetchEventsForDay(_selectedDay, _allEvents);
    setState(() {
      _selectedEvents = selectedEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.05);
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Column(
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
                _fetchEventsForSelectedDay(); // Fetch events for the selected day
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
            child: ListView.builder(
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                return EventWidget(event: _selectedEvents[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
