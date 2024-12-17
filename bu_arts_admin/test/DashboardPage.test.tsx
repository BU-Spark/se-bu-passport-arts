import React from 'react';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { describe, it, expect, beforeEach } from 'vitest';
import { format, subMonths } from 'date-fns';
import { MemoryRouter } from 'react-router-dom';
import '@testing-library/jest-dom';
import DashboardPage from '../src/pages/DashboardPage';

const getLastNMonths = (months: number): string[] => {
    const labels: string[] = [];
    const currentDate = new Date();

    for (let i = months - 1; i >= 0; i--) {
        const date = subMonths(currentDate, i);
        labels.push(format(date, 'yyyy-MM'));
    }

    return labels;
};

describe('DashboardPage', () => {
    it('renders without crashing', async () => {
        render(
            <MemoryRouter>
                <DashboardPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/Dashboard/i)).toBeInTheDocument();
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

    it('updates substitles and x-axis labels when time range is changed', async () => {
        render(
            <MemoryRouter>
                <DashboardPage />
            </MemoryRouter>
        );

        // Wait for the initial render
        await waitFor(() => {
            expect(screen.getByText(/Total New Users/i)).toBeInTheDocument();
        });

        // Simulate changing the time range
        fireEvent.change(screen.getByLabelText(/Select Time Range/i), { target: { value: '6' } });

        await waitFor(() => {
            expect(screen.getAllByText(/Last 6 Months/i).find(el => el.tagName.toLowerCase() === 'p')).toBeInTheDocument();
        });

        const mockLast6Months = getLastNMonths(6);
        mockLast6Months.forEach(label => {
            expect(screen.getByText(label)).toBeInTheDocument();
        });

        // Simulate changing the time range again
        fireEvent.change(screen.getByLabelText(/Select Time Range/i), { target: { value: '12' } });

        // Wait for the range description to update
        await waitFor(() => {
            expect(screen.getAllByText(/Last Year/i).find(el => el.tagName.toLowerCase() === 'p')).toBeInTheDocument();
        });

        const mockLast12Months = getLastNMonths(12);
        mockLast12Months.forEach(label => {
            expect(screen.getByText(label)).toBeInTheDocument();
        });
    });
})

describe('DashboardPage: Monthly Event Count Widget', () => {
    it('renders without crashing', async () => {
        render(
            <MemoryRouter>
                <DashboardPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/Monthly Events/i)).toBeInTheDocument();
            expect(screen.getByRole('button', { name: /See All Events/i })).toBeInTheDocument();
        });
    });
})