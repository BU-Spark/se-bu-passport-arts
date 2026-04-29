import { buEventsApiUrl } from '../config';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../firebase/firebaseConfig';
import { BuEventsApiEvent, Event } from '../interfaces/Event';
import { Session } from '../interfaces/Session';

interface BuEventsApiResponse {
  success: boolean;
  events: BuEventsApiEvent[];
}

interface EventFilters {
  searchText?: string;
  selectedDate?: string;
  selectedCategory?: string;
}

const DEFAULT_EVENT_PHOTO = '/logo.png';
const DEFAULT_EVENT_POINTS = 0;
const EVENT_COLLECTION = 'new_events';

const TOPIC_LABELS: Record<string, string> = {
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

let cachedEvents: Event[] | null = null;
let cachedEventsPromise: Promise<Event[]> | null = null;

const decodeHtml = (value: string): string => {
  if (typeof document === 'undefined') {
    return value;
  }

  const textarea = document.createElement('textarea');
  textarea.innerHTML = value;
  return textarea.value;
};

const buildSessionId = (rawEvent: BuEventsApiEvent): string =>
  rawEvent.oid !== null ? `${rawEvent.id}-${rawEvent.oid}` : `${rawEvent.id}-0`;

const buildSession = (rawEvent: BuEventsApiEvent): Session => ({
  sessionId: buildSessionId(rawEvent),
  savedUsers: [],
  startTime: new Date(rawEvent.starts * 1000),
  endTime: new Date(rawEvent.ends * 1000),
  occurrenceId: rawEvent.oid !== null ? String(rawEvent.oid) : null,
});

const getEventCategories = (topics: string): string[] => {
  const categories = topics
    .split(',')
    .map((topicId) => TOPIC_LABELS[topicId.trim()])
    .filter(Boolean);

  return categories.length > 0 ? [...new Set(categories)] : ['BU Arts'];
};

const getFallbackDescription = (title: string, location: string): string => {
  const locationText = location ? ` at ${location}` : '';
  return `${title}${locationText}. More details are available on the BU Arts calendar.`;
};

const stringOrFallback = (value: unknown, fallback: string): string =>
  typeof value === 'string' && value.trim() ? value : fallback;

const intOrFallback = (value: unknown, fallback: number): number => {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return Math.round(value);
  }

  if (typeof value === 'string' && value.trim()) {
    const parsedValue = Number(value);
    if (Number.isFinite(parsedValue)) {
      return Math.round(parsedValue);
    }
  }

  return fallback;
};

const fetchEventMetadataById = async (): Promise<Record<string, Record<string, unknown>>> => {
  const snapshot = await getDocs(collection(db, EVENT_COLLECTION));

  return snapshot.docs.reduce<Record<string, Record<string, unknown>>>((metadata, document) => {
    metadata[document.id] = document.data() as Record<string, unknown>;
    return metadata;
  }, {});
};

const toGroupedEvents = (
  rawEvents: BuEventsApiEvent[],
  metadataById: Record<string, Record<string, unknown>>,
): Event[] => {
  const groupedEvents = new Map<string, Event>();

  rawEvents.forEach((rawEvent) => {
    const eventID = String(rawEvent.id);
    const session = buildSession(rawEvent);
    const title = decodeHtml(rawEvent.summary);
    const location = decodeHtml(rawEvent.location || 'Boston University');
    const eventURL = rawEvent.url || '';

    if (!groupedEvents.has(eventID)) {
      const metadata = metadataById[eventID];

      groupedEvents.set(eventID, {
        eventID,
        eventTitle: stringOrFallback(metadata?.eventTitle, title),
        eventCategories: getEventCategories(rawEvent.topics),
        eventDescription: stringOrFallback(
          metadata?.eventDescription,
          getFallbackDescription(title, location),
        ),
        eventLocation: stringOrFallback(metadata?.eventLocation, location),
        eventURL: stringOrFallback(metadata?.eventURL, eventURL),
        eventPhoto: stringOrFallback(metadata?.eventPhoto, DEFAULT_EVENT_PHOTO),
        eventPoints: intOrFallback(metadata?.eventPoints, DEFAULT_EVENT_POINTS),
        eventSessions: { [session.sessionId]: session },
      });
      return;
    }

    const existingEvent = groupedEvents.get(eventID)!;
    existingEvent.eventSessions[session.sessionId] = session;

    if (!existingEvent.eventURL && eventURL) {
      existingEvent.eventURL = eventURL;
    }
  });

  return Array.from(groupedEvents.values()).sort((left, right) => {
    const leftStart = Math.min(...Object.values(left.eventSessions).map((session) => session.startTime.getTime()));
    const rightStart = Math.min(...Object.values(right.eventSessions).map((session) => session.startTime.getTime()));
    return leftStart - rightStart;
  });
};

