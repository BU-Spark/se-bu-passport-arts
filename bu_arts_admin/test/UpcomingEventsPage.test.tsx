import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { vi, describe, it, expect, beforeEach, Mock } from 'vitest';
import { MemoryRouter } from 'react-router-dom';
import '@testing-library/jest-dom';
import UpcomingEventsPage from '../src/pages/UpcomingEventsPage';
import { fetchFutureEvents } from '../src/firebase/firebaseService';
import { Timestamp } from 'firebase/firestore';
import { Event } from '../src/interfaces/Event';

// Mock fetchPastEvents function
vi.mock('../src/firebase/firebaseService', () => ({
    fetchFutureEvents: vi.fn(),
}));

describe('UpcomingEventsPage', () => {
    const mockFetchUpcomingEvents = fetchFutureEvents as Mock;
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('renders without crashing', async () => {
        const mockEvents: Event[] = [];
        mockFetchUpcomingEvents.mockResolvedValue(mockEvents);
        console.log('Mock events:', mockFetchUpcomingEvents.mock.results);
        render(
            <MemoryRouter>
                <UpcomingEventsPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/Upcoming Events/i)).toBeInTheDocument();
        });
    });

    it('renders no events found', async () => {
        const mockEvents: Event[] = [];
        mockFetchUpcomingEvents.mockResolvedValue(mockEvents);
        console.log('Mock events:', mockFetchUpcomingEvents.mock.results);

        render(
            <MemoryRouter>
                <UpcomingEventsPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText("No events found.")).toBeInTheDocument();
        });
    });

    it('renders error message when fetch fails', async () => {
        mockFetchUpcomingEvents.mockRejectedValue(new Error('Fetch failed'));

        render(
            <MemoryRouter>
                <UpcomingEventsPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/Failed to load events/i)).toBeInTheDocument();
        });
    });

    it('renders UpcomingEventsPage correctly with fetched events', async () => {
        const mockEvents: Event[] = [
            {
                eventID: '1',
                eventTitle: 'Event 1',
                eventLocation: 'Location 1',
                eventPhoto: '',
                eventCategories: ['Category 1'],
                eventDescription: 'Event 1 description',
                eventURL: 'https://example.com/event1',
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
                eventTitle: 'Event 2',
                eventLocation: 'Location 2',
                eventPhoto: '',
                eventCategories: ['Category 2'],
                eventDescription: 'Event 2 description',
                eventURL: 'https://example.com/event2',
                eventPoints: 20,
                eventSessions: {
                    session1: {
                        sessionId: 'session1',
                        savedUsers: [],
                        startTime: new Timestamp(1672531200, 0), // Mock Timestamp
                        endTime: new Timestamp(1672538400, 0), // Mock Timestamp
                    },
                },
            },
        ];
        // const mockedFetchPastEvents = vi.mocked(fetchPastEvents);
        mockFetchUpcomingEvents.mockResolvedValue(mockEvents);

        render(
            <MemoryRouter>
                <UpcomingEventsPage />
            </MemoryRouter>
        );

        // Wait for events to load
        await waitFor(() => {
            expect(screen.getByText(/Upcoming Events/i)).toBeInTheDocument();
        });

        // Verify real PastEventBox components render
        expect(screen.getByText('Event 1')).toBeInTheDocument();
        expect(screen.getByText('Location 1')).toBeInTheDocument();
        expect(screen.getByText('Event 2')).toBeInTheDocument();
        expect(screen.getByText('Location 2')).toBeInTheDocument();
    });
})