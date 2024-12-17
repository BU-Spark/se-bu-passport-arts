import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { vi, describe, it, expect, beforeEach, Mock } from 'vitest';
import { MemoryRouter } from 'react-router-dom';
import '@testing-library/jest-dom';
import PastEventsPage from '../src/pages/PastEventsPage';
import { fetchPastEvents } from '../src/firebase/firebaseService';
import { Timestamp } from 'firebase/firestore';
import { Event } from '../src/interfaces/Event';

// Mock fetchPastEvents function
vi.mock('../src/firebase/firebaseService', () => ({
    fetchPastEvents: vi.fn(),
}));

describe('PastEventsPage', () => {
    const mockFetchPastEvents = fetchPastEvents as Mock;
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('renders without crashing', async () => {
        const mockEvents: Event[] = [];
        mockFetchPastEvents.mockResolvedValue(mockEvents);
        console.log('Mock events:', mockFetchPastEvents.mock.results);
        render(
            <MemoryRouter>
                <PastEventsPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/Past Events/i)).toBeInTheDocument();
        });
    });

    it('renders no events found', async () => {
        const mockEvents: Event[] = [];
        mockFetchPastEvents.mockResolvedValue(mockEvents);
        console.log('Mock events:', mockFetchPastEvents.mock.results);

        render(
            <MemoryRouter>
                <PastEventsPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText("No events found.")).toBeInTheDocument();
        });
    });

    it('renders error message when fetch fails', async () => {
        mockFetchPastEvents.mockRejectedValue(new Error('Fetch failed'));

        render(
            <MemoryRouter>
                <PastEventsPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/Failed to load events/i)).toBeInTheDocument();
        });
    });

    it('renders PastEventsPage correctly with fetched events', async () => {
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
        mockFetchPastEvents.mockResolvedValue(mockEvents);

        render(
            <MemoryRouter>
                <PastEventsPage />
            </MemoryRouter>
        );

        // Wait for events to load
        await waitFor(() => {
            expect(screen.getByText(/Past Events/i)).toBeInTheDocument();
        });

        // Verify real PastEventBox components render
        expect(screen.getByText('Event 1')).toBeInTheDocument();
        expect(screen.getByText('Location 1')).toBeInTheDocument();
        expect(screen.getByText('Event 2')).toBeInTheDocument();
        expect(screen.getByText('Location 2')).toBeInTheDocument();
    });
})