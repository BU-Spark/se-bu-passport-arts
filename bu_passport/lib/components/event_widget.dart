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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.02);
    double edgeInsets = (MediaQuery.of(context).size.width * 0.02);

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
        padding: EdgeInsets.all(edgeInsets),
        child: Stack(
          children: [
            Image.asset(
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
                    widget.event.eventTitle,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color on top of the image
                    ),
                  ),
                  SizedBox(height: sizedBoxHeight),
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
