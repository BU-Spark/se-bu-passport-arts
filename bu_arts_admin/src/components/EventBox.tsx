import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Event } from "../interfaces/Event";

const EventBox = ({ event }: { event: Event }) => {
    const navigate = useNavigate();

    const handleEdit = () => {
        navigate(`/edit-event/${event.eventID}`);
    };

    return (
        <div className="event-box p-4 border border-gray-200 rounded-lg shadow-md mb-4">
            <h3 className="text-lg font-semibold">{event.eventTitle}</h3>
            <p className="text-gray-600 line-clamp-2">{event.eventDescription}</p>
            <p className="text-sm text-gray-500">Categories: {event.eventCategories.join(', ')}</p>
            <button
                onClick={handleEdit}
                className="mt-2 px-4 py-2 bg-bured text-white rounded hover:bg-bured transition-colors duration-200"
            >
                Edit
            </button>
        </div>
    );
};

export default EventBox;
