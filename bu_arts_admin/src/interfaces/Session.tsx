// src/types/Session.ts
import { Timestamp } from "firebase/firestore";
export interface Session {
    sessionId: string;
    savedUsers: string[];
    startTime: Timestamp;
    endTime: Timestamp;
}