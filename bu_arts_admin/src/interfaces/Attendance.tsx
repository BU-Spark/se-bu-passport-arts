// src/types/Attendance.ts
import { Timestamp } from "firebase/firestore";
export interface Attendance {
    eventID: string;
    sessionID: string;
    userID: string;
    checkInTime: Timestamp;
    // isAttended: boolean;
}