// src/firebase/firebaseService.ts
import { collection, getDocs, getDoc, doc, setDoc, query, where, writeBatch, increment } from "firebase/firestore";
import { db } from "./firebaseConfig";
import { Event } from "../interfaces/Event";
import { User } from "../interfaces/User";
import { Attendance } from "../interfaces/Attendance";
import { getLastXMonths, generateMonthRange } from "../utils/utils";
import { fetchAllBuEvents, fetchFutureBuEvents } from "../services/buEventsService";

const userTableName = "users";
const attendanceTableName = "attendances";
const eventTableName = "new_events";

export interface UpcomingTopEvent {
  eventID: string;
  eventTitle: string;
  savedCount: number;
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

export const updateEventMetadata = async (
  eventId: string,
  metadata: Partial<Pick<Event, 'eventPoints' | 'eventPhoto' | 'eventDescription' | 'eventLocation' | 'eventURL' | 'eventTitle'>>,
) => {
  await setDoc(doc(db, eventTableName, eventId), metadata, { merge: true });
};

export const updateEventPoints = async (
  eventId: string,
  previousPoints: number,
  nextPoints: number,
) => {
  const roundedNextPoints = Math.round(nextPoints);
  const pointsDelta = roundedNextPoints - previousPoints;

  await setDoc(
    doc(db, eventTableName, eventId),
    { eventPoints: roundedNextPoints },
    { merge: true },
  );

  if (pointsDelta === 0) {
    return;
  }

  const attendanceSnapshot = await getDocs(
    query(collection(db, attendanceTableName), where('eventID', '==', eventId)),
  );

  const uniqueUserIds = new Set(
    attendanceSnapshot.docs
      .map((document) => (document.data() as Attendance).userID)
      .filter(Boolean),
  );

  if (uniqueUserIds.size === 0) {
    return;
  }

  const batch = writeBatch(db);

  uniqueUserIds.forEach((userId) => {
    batch.update(doc(db, userTableName, userId), {
      userPoints: increment(pointsDelta),
    });
  });

  await batch.commit();
};

export const fetchUserRegistrationStats = async (numMonths: number) => {
  const userCollection = collection(db, userTableName);
  const snapshot = await getDocs(userCollection);
  const userData = snapshot.docs.map((document) => document.data());
  const registrationsByMonth: { [month: string]: number } = {};
  const currentMonth = `${new Date().getFullYear()}-${String(new Date().getMonth() + 1).padStart(2, '0')}`;

  const getUserCreatedDate = (userCreated: unknown): Date | null => {
    if (!userCreated) {
      return null;
    }

    if (userCreated instanceof Date) {
      return userCreated;
    }

    if (typeof userCreated === 'object' && userCreated !== null) {
      if ('toDate' in userCreated && typeof userCreated.toDate === 'function') {
        return userCreated.toDate();
      }

      if ('seconds' in userCreated && typeof userCreated.seconds === 'number') {
        return new Date(userCreated.seconds * 1000);
      }
    }

    return null;
  };

  userData.forEach((user) => {
    const date = getUserCreatedDate(user.userCreated ?? user.userCreatedAt);

    if (date) {
      const month = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
      registrationsByMonth[month] = (registrationsByMonth[month] || 0) + 1;
    }
  });

  let months: string[];

  if (numMonths === 0) {
    const allMonths = Object.keys(registrationsByMonth).sort();
    const startMonth = allMonths[0] || currentMonth;
    const endMonth = currentMonth;
    months = generateMonthRange(startMonth, endMonth);
  } else {
    months = getLastXMonths(numMonths);
  }

  const registrations = months.map((month) => registrationsByMonth[month] || 0);
  return { months, registrations };
};

export const fetchUpcomingEventInsights = async (): Promise<UpcomingEventInsights> => {
  const [users, upcomingEvents] = await Promise.all([
    fetchAllUsers(),
    fetchFutureBuEvents(),
  ]);
  const upcomingEventIds = new Set(upcomingEvents.map((event) => event.eventID));
  const savedCountsByEvent = new Map<string, number>();

  users.forEach((user) => {
    const savedEvents =
      user.userSavedEvents instanceof Map
        ? Array.from(user.userSavedEvents.keys())
        : Object.keys((user.userSavedEvents as Record<string, unknown>) || {});

    savedEvents.forEach((eventID) => {
      if (!upcomingEventIds.has(eventID)) {
        return;
      }

      savedCountsByEvent.set(eventID, (savedCountsByEvent.get(eventID) || 0) + 1);
    });
  });

  const topEvents = upcomingEvents
    .map((event) => ({
      eventID: event.eventID,
      eventTitle: event.eventTitle,
      savedCount: savedCountsByEvent.get(event.eventID) || 0,
      categories: event.eventCategories,
    }))
    .sort(
      (left, right) =>
        right.savedCount - left.savedCount || left.eventTitle.localeCompare(right.eventTitle),
    );

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
