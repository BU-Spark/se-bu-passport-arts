import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/pages/event_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    double widgetHeight = (MediaQuery.of(context).size.height * 0.25);

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
        height: widgetHeight, // Set the height of the widget
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), // Apply border radius
          border: Border.all(color: Colors.grey), // Add border
          // color: Color(0xFFCC0000),
          image: DecorationImage(
            image: AssetImage(widget.event.eventPhoto),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5), // Background blend mode color
              BlendMode.dstATop, // Choose your blend mode
            ),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFCC0000),
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height:
                  widgetHeight * 0.7, // Set the height of the image container
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                child: Image.asset(
                  widget.event.eventPhoto,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: sizedBoxHeight * 0.5),
            Padding(
              padding: EdgeInsets.fromLTRB(edgeInsets, 0, edgeInsets, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.event.eventTitle,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  RichText(
                    // '${widget.event.points} Points',
                    text: TextSpan(
                      // text: '${widget.event.points}',
                      text: '30',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' pts',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
