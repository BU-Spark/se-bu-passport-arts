import React from 'react';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { vi, describe, it, expect, beforeEach } from 'vitest';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import '@testing-library/jest-dom';
import { Timestamp } from 'firebase/firestore';
import EditEventPage from '../src/pages/EditEventPage';
import { Event } from '../src/interfaces/Event';
import { fetchSingleEvent } from '../src/firebase/firebaseService';
import { googleMapKey } from '../src/config';

import URLEdit from '../src/components/eventEdit/LinkEdit';
import PointEdit from '../src/components/eventEdit/PointEdit';
import LocationEdit from '../src/components/eventEdit/LocationEdit';
import DescriptionEdit from '../src/components/eventEdit/DescriptionEdit';
import PhotoEdit from '../src/components/eventEdit/PhotoEdit';
import TitleEdit from '../src/components/eventEdit/TitleEdit';
import CategoryEdit from '../src/components/eventEdit/CategoryEdit';


vi.mock('../src/firebase/firebaseService', () => ({
    fetchSingleEvent: vi.fn(),
    fetchEventAttendanceWithProfiles: vi.fn(),
}));

const mockEvent: Event = {
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
};

describe('EditEventPage', () => {
    beforeEach(() => {
        (fetchSingleEvent as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(mockEvent);
    });

    it('renders without crashing', async () => {
        render(
            <MemoryRouter initialEntries={['/edit-event/297397']}>
                <Routes>
                    <Route path="/edit-event/:eventID" element={<EditEventPage />} />
                </Routes>
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/Upcoming Event/i)).toBeInTheDocument();
        });
    });

    it('renders event details correctly', async () => {
        render(
            <MemoryRouter initialEntries={['/edit-event/297397']}>
                <Routes>
                    <Route path="/edit-event/:eventID" element={<EditEventPage />} />
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
        });
    });
})

describe('PointEdit Component', () => {
    const mockEvent = {
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
                startTime: new Timestamp(1672531200, 0),
                savedUsers: [],
                endTime: new Timestamp(1672538400, 0),
            },
        },
    };
    const newPoints = 20;

    it('allows editing and saving points', () => {
        const mockSetEvent = vi.fn();
        render(<PointEdit event={mockEvent} setEvent={mockSetEvent} />);

        const pointsText = screen.getByText(`Pts: ${mockEvent.eventPoints}`);
        expect(pointsText).toBeInTheDocument();

        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        const inputField = screen.getByDisplayValue(mockEvent.eventPoints.toString());
        expect(inputField).toBeInTheDocument();

        fireEvent.change(inputField, { target: { value: newPoints.toString() } });

        const saveButton = screen.getByText('Save');
        fireEvent.click(saveButton);

        const updatedEvent = mockSetEvent.mock.calls[0][0](mockEvent);
        expect(updatedEvent).toEqual({
            ...mockEvent,
            eventPoints: newPoints,
        });

        expect(mockSetEvent).toHaveBeenCalledTimes(1);
    });

    it('cancels editing and reverts points', () => {
        const mockSetEvent = vi.fn();
        render(<PointEdit event={mockEvent} setEvent={mockSetEvent} />);

        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        const inputField = screen.getByDisplayValue(mockEvent.eventPoints.toString());
        fireEvent.change(inputField, { target: { value: mockEvent.eventPoints.toString() } });

        const cancelButton = screen.getByText('Cancel');
        fireEvent.click(cancelButton);

        expect(mockSetEvent).not.toHaveBeenCalled();
        expect(screen.getByText(`Pts: ${mockEvent.eventPoints}`)).toBeInTheDocument();
    });
});

describe('LocationEdit Component', () => {
    const newLocation = 'New Location';

    it('allows editing and saving location', () => {

        const mockSetEvent = vi.fn();

        render(<LocationEdit event={mockEvent} setEvent={mockSetEvent} googleMapKey={googleMapKey} />);

        const locationText = screen.getByText(mockEvent.eventLocation);
        expect(locationText).toBeInTheDocument();

        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        const inputField = screen.getByDisplayValue(mockEvent.eventLocation);
        expect(inputField).toBeInTheDocument();

        fireEvent.change(inputField, { target: { value: newLocation } });

        const saveButton = screen.getByText('Save');
        fireEvent.click(saveButton);

        const updatedEvent = mockSetEvent.mock.calls[0][0](mockEvent);
        expect(updatedEvent).toEqual({
            ...mockEvent,
            eventLocation: newLocation,
        });

        expect(mockSetEvent).toHaveBeenCalledTimes(1);
    });

    it('cancels editing and reverts location', () => {
        const mockSetEvent = vi.fn();
        render(<LocationEdit event={mockEvent} setEvent={mockSetEvent} googleMapKey={googleMapKey} />);

        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        const inputField = screen.getByDisplayValue(mockEvent.eventLocation);
        fireEvent.change(inputField, { target: { value: mockEvent.eventLocation } });

        const cancelButton = screen.getByText('Cancel');
        fireEvent.click(cancelButton);

        expect(mockSetEvent).not.toHaveBeenCalled();
        expect(screen.getByText(mockEvent.eventLocation)).toBeInTheDocument();
    });
});

