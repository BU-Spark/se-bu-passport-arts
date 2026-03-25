// src/types/Event.ts
import { Session } from "./Session";

export interface BuEventsApiEvent {
  starts: number;
  ends: number;
  summary: string;
  location: string;
  id: number;
  oid: number | null;
  url: string;
  allday: string | null;
  topics: string;
}

export interface Event {
  eventID: string;
  eventTitle: string;
  eventCategories: string[];
  eventDescription: string;
  eventLocation: string;
  eventURL: string;
  eventPhoto: string;
  eventPoints: number;
  eventSessions: { [key: string]: Session };
}