// src/firebase/firebaseService.ts
import { db } from "./firebaseConfig";
import { collection, getDocs, getDoc, doc, updateDoc} from "firebase/firestore";
import { Event } from "../interfaces/Event"
import { User } from "../interfaces/User";

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

