import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../classes/session.dart';

class EventTimeDisplay extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;

  const EventTimeDisplay({
    Key? key,
    required this.startTime,
    required this.endTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16.0, color: Colors.black),
            children: [
              const TextSpan(
                text: 'Start: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: DateFormat('h:mm a, EEEE, MMMM d, y').format(startTime),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0), // Use desired spacing
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16.0, color: Colors.black),
            children: [
              const TextSpan(
                text: 'End: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: DateFormat('h:mm a, EEEE, MMMM d, y').format(endTime),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}


class AllSessionsDisplay extends StatelessWidget {
  final List<Session> sessions;

  const AllSessionsDisplay({
    Key? key,
    required this.sessions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sessions.map((session) {
        return EventTimeDisplay(
          startTime: session.sessionStartTime,
          endTime: session.sessionEndTime,
        );
      }).toList(),
    );
  }
}

class EventDateRangeDisplay extends StatelessWidget {
  final List<Session> sessions;

  const EventDateRangeDisplay({
    Key? key,
    required this.sessions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return Text("No sessions available");

    // Find the minimum start time and maximum end time
    DateTime earliestStart = sessions.first.sessionStartTime;
    DateTime latestEnd = sessions.first.sessionEndTime;

    for (var session in sessions) {
      if (session.sessionStartTime.isBefore(earliestStart)) {
        earliestStart = session.sessionStartTime;
      }
      if (session.sessionEndTime.isAfter(latestEnd)) {
        latestEnd = session.sessionEndTime;
      }
    }

    // Format the dates
    String startDate = DateFormat.yMMMd().format(earliestStart);
    String endDate = DateFormat.yMMMd().format(latestEnd);

    return Text(
      "$startDate - $endDate",
      style: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }
}
