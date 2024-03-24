import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/pages/event_page.dart';
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
    return GestureDetector(
      onTap: () {
        // Navigate to the event page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventPage(event: widget.event),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Stack(
          children: [
            // Background image
            Image.network(
              widget.event.eventPhoto,
              width: double.infinity, // Use full width
              fit: BoxFit.cover, // Cover the container with the image
            ),
            // Texts overlaid on the image
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.eventName,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color on top of the image
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '${widget.event.eventLocation}',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
