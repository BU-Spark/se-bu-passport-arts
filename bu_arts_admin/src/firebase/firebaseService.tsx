// src/firebase/firebaseService.ts
import { collection, getDocs, getDoc, doc, updateDoc, Timestamp } from "firebase/firestore";
import { db } from "./firebaseConfig";
import { Event } from "../interfaces/Event"
import { User } from "../interfaces/User";
import { getLastXMonths, generateMonthRange } from "../utils/utils";

const eventTableName = "new_events";
const userTableName = "users";
// Function to get data from a collection
export const fetchAllEvents = async (): Promise<Event[]> => {
  const querySnapshot = await getDocs(collection(db, eventTableName));
  return querySnapshot.docs.map((doc) => ({
    id: doc.id,
    ...(doc.data() as Event),
  }));
};

// Function to add data to a collection
export const searchEvents = async (searchText: string): Promise<Event[]> => {
  if (searchText === "") {
    const querySnapshot = await getDocs(collection(db, eventTableName));
    return querySnapshot.docs.map((doc) => ({
      id: doc.id,
      ...(doc.data() as Event), // Explicitly cast to Event
    }));
  }

  const lowerSearchText = searchText.toLowerCase();
  const eventsSnapshot = await getDocs(collection(db, eventTableName));

  const events: Event[] = [];
  eventsSnapshot.forEach((doc) => {
    const eventData = doc.data() as Event;
    // Perform client-side filtering
    if (
      eventData.eventTitle.toLowerCase().includes(lowerSearchText) ||
      eventData.eventDescription.toLowerCase().includes(lowerSearchText)
    ) {
      events.push(eventData);
    }
  });
  return events;
};

export const fetchSingleEvent = async (eventId: string): Promise<Event | null> => {
  try {
    const eventRef = doc(db, eventTableName, eventId);
    const docSnapshot = await getDoc(eventRef);

    if (!docSnapshot.exists()) {
      console.error("No matching event found");
      return null;
    }

    const eventData = docSnapshot.data() as Event;
    return eventData;
  } catch (error) {
    console.error("Error fetching event:", error);
    throw new Error("Failed to fetch event");
  }
};

export const updateSingleEvent = async (event: Event): Promise<boolean> => {
  try {
    // Create a reference to the event document based on the eventId
    const eventRef = doc(db, eventTableName, event.eventID);

    // Update the document with the new event data
    await updateDoc(eventRef, {
      eventTitle: event.eventTitle,
      eventCategories: event.eventCategories,
      eventDescription: event.eventDescription,
      eventLocation: event.eventLocation,
      eventURL: event.eventURL,
      eventPhoto: event.eventPhoto,
      eventPoints: event.eventPoints,
      eventSessions: event.eventSessions,
    });

    console.log("Event updated successfully");
    return true;
  } catch (error) {
    console.error("Error updating event:", error);
    return false;
  }
};

export const fetchAllUsers = async (): Promise<User[]> => {
  const querySnapshot = await getDocs(collection(db, userTableName));
  let users = querySnapshot.docs.map((doc) => ({
    id: doc.id,
    ...(doc.data() as User),
  }));
  console.log(users)
  return users
}

export const searchUsers = async (searchText: string): Promise<User[]> => {
  try {
    if (searchText === "") {
      return await fetchAllUsers()
    }
    const lowerSearchText = searchText.toLowerCase();
    const usersSnapshot = await getDocs(collection(db, userTableName));
    const users: User[] = [];
    usersSnapshot.forEach((doc) => {
      const userData = doc.data() as User;

      const firstNameMatch = userData.firstName.toLowerCase().startsWith(lowerSearchText);
      const lastNameMatch = userData.lastName.toLowerCase().startsWith(lowerSearchText);

      const isBUIDSearch = lowerSearchText.startsWith("u");
      const buidMatch = isBUIDSearch && userData.userBUID.toLowerCase().startsWith(lowerSearchText);

      if (firstNameMatch || lastNameMatch || buidMatch) {
        users.push(userData);
      }
    });
    return users
  } catch (error) {
    console.error("Error searching users:", error);
    return [];
  }
}

