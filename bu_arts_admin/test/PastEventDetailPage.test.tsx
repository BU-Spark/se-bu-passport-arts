import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { vi, describe, it, expect, beforeEach } from 'vitest';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import '@testing-library/jest-dom';
import PastEventDetailPage from '../src/pages/PastEventDetailPage';
import { fetchSingleEvent, fetchEventAttendanceWithProfiles } from '../src/firebase/firebaseService';

vi.mock('../src/firebase/firebaseService', () => ({
    fetchSingleEvent: vi.fn(),
    fetchEventAttendanceWithProfiles: vi.fn(),
}));

describe('PastEventDetailPage', () => {
    const mockEvent = {
        eventPhoto: 'https://example.com/event-photo.jpg',
        eventTitle: 'Sample Event',
        eventCategories: ['Category1', 'Category2'],
        eventPoints: 100,
        eventLocation: '123 Main St, City, Country',
        eventDescription: 'This is a sample event description.',
        eventURL: 'https://example.com',
        eventSessions: {
            session1: {
                sessionId: 'session1',
                startTime: { toDate: () => new Date('2023-01-01T10:00:00Z') },
                endTime: { toDate: () => new Date('2023-01-01T12:00:00Z') },
            },
        },
    };

    const mockAttendanceProfiles = [
        { userProfileURL: 'https://example.com/profile1.jpg' },
        { userProfileURL: 'https://example.com/profile2.jpg' },
        { userProfileURL: 'https://example.com/profile3.jpg' },
        { userProfileURL: 'https://example.com/profile4.jpg' },
        { userProfileURL: 'https://example.com/profile5.jpg' },
    ];

    beforeEach(() => {
        (fetchSingleEvent as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(mockEvent);
        (fetchEventAttendanceWithProfiles as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(
            mockAttendanceProfiles.map(profile => ({ attendance: {}, userProfile: profile }))
        );
    });

    it('renders without crashing', async () => {
        render(
            <MemoryRouter initialEntries={['/view-event/297397']}>
                <Routes>
                    <Route path="/view-event/:eventID" element={<PastEventDetailPage />} />
                </Routes>
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/Past Event/i)).toBeInTheDocument();
        });
    });

    it('renders event details correctly', async () => {
        render(
            <MemoryRouter initialEntries={['/view-event/297397']}>
                <Routes>
                    <Route path="/view-event/:eventID" element={<PastEventDetailPage />} />
                </Routes>
            </MemoryRouter>
        );

        await waitFor(() => {
            // Check if eventPhoto is rendered
            expect(screen.getByAltText('Event Preview')).toHaveAttribute('src', mockEvent.eventPhoto);

            // Check if eventTitle is rendered
            expect(screen.getByText(mockEvent.eventTitle)).toBeInTheDocument();

            // Check if eventCategories are rendered
            mockEvent.eventCategories.forEach(category => {
                expect(screen.getByText(category)).toBeInTheDocument();
            });

            // Check if eventPoints are rendered
            expect(screen.getByText(`Pts: ${mockEvent.eventPoints}`)).toBeInTheDocument();

            // Check if eventLocation is rendered
            expect(screen.getByText(mockEvent.eventLocation)).toBeInTheDocument();

            // Check if eventDescription is rendered
            expect(screen.getByText(mockEvent.eventDescription)).toBeInTheDocument();

            // Check if eventURL is rendered
            expect(screen.getByText(mockEvent.eventURL)).toHaveAttribute('href', mockEvent.eventURL);

            const profileImages = screen.getAllByAltText('profile');
            profileImages.slice(0, 4).forEach((img, index) => {
                expect(img).toHaveAttribute('src', mockAttendanceProfiles[index].userProfileURL);
            });

            // Check if "+N" is rendered for additional profiles
            if (mockAttendanceProfiles.length > 4) {
                expect(screen.getByText(`+${mockAttendanceProfiles.length - 4}`)).toBeInTheDocument();
            }

            // Check if the "Details" button is rendered
            expect(screen.getByRole('button', { name: /Details/i })).toBeInTheDocument();
        });
    });


})