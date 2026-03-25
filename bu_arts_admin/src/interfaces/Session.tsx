// src/types/Session.ts
export interface Session {
    sessionId: string;
    savedUsers: string[];
    startTime: Date;
    endTime: Date;
    occurrenceId: string | null;
}