export const fetchSingleUser = async (userId: string): Promise<User | null> => {
  try {
    const eventRef = doc(db, userTableName, userId);
    const docSnapshot = await getDoc(eventRef);

    if (!docSnapshot.exists()) {
      console.error("No matching event found");
      return null;
    }

    const userData = docSnapshot.data() as User;
    return userData;
  } catch (error) {
    console.error("Error fetching user:", error);
    throw new Error("Failed to fetch user");
  }
}

export const fetchUserRegistrationStats = async (numMonths: number) => {
  const userCollection = collection(db, userTableName);

  const snapshot = await getDocs(userCollection);
  const userData = snapshot.docs.map((doc) => doc.data());

  // Process the data: Group registrations by month
  const registrationsByMonth: { [month: string]: number } = {};
  userData.forEach((user) => {
    const userCreated = user.userCreated; // Assuming userCreated is a timestamp
    if (userCreated) {
      const date = new Date(userCreated.seconds * 1000); // Convert Firestore timestamp to JS Date
      const month = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`; // Format as YYYY-MM
      registrationsByMonth[month] = (registrationsByMonth[month] || 0) + 1;
    }
  });

  // Generate the latest x months
  let months: string[];

  if (numMonths === 0) {
    // Fetch all months starting from the earliest one
    const allMonths = Object.keys(registrationsByMonth).sort(); // Sort months in ascending order
    const startMonth = allMonths[0]; // Earliest month
    const endMonth = allMonths[allMonths.length - 1]; // Latest month
    months = generateMonthRange(startMonth, endMonth); // Generate all months in the range
  } else {
    // Generate the latest numMonths
    months = getLastXMonths(numMonths);
  }

  // Map user counts to the generated months, set to 0 if no data
  const registrations = months.map((month) => registrationsByMonth[month] || 0);

  return { months, registrations };
};

export const countCurrentMonthEvents = async (): Promise<number> => {
  const eventCollection = collection(db, eventTableName);

  try {
    const snapshot = await getDocs(eventCollection);
    const events = snapshot.docs.map((doc) => doc.data() as Event);

    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth();
    let count = 0;

    events.forEach((event) => {
      Object.values(event.eventSessions).forEach((session) => {
        if (session?.startTime) { // Check if startTime exists
          const startTime = session.startTime.toDate(); // Convert Firestore Timestamp to JS Date
          if (startTime.getFullYear() === currentYear && startTime.getMonth() === currentMonth) {
            count++;
          }
        }
      });
    });

    return count;
  } catch (error) {
    console.error("Error fetching events:", error);
    return 0; // Return 0 in case of an error
  }
};

export const fetchPastEvents = async (searchText: string): Promise<Event[]> => {
  const eventsData = await searchEvents(searchText); // Fetch all events by default
  const now = Timestamp.now();

  const pastEvents = eventsData
    .filter(event =>
      Object.values(event.eventSessions).some(session => session.endTime < now)
    )
    .map(event => ({
      ...event,
      eventSessions: Object.fromEntries(
        Object.entries(event.eventSessions).filter(
          ([, session]) => session.endTime < now
        )
      )
    }))
    .filter(event => Object.keys(event.eventSessions).length > 0)
  return pastEvents;
}

export const fetchFutureEvents = async (searchText: string): Promise<Event[]> => {
  const eventsData = await searchEvents(searchText);

  const now = Timestamp.now();

  const futureEvents = eventsData
    .filter(event =>
      Object.values(event.eventSessions).some(session => session.endTime > now)
    )
    .map(event => ({
      ...event,
      eventSessions: Object.fromEntries(
        Object.entries(event.eventSessions).filter(
          ([, session]) => session.endTime > now
        )
      )
    }))
    .filter(event => Object.keys(event.eventSessions).length > 0);

  console.log(futureEvents);
  return futureEvents;
}