describe('DescriptionEdit Component', () => {
    const newDescription = 'New Description';

    it('allows editing and saving description', () => {
        const mockSetEvent = vi.fn();
        render(<DescriptionEdit event={mockEvent} setEvent={mockSetEvent} />);

        const descriptionText = screen.getByText(mockEvent.eventDescription);
        expect(descriptionText).toBeInTheDocument();

        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        const inputField = screen.getByDisplayValue(mockEvent.eventDescription);
        expect(inputField).toBeInTheDocument();

        fireEvent.change(inputField, { target: { value: newDescription } });

        const saveButton = screen.getByText('Save');
        fireEvent.click(saveButton);

        const updatedEvent = mockSetEvent.mock.calls[0][0](mockEvent);
        expect(updatedEvent).toEqual({
            ...mockEvent,
            eventDescription: newDescription,
        });

        expect(mockSetEvent).toHaveBeenCalledTimes(1);
    });

    it('cancels editing and reverts description', () => {
        const mockSetEvent = vi.fn();
        render(<DescriptionEdit event={mockEvent} setEvent={mockSetEvent} />);

        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        const inputField = screen.getByDisplayValue(mockEvent.eventDescription);
        fireEvent.change(inputField, { target: { value: mockEvent.eventDescription } });

        const cancelButton = screen.getByText('Cancel');
        fireEvent.click(cancelButton);

        expect(mockSetEvent).not.toHaveBeenCalled();
        expect(screen.getByText(mockEvent.eventDescription)).toBeInTheDocument();
    });
});

describe('PhotoEdit Component', () => {
    const newPhoto = 'https://newphoto.com/photo.jpg';

    it('allows editing and saving photo', () => {
        const mockSetEvent = vi.fn();
        render(<PhotoEdit event={mockEvent} setEvent={mockSetEvent} />);

        const photoImg = screen.getByAltText('Event Preview');
        expect(photoImg).toHaveAttribute('src', mockEvent.eventPhoto);

        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        const inputField = screen.getByDisplayValue(mockEvent.eventPhoto);
        expect(inputField).toBeInTheDocument();

        fireEvent.change(inputField, { target: { value: newPhoto } });

        const saveButton = screen.getByText('Save');
        fireEvent.click(saveButton);

        const updatedEvent = mockSetEvent.mock.calls[0][0](mockEvent);
        expect(updatedEvent).toEqual({
            ...mockEvent,
            eventPhoto: newPhoto,
        });

        expect(mockSetEvent).toHaveBeenCalledTimes(1);
    });

    it('cancels editing and reverts photo', () => {
        const mockSetEvent = vi.fn();
        render(<PhotoEdit event={mockEvent} setEvent={mockSetEvent} />);

        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        const inputField = screen.getByDisplayValue(mockEvent.eventPhoto);
        fireEvent.change(inputField, { target: { value: mockEvent.eventPhoto } });

        const cancelButton = screen.getByText('Cancel');
        fireEvent.click(cancelButton);

        expect(mockSetEvent).not.toHaveBeenCalled();
        expect(screen.getByAltText('Event Preview')).toHaveAttribute('src', mockEvent.eventPhoto);
    });
});

describe('TitleEdit Component', () => {
    const newTitle = 'New Event Title';

    it('allows editing and saving title', () => {
        const mockSetEvent = vi.fn();
        render(<TitleEdit event={mockEvent} setEvent={mockSetEvent} />);

        const titleText = screen.getByText(mockEvent.eventTitle);
        expect(titleText).toBeInTheDocument();

        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        const inputField = screen.getByDisplayValue(mockEvent.eventTitle);
        expect(inputField).toBeInTheDocument();

        fireEvent.change(inputField, { target: { value: newTitle } });

        const saveButton = screen.getByText('Save');
        fireEvent.click(saveButton);

        const updatedEvent = mockSetEvent.mock.calls[0][0](mockEvent);
        expect(updatedEvent).toEqual({
            ...mockEvent,
            eventTitle: newTitle,
        });

        expect(mockSetEvent).toHaveBeenCalledTimes(1);
    });

    it('cancels editing and reverts title', () => {
        const mockSetEvent = vi.fn();
        render(<TitleEdit event={mockEvent} setEvent={mockSetEvent} />);

        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        const inputField = screen.getByDisplayValue(mockEvent.eventTitle);
        fireEvent.change(inputField, { target: { value: mockEvent.eventTitle } });

        const cancelButton = screen.getByText('Cancel');
        fireEvent.click(cancelButton);

        expect(mockSetEvent).not.toHaveBeenCalled();
        expect(screen.getByText(mockEvent.eventTitle)).toBeInTheDocument();
    });
});

