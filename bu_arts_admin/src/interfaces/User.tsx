// src/types/Session.ts
import { Timestamp } from "firebase/firestore";
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
}