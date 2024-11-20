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
    userSavedEvents: string;
    userCreated: Timestamp;
}