describe('CategoryEdit Component', () => {
    const newCategories = [
        'Updated Category 1',
        'New Category 2'
    ]

    it('allows editing and saving categories', () => {
        const mockSetEvent = vi.fn();

        // Render the component
        render(<CategoryEdit event={mockEvent} setEvent={mockSetEvent} />);

        // Simulate clicking the "Edit" button
        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        // Modify the first category input
        const inputFields = screen.getAllByDisplayValue(/Category/);
        fireEvent.change(inputFields[0], { target: { value: newCategories[0] } });


        const addButton = screen.getByText('Add Category');
        fireEvent.click(addButton);

        // Ensure the new input field is rendered
        const newInputField = screen.getAllByDisplayValue('New Category')[0];
        fireEvent.change(newInputField, { target: { value: newCategories[1] } });


        // Click the Save button
        const saveButton = screen.getByText('Save');
        fireEvent.click(saveButton);

        // Manually simulate the updater function passed to setEvent
        const updateFunction = mockSetEvent.mock.calls[0][0];
        const updatedEvent = updateFunction(mockEvent); // Call the function with the current state

        // Verify that the updated event has the new categories
        expect(updatedEvent).toEqual({
            ...mockEvent,
            eventCategories: newCategories,
        });

        // Ensure setEvent was called once
        expect(mockSetEvent).toHaveBeenCalledTimes(1);
    });

    it('cancels editing and reverts categories', () => {
        const mockSetEvent = vi.fn();
        render(<CategoryEdit event={mockEvent} setEvent={mockSetEvent} />);

        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        const inputField = screen.getByDisplayValue(mockEvent.eventCategories.join(', '));
        fireEvent.change(inputField, { target: { value: mockEvent.eventCategories.join(', ') } });

        const cancelButton = screen.getByText('Cancel');
        fireEvent.click(cancelButton);

        expect(mockSetEvent).not.toHaveBeenCalled();
        mockEvent.eventCategories.forEach(category => {
            expect(screen.getByText(category)).toBeInTheDocument();
        });
    });
});

describe('URLEdit Component', () => {
    const newURL = 'https://newurl.com';

    it('allows editing and saving a URL', () => {
        // Mock setEvent function
        const mockSetEvent = vi.fn();

        // Render the URLEdit component
        render(<URLEdit event={mockEvent} setEvent={mockSetEvent} />);

        // Check that the URL is displayed
        const urlLink = screen.getByText(mockEvent.eventURL);
        expect(urlLink).toBeInTheDocument();

        // Click the edit button
        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        // Check that the input field appears with the correct value
        const inputField = screen.getByDisplayValue(mockEvent.eventURL);
        expect(inputField).toBeInTheDocument();

        // Change the URL
        fireEvent.change(inputField, { target: { value: newURL } });

        // Click the Save button
        const saveButton = screen.getByText('Save');
        fireEvent.click(saveButton);

        // Manually simulate the updater function to check the expected result
        const updatedEvent = mockSetEvent.mock.calls[0][0](mockEvent);
        expect(updatedEvent).toEqual({
            ...mockEvent,
            eventURL: newURL,
        });

        // Ensure setEvent was called once
        expect(mockSetEvent).toHaveBeenCalledTimes(1);
    });

    it('cancels editing and reverts the URL', () => {
        // Mock setEvent function
        const mockSetEvent = vi.fn();

        // Render the URLEdit component
        render(<URLEdit event={mockEvent} setEvent={mockSetEvent} />);

        // Click the edit button
        const editButton = screen.getByAltText('Edit');
        fireEvent.click(editButton);

        // Modify the input field
        const inputField = screen.getByDisplayValue(mockEvent.eventURL);
        fireEvent.change(inputField, { target: { value: mockEvent.eventURL } });

        // Click the Cancel button
        const cancelButton = screen.getByText('Cancel');
        fireEvent.click(cancelButton);

        // Verify that setEvent was not called
        expect(mockSetEvent).not.toHaveBeenCalled();

        // Verify the original URL is still displayed
        expect(screen.getByText(mockEvent.eventURL)).toBeInTheDocument();
    });
});