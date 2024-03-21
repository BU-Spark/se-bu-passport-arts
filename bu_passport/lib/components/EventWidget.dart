// ignore_for_file: prefer_const_constructors

import 'package:bu_passport/classes/event.dart';
import 'package:flutter/material.dart';

class EventWidget extends StatefulWidget {
  final Event event;
  const EventWidget({Key? key, required this.event}) : super(key: key);

  @override
  _EventWidgetState createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(children: [
        Text(
          widget.event.eventName,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          'Location: ${widget.event.eventLocation}',
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(height: 8.0),
        Text(
          'Date: ${widget.event.eventTime.toString()}',
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(height: 8.0),
        // You can display the photo using Image.network if you have the URL
        // Assuming you have the URL of the photo stored in event.eventPhoto
        Image.network(
          widget.event.eventPhoto,
          width: 200, // Adjust width as needed
          height: 200, // Adjust height as needed
        ),
      ]),
    );
  }
}
