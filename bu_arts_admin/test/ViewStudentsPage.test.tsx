import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { describe, it, expect, vi } from 'vitest';
import ViewStudentsPage from '../src/pages/ViewStudentsPage';
import { searchUsers } from '../src/firebase/firebaseService';
import { User } from '../src/interfaces/User';
import { Timestamp } from 'firebase/firestore';

// Mock the fetchStudents function
vi.mock('../src/firebase/firebaseService', () => ({
    searchUsers: vi.fn(),
}));


const mockStudents: User[] = [
  {
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
  },
  {
    firstName: 'Jane',
    lastName: 'Smith',
    userBUID: 'BUID2',
    userProfileURL: 'https://example.com/profile2.jpg',
    userEmail: 'jane@example.com',
    userPoints: 150,
    userSchool: 'School of Science',
    userUID: 'UID2',
    userYear: 'Junior',
    userSavedEvents: new Map(),
    userCreated: new Timestamp(1672531200, 0),
  },
];

describe('ViewStudentsPage', () => {
    it('renders without crashing', async () => {
        (searchUsers as unknown as ReturnType<typeof vi.fn>).mockResolvedValue([]);

        render(
            <MemoryRouter>
                <ViewStudentsPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText("Students")).toBeInTheDocument();
        });
    });

    it('displays a list of students', async () => {
        (searchUsers as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(mockStudents);

        render(
            <MemoryRouter>
                <ViewStudentsPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/John Doe/i)).toBeInTheDocument();
            expect(screen.getByText(/Jane Smith/i)).toBeInTheDocument();
        });
    });

    it('displays an error message if fetching students fails', async () => {
        (searchUsers as unknown as ReturnType<typeof vi.fn>).mockRejectedValue(new Error('Failed to fetch students'));

        render(
            <MemoryRouter>
                <ViewStudentsPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/Failed to load users/i)).toBeInTheDocument();
        });
    });
});