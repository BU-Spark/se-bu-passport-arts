import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import StudentDetailPage from '../src/pages/StudentProfilePage';
import { fetchSingleUser, fetchUserAttendedEvents } from '../src/firebase/firebaseService';
import { Timestamp } from 'firebase/firestore';
import { User } from '../src/interfaces/User';
import { Event } from '../src/interfaces/Event';

// Mock the fetchSingleUser and fetchUserAttendedEvents functions
vi.mock('../src/firebase/firebaseService', () => ({
    fetchSingleUser: vi.fn(),
    fetchUserAttendedEvents: vi.fn(),
}));

describe('StudentDetailPage', () => {
    const mockUser: User = {
        firstName: 'John',
        lastName: 'Doe',
        userBUID: 'BUID1',
        userProfileURL: 'https://example.com/profile1.jpg',
        userEmail: 'john@example.com',
        userPoints: 100,
        userSchool: 'School of Arts',
        userUID: 'UID1',
        userYear: 'Sophomore',
        userSavedEvents: new Map(),
        userCreated: new Timestamp(1672531200, 0),
    };

    const mockEvents: Event[] = [
        {
            eventID: '1',
            eventTitle: 'Jazz Night',
            eventLocation: 'Downtown Club',
            eventPhoto: 'https://via.placeholder.com/300x200',
            eventCategories: ['Music'],
            eventDescription: 'A night of jazz music.',
            eventURL: 'https://example.com/jazz-night',
            eventPoints: 10,
            eventSessions: {
                session1: {
                    sessionId: 'session1',
                    startTime: new Timestamp(1672531200, 0), // Mock Timestamp
                    savedUsers: [],
                    endTime: new Timestamp(1672538400, 0), // Mock Timestamp
                },
            },
        },
        {
            eventID: '2',
            eventTitle: 'Art Gallery Exhibition',
            eventLocation: 'City Art Center',
            eventPhoto: 'https://via.placeholder.com/300x200',
            eventCategories: ['Art'],
            eventDescription: 'An exhibition of modern art.',
            eventURL: 'https://example.com/art-gallery',
            eventPoints: 20,
            eventSessions: {
                session2: {
                    sessionId: 'session2',
                    startTime: new Timestamp(1672531200, 0), // Mock Timestamp
                    savedUsers: [],
                    endTime: new Timestamp(1672538400, 0), // Mock Timestamp
                },
            },
        },
    ];

    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('renders without crashing', async () => {
        (fetchSingleUser as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(mockUser);
        (fetchUserAttendedEvents as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(mockEvents);

        render(
            <MemoryRouter initialEntries={['/student/UID1']}>
                <Routes>
                    <Route path="/student/:userID" element={<StudentDetailPage />} />
                </Routes>
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText("Student Profile")).toBeInTheDocument();
        });
    });

    it('displays user details and attended events', async () => {
        (fetchSingleUser as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(mockUser);
        (fetchUserAttendedEvents as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(mockEvents);

        render(
            <MemoryRouter initialEntries={['/student/UID1']}>
                <Routes>
                    <Route path="/student/:userID" element={<StudentDetailPage />} />
                </Routes>
            </MemoryRouter>
        );

        await waitFor(() => {
            // Check if user details are displayed
            expect(screen.getByText("John Doe")).toBeInTheDocument();

            // Check if attended events are displayed
            expect(screen.getByText(/Jazz Night/i)).toBeInTheDocument();
            expect(screen.getByText(/Downtown Club/i)).toBeInTheDocument();
            expect(screen.getByText(/Art Gallery Exhibition/i)).toBeInTheDocument();
            expect(screen.getByText(/City Art Center/i)).toBeInTheDocument();
        });
    });

    it('displays an error message if fetching user details fails', async () => {
        (fetchSingleUser as unknown as ReturnType<typeof vi.fn>).mockRejectedValue(new Error('Failed to fetch user'));

        render(
            <MemoryRouter initialEntries={['/student/UID1']}>
                <Routes>
                    <Route path="/student/:userID" element={<StudentDetailPage />} />
                </Routes>
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/Failed to load user details./i)).toBeInTheDocument();
        });
    });
});