// src/firebase/firebaseService.ts
import { db } from "./firebaseConfig";
import { collection, getDocs, getDoc, doc, updateDoc, deleteDoc, query, where, startAt, endAt } from "firebase/firestore";
import { Event } from "../interfaces/Event"

const eventTableName = "new_events";
// Function to get data from a collection
export const fetchAllEvents = async (): Promise<Event[]> => {
  const querySnapshot = await getDocs(collection(db, eventTableName));
  return querySnapshot.docs.map((doc) => ({
    id: doc.id,
    ...(doc.data() as Event), // Explicitly cast to Event
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
      return null; // or throw an error if you want to handle this in the calling function
    }

    // Get the event data from the document snapshot
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

// Function to update a document
export const updateDocument = async (collectionName: string, docId: string, data: any) => {
  const docRef = doc(db, collectionName, docId);
  await updateDoc(docRef, data);
};

// Function to delete a document
export const deleteDocument = async (collectionName: string, docId: string) => {
  const docRef = doc(db, collectionName, docId);
  await deleteDoc(docRef);
};
