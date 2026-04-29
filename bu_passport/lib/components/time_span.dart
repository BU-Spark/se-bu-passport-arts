import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../classes/session.dart';

class AllSessionsDisplay extends StatelessWidget {
  final List<Session> sessions;

  const AllSessionsDisplay({
    Key? key,
    required this.sessions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Text("No sessions available");
    }

    final sortedSessions = [...sessions]..sort((left, right) =>
        left.sessionStartTime.compareTo(right.sessionStartTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.8),
                1: FlexColumnWidth(1.1),
                2: FlexColumnWidth(1.1),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                  ),
                  children: [
                    _TableHeaderCell('Date'),
                    _TableHeaderCell('Start'),
                    _TableHeaderCell('End'),
                  ],
                ),
                ...sortedSessions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final session = entry.value;

                  return TableRow(
                    decoration: BoxDecoration(
                      color:
                          index.isEven ? Colors.white : const Color(0xFFFAFAFA),
                    ),
                    children: [
                      _TableBodyCell(
                        DateFormat('EEE, MMM d, y')
                            .format(session.sessionStartTime),
                      ),
                      _TableBodyCell(
                        DateFormat('h:mm a').format(session.sessionStartTime),
                      ),
                      _TableBodyCell(
                        DateFormat('h:mm a').format(session.sessionEndTime),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String label;

  const _TableHeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _TableBodyCell extends StatelessWidget {
  final String value;

  const _TableBodyCell(this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.3,
        ),
      ),
    );
  }
}

class EventDateRangeDisplay extends StatelessWidget {
  final List<Session> sessions;
  final Color textColor;

  const EventDateRangeDisplay({
    Key? key,
    required this.sessions,
    this.textColor = Colors.black,
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
        color: textColor,
      ),
    );
  }
}
