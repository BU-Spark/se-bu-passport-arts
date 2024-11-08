// src/components/FetchAllEvents.tsx
import React, { useEffect, useState } from 'react';
import { fetchAllEvents } from "../firebase/firebaseService"
import { Event } from "../interfaces/Event"
import EventBox from "../components/EventBox"

interface FetchAllEventsProps {
}

const ViewAllEventsPage: React.FC<FetchAllEventsProps> = () => {
    const [loading, setLoading] = useState<boolean>(true);
    const [events, setEvents] = useState<Event[]>([]);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchEvents = async () => {
            try {
                const eventsData = await fetchAllEvents();
                setEvents(eventsData);
            } catch (error) {
                setError('Failed to load events');
                console.error('Error fetching events:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchEvents();
    }, []);

    if (loading) return <p className="text-center text-lg text-gray-500">Loading events...</p>;
    if (error) return <p className="text-center text-red-500">{error}</p>;

    return (
        <div>
            <div className="flex items-center space-x-4 mb-6">
                <h1 className="text-2xl font-semibold text-bured">Event</h1>
                <div className="relative">
                    <input
                        type="text"
                        placeholder="Search anything here..."
                        className="border border-gray-300 rounded-full py-2 pl-4 pr-10 text-gray-700 focus:outline-none focus:ring-2 focus:ring-purple-500"
                    />
                    <img className="w-5 h-5 text-gray-400 absolute right-3 top-2.5" src="/public/icons/search.png" alt="search_icon" />
                </div>
            </div>
            <div className="min-h-screen flex flex-col mx-auto p-6">

                {/* Scrollable events container */}
                <div className="flex-grow h-96 overflow-y-auto bg-slate-50">
                    {events.length > 0 ? (
                        <ul className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                            {events.map((event) => (
                                <EventBox key={event.eventID} event={event} />
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

export default ViewAllEventsPage;
