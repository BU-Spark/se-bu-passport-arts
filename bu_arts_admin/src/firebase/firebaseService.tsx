// src/firebase/firebaseService.ts
import { collection, getDocs, getDoc, doc, updateDoc, Timestamp } from "firebase/firestore";
import { db } from "./firebaseConfig";
import { Event } from "../interfaces/Event"
import { User, AttendanceUser } from "../interfaces/User";
import { Attendance } from "../interfaces/Attendance";
import { getLastXMonths, generateMonthRange } from "../utils/utils";

const eventTableName = "new_events";
const userTableName = "users";
const attendanceTableName = "attendances";
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

export const fetchEventAttendance = async (eventId: string): Promise<Attendance[]> => {
  const attendanceCollection = collection(db, attendanceTableName);
  const snapshot = await getDocs(attendanceCollection);

  const attendances: Attendance[] = snapshot.docs
    .map((doc) => doc.data() as Attendance) // Cast to Attendance
    .filter((attendance) => attendance.eventID === eventId); // Filter by eventId

  console.log("fetchEventAttendance:", attendances);
  return attendances;
};


export const fetchPastEventSessions = async (eventId: string): Promise<string[]> => {
  try {
    // Reference to the specific event document
    const eventDocRef = doc(collection(db, "eventTableName"), eventId); // Replace "eventTableName" with your actual collection name

    // Fetch the event document
    const eventDocSnap = await getDoc(eventDocRef);

    if (eventDocSnap.exists()) {
      const eventData = eventDocSnap.data() as Event;
      const currentTime = Timestamp.now();

      // Filter past sessions
      const pastSessions = Object.values(eventData.eventSessions).filter(
        (session) => session.endTime.toMillis() < currentTime.toMillis()
      );

      // Extract and return session IDs
      return pastSessions.map((session) => session.sessionId);
    } else {
      console.error(`Event with ID ${eventId} not found.`);
      return [];
    }
  } catch (error) {
    console.error("Error fetching past event sessions:", error);
    return [];
  }
};

export const fetchRegisteredUsers = async (eventId: string): Promise<AttendanceUser[]> => {
  try {
    // Fetch past event sessions for the given eventId
    const pastEventSessions = await fetchPastEventSessions(eventId);

    // Reference to the users collection
    const usersCollectionRef = collection(db, "users"); // Replace "users" with your actual users collection name

    // Fetch all user documents
    const userDocsSnapshot = await getDocs(usersCollectionRef);

    const users: AttendanceUser[] = [];

    userDocsSnapshot.forEach((doc) => {
      const userData = doc.data() as AttendanceUser;

      // Check if the user's saved events contain the eventId and a sessionId in pastEventSessions
      const savedEvents = userData.userSavedEvents;

      if (savedEvents.has(eventId) && pastEventSessions.includes(savedEvents.get(eventId)!)) {
        users.push(userData);
      }
    });

    return users;
  } catch (error) {
    console.error("Error fetching registered users:", error);
    return [];
  }
};


export const fetchEventAttendanceWithProfiles = async (eventId: string): Promise<{ attendance: Attendance; userProfile: User | null }[]> => {
  const attendanceCollection = collection(db, attendanceTableName);
  const userCollection = collection(db, userTableName); // Correctly get a reference to the users collection.

  // Fetch attendance records for the event
  const snapshot = await getDocs(attendanceCollection);

  const eventAttendances: Attendance[] = snapshot.docs
    .map((doc) => doc.data() as Attendance) // Cast to Attendance
    .filter((attendance) => attendance.eventID === eventId); // Filter by eventId

  const results: { attendance: Attendance; userProfile: User | null }[] = [];

  const registeredUsers = await fetchRegisteredUsers(eventId);

  for (const attendance of eventAttendances) {
    for (const user of registeredUsers) {
      if (attendance.userID === user.userUID) {
        user.isAttended = true;
      }
    }
  }
  console.log("registeredUsers:", registeredUsers);

  const isAttended: Map<string, boolean> = new Map();
  for (const user of registeredUsers) {
    isAttended.set(user.userUID, false);
  }
  for (const attendance of eventAttendances) {
    isAttended.set(attendance.userID, true);
  }

  // Fetch user profile for each attendance record
  for (const attendance of eventAttendances) {
    const userDocRef = doc(userCollection, attendance.userID); // Pass userCollection and document ID correctly
    const userDoc = await getDoc(userDocRef);

    const userProfile = userDoc.exists() ? (userDoc.data() as User) : null;

    results.push({ attendance, userProfile });
  }

  let attendedCount = 0;
  let notAttendedCount = 0;

  isAttended.forEach((value) => {
    if (value) {
      attendedCount++;
    } else {
      notAttendedCount++;
    }
  });


  console.log("fetchEventAttendanceWithProfiles:", results);
  return results;
};

export const fetchEventName = async (eventId: string): Promise<string> => {
  try {
    const eventRef = doc(db, eventTableName, eventId);
    const docSnapshot = await getDoc(eventRef);

    if (!docSnapshot.exists()) {
      console.error("No matching event found");
      return "";
    }

    const eventData = docSnapshot.data() as Event;
    return eventData.eventTitle;
  } catch (error) {
    console.error("Error fetching event:", error);
    throw new Error("Failed to fetch event");
  }
}

export const fetchUserAttendedEvents = async (userId: string): Promise<Event[]> => {
  const attendanceCollection = collection(db, attendanceTableName);
  const eventCollection = collection(db, eventTableName);

  const snapshot = await getDocs(attendanceCollection);

  const attendedEvents: Event[] = [];

  for (const document of snapshot.docs) {
    const attendance = document.data() as Attendance;

    if (attendance.userID === userId) {
      const eventDocRef = doc(eventCollection, attendance.eventID);

      // Await the event document fetch
      const eventDoc = await getDoc(eventDocRef);

      if (eventDoc.exists()) {
        const eventData = eventDoc.data() as Event;
        attendedEvents.push(eventData);
      }
    }
  }

  return attendedEvents;
};