const matchesSearch = (event: Event, searchText: string): boolean => {
  if (!searchText.trim()) {
    return true;
  }

  const normalizedSearch = searchText.trim().toLowerCase();
  const searchableText = [
    event.eventTitle,
    event.eventDescription,
    event.eventLocation,
    event.eventCategories.join(' '),
  ]
    .join(' ')
    .toLowerCase();

  return searchableText.includes(normalizedSearch);
};

const matchesDate = (event: Event, selectedDate?: string): boolean => {
  if (!selectedDate) {
    return true;
  }

  return Object.values(event.eventSessions).some((session) => {
    const sessionDate = session.startTime.toISOString().slice(0, 10);
    return sessionDate === selectedDate;
  });
};

const matchesCategory = (event: Event, selectedCategory?: string): boolean => {
  if (!selectedCategory) {
    return true;
  }

  return event.eventCategories.includes(selectedCategory);
};

const filterEventSessions = (
  event: Event,
  predicate: (session: Session) => boolean,
): Event | null => {
  const filteredSessions = Object.fromEntries(
    Object.entries(event.eventSessions).filter(([, session]) => predicate(session)),
  );

  if (Object.keys(filteredSessions).length === 0) {
    return null;
  }

  return {
    ...event,
    eventSessions: filteredSessions,
  };
};

export const fetchAllBuEvents = async (): Promise<Event[]> => {
  if (cachedEvents) {
    return cachedEvents;
  }

  if (cachedEventsPromise) {
    return cachedEventsPromise;
  }

  cachedEventsPromise = (async () => {
    const [response, metadataById] = await Promise.all([
      fetch(buEventsApiUrl),
      fetchEventMetadataById(),
    ]);

    if (!response.ok) {
      throw new Error(`Failed to fetch BU events: ${response.status}`);
    }

    const data = (await response.json()) as BuEventsApiResponse;

    if (!data.success || !Array.isArray(data.events)) {
      throw new Error('BU events API returned an invalid payload.');
    }

    cachedEvents = toGroupedEvents(data.events, metadataById);
    return cachedEvents;
  })();

  try {
    return await cachedEventsPromise;
  } finally {
    cachedEventsPromise = null;
  }
};

export const clearBuEventsCache = (): void => {
  cachedEvents = null;
  cachedEventsPromise = null;
};

export const fetchSingleBuEvent = async (eventId: string): Promise<Event | null> => {
  const events = await fetchAllBuEvents();
  return events.find((event) => event.eventID === eventId) ?? null;
};

export const fetchFilteredBuEvents = async ({
  searchText = '',
  selectedDate,
  selectedCategory,
}: EventFilters = {}): Promise<Event[]> => {
  const events = await fetchAllBuEvents();
  return events.filter(
    (event) =>
      matchesSearch(event, searchText) &&
      matchesDate(event, selectedDate) &&
      matchesCategory(event, selectedCategory),
  );
};

export const getAvailableEventCategories = (events: Event[]): string[] =>
  [...new Set(events.flatMap((event) => event.eventCategories))].sort((left, right) =>
    left.localeCompare(right),
  );

export const fetchFutureBuEvents = async (filters: EventFilters = {}): Promise<Event[]> => {
  const now = Date.now();
  const events = await fetchFilteredBuEvents(filters);

  return events
    .map((event) => filterEventSessions(event, (session) => session.endTime.getTime() > now))
    .filter((event): event is Event => event !== null);
};

export const fetchPastBuEvents = async (filters: EventFilters = {}): Promise<Event[]> => {
  const now = Date.now();
  const events = await fetchFilteredBuEvents(filters);

  return events
    .map((event) => filterEventSessions(event, (session) => session.endTime.getTime() <= now))
    .filter((event): event is Event => event !== null)
    .sort((left, right) => {
      const leftLatest = Math.max(...Object.values(left.eventSessions).map((session) => session.endTime.getTime()));
      const rightLatest = Math.max(...Object.values(right.eventSessions).map((session) => session.endTime.getTime()));
      return rightLatest - leftLatest;
    });
};

export const countCurrentMonthBuEvents = async (): Promise<number> => {
  const events = await fetchAllBuEvents();
  const now = new Date();
  const currentMonth = now.getMonth();
  const currentYear = now.getFullYear();

  let count = 0;

  events.forEach((event) => {
    Object.values(event.eventSessions).forEach((session) => {
      if (
        session.startTime.getMonth() === currentMonth &&
        session.startTime.getFullYear() === currentYear
      ) {
        count += 1;
      }
    });
  });

  return count;
};

export const fetchBuEventName = async (eventId: string): Promise<string> => {
  const event = await fetchSingleBuEvent(eventId);
  return event?.eventTitle ?? '';
};
