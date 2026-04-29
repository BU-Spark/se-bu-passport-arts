import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/components/time_span.dart';
import 'package:bu_passport/pages/event_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firebase_service.dart';

class EventWidget extends StatefulWidget {
  final Event event;
  final Function onUpdateEventPage;
  const EventWidget(
      {Key? key, required this.event, required this.onUpdateEventPage})
      : super(key: key);

  @override
  _EventWidgetState createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {
  static const Color _cardBorderColor = Color(0xFFE5E7EB);
  static const Color _categoryChipColor = Color(0xFFC62828);
  static const Color _mutedTextColor = Color(0xFF5F6368);

  bool _isSaved = false;
  bool _isCheckedIn = false;
  String userUID = FirebaseAuth.instance.currentUser?.uid ?? "";
  // Ensure there's a user logged in
  FirebaseService firebaseService =
      FirebaseService(db: FirebaseFirestore.instance);

  @override
  void initState() {
    checkIfUserSaved();
    checkIfUserCheckedIn();
    super.initState();
  }

  // Function to check if user has saved the event

  void checkIfUserSaved() async {
    // Ensure there's a user logged in
    if (userUID.isEmpty) {
      return;
    }
    try {
      bool isSaved = await firebaseService.hasUserSavedEvent(
          userUID, widget.event.eventID);
      if (!mounted) return;
      setState(() {
        _isSaved = isSaved;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaved = false;
      });
    }
  }

  // Function to check if user has checked in to the event
  void checkIfUserCheckedIn() async {
    // Ensure there's a user logged in
    if (userUID.isEmpty) {
      return;
    }
    try {
      bool isCheckedIn = await firebaseService.isUserCheckedInForEvent(
          userUID, widget.event.eventID);
      if (!mounted) return;
      setState(() {
        _isCheckedIn = isCheckedIn;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCheckedIn = false;
      });
    }
  }

  // Function to update the event page
  void updateEventPage() {
    checkIfUserSaved();
    checkIfUserCheckedIn();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.event.eventCategories.isNotEmpty
        ? widget.event.eventCategories
        : ['BU Arts'];

    return GestureDetector(
      onTap: () {
        // Navigate to the event page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventPage(
                event: widget.event,
                onUpdateEventPage: widget.onUpdateEventPage),
          ),
        );
      },
      child: Container(
        height: 224,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: _cardBorderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              right: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    top: BorderSide(color: Colors.black, width: 4),
                    right: BorderSide(color: Colors.black, width: 4),
                  ),
                ),
                child: SizedBox(width: 20, height: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 36),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories
                          .map(
                            (category) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _categoryChipColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.eventTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.event.eventLocation,
                              style: const TextStyle(
                                fontSize: 14,
                                color: _mutedTextColor,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            EventDateRangeDisplay(
                              sessions: widget.event.eventSessions,
                              textColor: _mutedTextColor,
                            ),
                            if (_isCheckedIn) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Checked in',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${widget.event.eventPoints} pts',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: GestureDetector(
                onTap: () async {
                  if (userUID.isEmpty) {
                    return;
                  }

                  try {
                    final isSaved = await firebaseService.hasUserSavedEvent(
                      userUID,
                      widget.event.eventID,
                    );

                    if (isSaved) {
                      await firebaseService.unsaveEvent(widget.event.eventID);
                    } else {
                      await firebaseService.saveEvent(widget.event.eventID);
                    }

                    if (!mounted) return;
                    setState(() {
                      _isSaved = !isSaved;
                    });
                  } catch (_) {
                    if (!mounted) return;
                    setState(() {
                      _isSaved = false;
                    });
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _cardBorderColor),
                  ),
                  child: Icon(
                    _isSaved ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: _isSaved ? Colors.red : _mutedTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
