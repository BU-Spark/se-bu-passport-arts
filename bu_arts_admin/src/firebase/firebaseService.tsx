// src/firebase/firebaseService.ts
import { collection, getDocs, getDoc, doc } from "firebase/firestore";
import { db } from "./firebaseConfig";
import { Event } from "../interfaces/Event";
import { User } from "../interfaces/User";
import { Attendance } from "../interfaces/Attendance";
import { getLastXMonths, generateMonthRange } from "../utils/utils";
import { fetchAllBuEvents, fetchFutureBuEvents } from "../services/buEventsService";

const userTableName = "users";
const attendanceTableName = "attendances";

export interface UpcomingTopEvent {
  eventID: string;
  eventTitle: string;
  signupCount: number;
  categories: string[];
}

export interface UpcomingCategorySplit {
  category: string;
  count: number;
}

export interface UpcomingEventInsights {
  topEvents: UpcomingTopEvent[];
  categorySplit: UpcomingCategorySplit[];
}

export const fetchAllUsers = async (): Promise<User[]> => {
  const querySnapshot = await getDocs(collection(db, userTableName));
  return querySnapshot.docs.map((document) => ({
    id: document.id,
    ...(document.data() as User),
  }));
};

export const searchUsers = async (searchText: string): Promise<User[]> => {
  try {
    if (searchText === "") {
      return await fetchAllUsers();
    }

    const lowerSearchText = searchText.toLowerCase();
    const usersSnapshot = await getDocs(collection(db, userTableName));
    const users: User[] = [];

    usersSnapshot.forEach((document) => {
      const userData = document.data() as User;
      const firstNameMatch = userData.firstName.toLowerCase().startsWith(lowerSearchText);
      const lastNameMatch = userData.lastName.toLowerCase().startsWith(lowerSearchText);
      const isBUIDSearch = lowerSearchText.startsWith("u");
      const buidMatch = isBUIDSearch && userData.userBUID.toLowerCase().startsWith(lowerSearchText);

      if (firstNameMatch || lastNameMatch || buidMatch) {
        users.push(userData);
      }
    });

    return users;
  } catch (error) {
    console.error("Error searching users:", error);
    return [];
  }
};

export const fetchSingleUser = async (userId: string): Promise<User | null> => {
  try {
    const userRef = doc(db, userTableName, userId);
    const docSnapshot = await getDoc(userRef);

    if (!docSnapshot.exists()) {
      console.error("No matching user found");
      return null;
    }

    return docSnapshot.data() as User;
  } catch (error) {
    console.error("Error fetching user:", error);
    throw new Error("Failed to fetch user");
  }
};

export const fetchUserRegistrationStats = async (numMonths: number) => {
  const userCollection = collection(db, userTableName);
  const snapshot = await getDocs(userCollection);
  const userData = snapshot.docs.map((document) => document.data());
  const registrationsByMonth: { [month: string]: number } = {};

  userData.forEach((user) => {
    const userCreated = user.userCreated;

    if (userCreated) {
      const date = new Date(userCreated.seconds * 1000);
      const month = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
      registrationsByMonth[month] = (registrationsByMonth[month] || 0) + 1;
    }
  });

  let months: string[];

  if (numMonths === 0) {
    const allMonths = Object.keys(registrationsByMonth).sort();
    const startMonth = allMonths[0];
    const endMonth = allMonths[allMonths.length - 1];
    months = generateMonthRange(startMonth, endMonth);
  } else {
    months = getLastXMonths(numMonths);
  }

  const registrations = months.map((month) => registrationsByMonth[month] || 0);
  return { months, registrations };
};

export const fetchUpcomingEventInsights = async (): Promise<UpcomingEventInsights> => {
  const [attendanceSnapshot, upcomingEvents] = await Promise.all([
    getDocs(collection(db, attendanceTableName)),
    fetchFutureBuEvents(),
  ]);
  const upcomingEventIds = new Set(upcomingEvents.map((event) => event.eventID));
  const signupCountsByEvent = new Map<string, number>();

  attendanceSnapshot.docs.forEach((document) => {
    const attendance = document.data() as Attendance;

    if (!upcomingEventIds.has(attendance.eventID)) {
      return;
    }

    signupCountsByEvent.set(attendance.eventID, (signupCountsByEvent.get(attendance.eventID) || 0) + 1);
  });

  const topEvents = upcomingEvents
    .map((event) => ({
      eventID: event.eventID,
      eventTitle: event.eventTitle,
      signupCount: signupCountsByEvent.get(event.eventID) || 0,
      categories: event.eventCategories,
    }))
    .sort(
      (left, right) =>
        left.signupCount - right.signupCount || left.eventTitle.localeCompare(right.eventTitle),
    )

  const categoryCounts = new Map<string, number>();

  upcomingEvents.forEach((event) => {
    event.eventCategories.forEach((category) => {
      categoryCounts.set(category, (categoryCounts.get(category) || 0) + 1);
    });
  });

  const categorySplit = Array.from(categoryCounts.entries())
    .map(([category, count]) => ({ category, count }))
    .sort((left, right) => right.count - left.count || left.category.localeCompare(right.category));

  return { topEvents, categorySplit };
};

export const fetchEventAttendance = async (eventId: string): Promise<Attendance[]> => {
  const attendanceCollection = collection(db, attendanceTableName);
  const snapshot = await getDocs(attendanceCollection);

  return snapshot.docs
    .map((document) => document.data() as Attendance)
    .filter((attendance) => attendance.eventID === eventId);
};

export const fetchEventAttendanceWithProfiles = async (
  eventId: string,
): Promise<{ attendance: Attendance; userProfile: User | null }[]> => {
  const userCollection = collection(db, userTableName);
  const attendances = await fetchEventAttendance(eventId);
  const results: { attendance: Attendance; userProfile: User | null }[] = [];

  for (const attendance of attendances) {
    const userDocRef = doc(userCollection, attendance.userID);
    const userDoc = await getDoc(userDocRef);
    const userProfile = userDoc.exists() ? (userDoc.data() as User) : null;
    results.push({ attendance, userProfile });
  }

  return results;
};

export const fetchUserAttendedEvents = async (userId: string): Promise<Event[]> => {
  const attendanceCollection = collection(db, attendanceTableName);
  const snapshot = await getDocs(attendanceCollection);
  const attendedEventIds = new Set(
    snapshot.docs
      .map((document) => document.data() as Attendance)
      .filter((attendance) => attendance.userID === userId)
      .map((attendance) => attendance.eventID),
  );

  if (attendedEventIds.size === 0) {
    return [];
  }

  const allEvents = await fetchAllBuEvents();
  return allEvents.filter((event) => attendedEventIds.has(event.eventID));
};
