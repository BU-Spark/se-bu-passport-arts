import 'dart:convert';

import 'package:bu_passport/classes/event.dart';
import 'package:bu_passport/classes/session.dart';
import 'package:bu_passport/classes/sticker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class BuEventsService {
  BuEventsService({required this.db});

  static const String _eventsCollection = 'new_events';
  static const String _defaultBuEventsApiUrl = String.fromEnvironment(
    'BU_EVENTS_API_URL',
    defaultValue: 'https://www.bu.edu/phpbin/calendar/rpc/events.php?cid=20',
  );

  static const String _defaultEventPhoto = '';
  static const int _defaultEventPoints = 0;

  static const Map<String, String> _topicLabels = {
    '5796': 'Student Life',
    '8636': 'Visual Arts',
    '8637': 'Theatre',
    '8639': 'Arts',
    '8643': 'Music',
    '8647': 'Exhibition',
    '8649': 'Performance',
    '8678': 'Concert',
    '9064': 'Opera',
    '9149': 'Workshop',
  };

  static List<Event>? _cachedEvents;
  static Future<List<Event>>? _cachedEventsFuture;

  final FirebaseFirestore db;

  Future<List<Event>> fetchEvents() async {
    if (_cachedEvents != null) {
      return _cachedEvents!;
    }

    if (_cachedEventsFuture != null) {
      return _cachedEventsFuture!;
    }

    _cachedEventsFuture = _fetchEvents();

    try {
      _cachedEvents = await _cachedEventsFuture!;
      return _cachedEvents!;
    } finally {
      _cachedEventsFuture = null;
    }
  }

  void clearCache() {
    _cachedEvents = null;
    _cachedEventsFuture = null;
  }

  Future<List<Event>> _fetchEvents() async {
    final response = await http.get(Uri.parse(_defaultBuEventsApiUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch BU events: ${response.statusCode}');
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic> || payload['events'] is! List) {
      throw Exception('BU events API returned an invalid payload.');
    }

    final metadataById = <String, Map<String, dynamic>>{};
    try {
      final metadataSnapshot = await db.collection(_eventsCollection).get();
      for (final doc in metadataSnapshot.docs) {
        metadataById[doc.id] = doc.data();
      }
    } catch (_) {
      // Event metadata is optional; continue with API-only data when Firestore is locked down.
    }

    final groupedEvents = <String, _GroupedEventAccumulator>{};

    for (final rawEvent in payload['events'] as List) {
      if (rawEvent is! Map<String, dynamic>) {
        continue;
      }

      final eventId = '${rawEvent['id'] ?? ''}'.trim();
      if (eventId.isEmpty) {
        continue;
      }

      final title = _decodeHtml('${rawEvent['summary'] ?? ''}'.trim());
      final location = _decodeHtml('${rawEvent['location'] ?? ''}'.trim());
      final eventUrl = '${rawEvent['url'] ?? ''}'.trim();
      final accumulator = groupedEvents.putIfAbsent(
        eventId,
        () => _GroupedEventAccumulator(
          eventID: eventId,
          eventTitle: title,
          eventLocation: location.isNotEmpty ? location : 'Boston University',
          eventDescription: _buildFallbackDescription(title, location),
          eventURL: eventUrl,
          eventCategories: _getEventCategories(rawEvent['topics']),
        ),
      );

      if (accumulator.eventURL.isEmpty && eventUrl.isNotEmpty) {
        accumulator.eventURL = eventUrl;
      }

      accumulator.sessions.add(
        Session(
          sessionID: _buildSessionId(rawEvent),
          sessionStartTime: DateTime.fromMillisecondsSinceEpoch(
            _parseUnixTimestamp(rawEvent['starts']) * 1000,
          ),
          sessionEndTime: DateTime.fromMillisecondsSinceEpoch(
            _parseUnixTimestamp(rawEvent['ends']) * 1000,
          ),
          savedUsers: const [],
        ),
      );
    }

    final events = groupedEvents.values.map((groupedEvent) {
      final metadata = metadataById[groupedEvent.eventID];
      final sortedSessions = [...groupedEvent.sessions]..sort(
          (left, right) =>
              left.sessionStartTime.compareTo(right.sessionStartTime),
        );

      return Event(
        eventID: groupedEvent.eventID,
        eventTitle:
            _stringOrFallback(metadata?['eventTitle'], groupedEvent.eventTitle),
        eventCategories: groupedEvent.eventCategories,
        eventPhoto:
            _stringOrFallback(metadata?['eventPhoto'], _defaultEventPhoto),
        eventLocation: _stringOrFallback(
          metadata?['eventLocation'],
          groupedEvent.eventLocation,
        ),
        eventDescription: _stringOrFallback(
          metadata?['eventDescription'],
          groupedEvent.eventDescription,
        ),
        eventURL:
            _stringOrFallback(metadata?['eventURL'], groupedEvent.eventURL),
        eventPoints:
            _intOrFallback(metadata?['eventPoints'], _defaultEventPoints),
        savedUsers: _stringList(metadata?['savedUsers']),
        eventSessions: sortedSessions,
        eventStickers: _stickerList(metadata?['eventStickers']),
      );
    }).toList()
      ..sort((left, right) {
        final leftStart = left.eventSessions.first.sessionStartTime;
        final rightStart = right.eventSessions.first.sessionStartTime;
        return leftStart.compareTo(rightStart);
      });

    return events;
  }

  static String _buildSessionId(Map<String, dynamic> rawEvent) {
    final eventId = '${rawEvent['id'] ?? ''}'.trim();
    final occurrenceId = rawEvent['oid'];
    if (occurrenceId == null) {
      return '$eventId-0';
    }

    return '$eventId-$occurrenceId';
  }

  static int _parseUnixTimestamp(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static String _buildFallbackDescription(String title, String location) {
    final cleanLocation = location.trim();
    final cleanTitle = title.trim().isEmpty ? 'BU Arts event' : title.trim();
    final locationSuffix = cleanLocation.isEmpty ? '' : ' at $cleanLocation';
    return '$cleanTitle$locationSuffix. More details are available on the BU Arts calendar.';
  }

  static List<String> _getEventCategories(dynamic topicsValue) {
    final rawTopics = topicsValue?.toString() ?? '';
    final categories = rawTopics
        .split(',')
        .map((topicId) => _topicLabels[topicId.trim()])
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();

    return categories.isEmpty ? ['BU Arts'] : categories;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.map((item) => '$item').toList();
  }

  static List<Sticker> _stickerList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((item) => '$item'.trim())
        .where((item) => item.isNotEmpty)
        .map((item) => Sticker(name: item))
        .toList();
  }

  static String _stringOrFallback(dynamic value, String fallback) {
    final normalized = value?.toString().trim() ?? '';
    return normalized.isEmpty ? fallback : normalized;
  }

  static int _intOrFallback(dynamic value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }

  static String _decodeHtml(String value) {
    const replacements = {
      '&amp;': '&',
      '&quot;': '"',
      '&#39;': "'",
      '&#x27;': "'",
      '&apos;': "'",
      '&lt;': '<',
      '&gt;': '>',
      '&nbsp;': ' ',
    };

    var decoded = value;
    replacements.forEach((encoded, plain) {
      decoded = decoded.replaceAll(encoded, plain);
    });
    return decoded;
  }
}

class _GroupedEventAccumulator {
  _GroupedEventAccumulator({
    required this.eventID,
    required this.eventTitle,
    required this.eventLocation,
    required this.eventDescription,
    required this.eventURL,
    required this.eventCategories,
  });

  final String eventID;
  final String eventTitle;
  final String eventLocation;
  final String eventDescription;
  String eventURL;
  final List<String> eventCategories;
  final List<Session> sessions = [];
}
