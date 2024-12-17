import { Timestamp } from "firebase/firestore";

// src/types/Session.ts
export interface User {
    firstName: string;
    lastName: string;
    userBUID: string;
    userProfileURL: string;
    userEmail: string;
    userPoints: number;
    userSchool: string;
    userUID: string;
    userYear: string;
    userSavedEvents: Map<string, string>;
    userCreated: Timestamp;
}

export interface AttendanceUser {
    firstName: string;
    lastName: string;
    userBUID: string;
    userProfileURL: string;
    userEmail: string;
    userPoints: number;
    userSchool: string;
    userUID: string;
    userYear: string;
    userSavedEvents: Map<string, string>;
    userCreated: Timestamp;
    isAttended: boolean;
}