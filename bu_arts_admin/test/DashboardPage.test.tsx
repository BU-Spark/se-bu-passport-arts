import React from 'react';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { format, subMonths } from 'date-fns';
import { MemoryRouter } from 'react-router-dom';
import '@testing-library/jest-dom';
import DashboardPage from '../src/pages/DashboardPage';
import { fetchUserRegistrationStats } from '../src/firebase/firebaseService';

const getLastNMonths = (months: number): string[] => {
    const labels: string[] = [];
    const currentDate = new Date();

    for (let i = months - 1; i >= 0; i--) {
        const date = subMonths(currentDate, i);
        labels.push(format(date, 'yyyy-MM'));
    }

    return labels;
};

vi.mock('../src/firebase/firebaseService', () => ({
    fetchUserRegistrationStats: vi.fn(),
}));

vi.mock('../src/components/dashboard/CurrentMonthEventInsights', () => ({
    default: () => <div>Current Month Event Insights</div>,
}));

describe('DashboardPage', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        (fetchUserRegistrationStats as unknown as ReturnType<typeof vi.fn>).mockImplementation(async (numMonths: number) => {
            const months = getLastNMonths(numMonths === 0 ? 12 : numMonths);
            return {
                months,
                registrations: months.map((_, index) => index + 1),
            };
        });
    });

    it('renders without crashing', async () => {
        render(
            <MemoryRouter>
                <DashboardPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/Dashboard/i)).toBeInTheDocument();
            expect(screen.getByText(/Current Month Event Insights/i)).toBeInTheDocument();
        });
    });
})

describe('DashboardPage: Chart of new users', () => {
    it('renders chart of number of new users', async () => {
        render(
            <MemoryRouter>
                <DashboardPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/Total New Users/i)).toBeInTheDocument();
        });
    });

    it('updates the selected time range when changed', async () => {
        render(
            <MemoryRouter>
                <DashboardPage />
            </MemoryRouter>
        );

        // Wait for the initial render
        await waitFor(() => {
            expect(screen.getByText(/Total New Users/i)).toBeInTheDocument();
        });

        const rangeSelect = screen.getByLabelText(/Select Time Range/i) as HTMLSelectElement;
        expect(rangeSelect.value).toBe('6');

        fireEvent.change(rangeSelect, { target: { value: '12' } });

        await waitFor(() => {
            expect((screen.getByLabelText(/Select Time Range/i) as HTMLSelectElement).value).toBe('12');
        });

        expect(fetchUserRegistrationStats).toHaveBeenLastCalledWith(12);
    });
})