// src/types/Event.ts
import {Session} from "./Session"
export interface Event {
    eventID: string;
    eventTitle: string;
    eventCategories: string[];
    eventDescription: string;
    eventLocation: string;
    eventURL: string;
    eventPhoto: string;
    eventPoints: number;
    eventSessions: { [key: string]: Session }; // Dictionary with session ID keys and Session values
  }