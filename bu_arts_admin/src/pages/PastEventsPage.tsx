// src/components/FetchAllEvents.tsx
import React, { useEffect, useState } from 'react';
import { Event } from "../interfaces/Event"
import PastEventBox from "../components/PastEventBox"
import { fetchPastBuEvents, getAvailableEventCategories } from '../services/buEventsService';

interface FetchAllEventsProps {
}

const PastEventsPage: React.FC<FetchAllEventsProps> = () => {
    const [loading, setLoading] = useState<boolean>(true);
    const [baseEvents, setBaseEvents] = useState<Event[]>([]);
    const [events, setEvents] = useState<Event[]>([]);
    const [error, setError] = useState<string | null>(null);
    const [searchText, setSearchText] = useState('');
    const [selectedDate, setSelectedDate] = useState('');
    const [selectedCategory, setSelectedCategory] = useState('');

    const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        setSearchText(event.target.value);
    };

    useEffect(() => {
        let isMounted = true;

        const fetchEvents = async () => {
            try {
                setLoading(true);
                setError(null);
                const pastEvents = await fetchPastBuEvents({ searchText, selectedDate });

                if (isMounted) {
                    setBaseEvents(pastEvents);
                }
            } catch (error) {
                if (isMounted) {
                    setError('Failed to load events');
                }
                console.error('Error fetching events:', error);
            } finally {
                if (isMounted) {
                    setLoading(false);
                }
            }
        };

        fetchEvents();

        return () => {
            isMounted = false;
        };
    }, [searchText, selectedDate]);

    const availableCategories = getAvailableEventCategories(baseEvents);

    useEffect(() => {
        if (selectedCategory && !availableCategories.includes(selectedCategory)) {
            setSelectedCategory('');
        }
    }, [availableCategories, selectedCategory]);

    useEffect(() => {
        if (!selectedCategory) {
            setEvents(baseEvents);
            return;
        }

        setEvents(
            baseEvents.filter((event) => event.eventCategories.includes(selectedCategory))
        );
    }, [baseEvents, selectedCategory]);

    if (loading) return <p className="text-center text-lg text-gray-500">Loading events...</p>;
    if (error) return <p className="text-center text-red-500">{error}</p>;

    return (
        <div>
            <div className="flex items-center space-x-4 mb-6">
                <h1 className="text-2xl font-semibold text-bured">Past Events</h1>
                <div className="relative">
                    <input
                        type="text"
                        placeholder="Search anything here..."
                        value={searchText}
                        onChange={handleInputChange}
                        className="border border-gray-300 rounded-full py-2 pl-4 pr-10 text-gray-700 focus:outline-none focus:ring-2 focus:ring-bured"
                    />
                    <img className="w-5 h-5 text-gray-400 absolute right-3 top-2.5" src="/public/icons/search.png" alt="search_icon" />
                </div>
                <input
                    type="date"
                    value={selectedDate}
                    onChange={(event) => setSelectedDate(event.target.value)}
                    className="border border-gray-300 rounded-full py-2 px-4 text-gray-700 focus:outline-none focus:ring-2 focus:ring-bured"
                />
                <div className="relative">
                    <select
                        value={selectedCategory}
                        onChange={(event) => setSelectedCategory(event.target.value)}
                        className="appearance-none border border-gray-300 rounded-full py-2 pl-4 pr-12 text-gray-700 focus:outline-none focus:ring-2 focus:ring-bured bg-white"
                    >
                        <option value="">All Categories</option>
                        {availableCategories.map((category) => (
                            <option key={category} value={category}>
                                {category}
                            </option>
                        ))}
                    </select>
                    <span className="pointer-events-none absolute inset-y-0 right-4 flex items-center text-gray-500">
                        <svg className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                            <path
                                fillRule="evenodd"
                                d="M5.23 7.21a.75.75 0 0 1 1.06.02L10 11.168l3.71-3.938a.75.75 0 1 1 1.08 1.04l-4.25 4.5a.75.75 0 0 1-1.08 0l-4.25-4.5a.75.75 0 0 1 .02-1.06Z"
                                clipRule="evenodd"
                            />
                        </svg>
                    </span>
                </div>
            </div>
            <div className="min-h-screen flex flex-col mx-auto p-6 overflow-x-hidden">
                <div className="flex-grow h-96 overflow-y-auto bg-slate-50 px-4">
                    {events.length > 0 ? (
                        <ul className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                            {events.map((event) => (
                                <PastEventBox key={event.eventID} event={event} />
                            ))}
                        </ul>
                    ) : (
                        <p className="text-center text-gray-600">No events found.</p>
                    )}
                </div>
            </div>
        </div>
    );
};

export default PastEventsPage;
