import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Event } from "../interfaces/Event";

// const EventBox = ({ event }: { event: Event }) => {
//     const navigate = useNavigate();

//     const handleEdit = () => {
//         navigate(`/edit-event/${event.eventID}`);
//     };

//     return (
//         <div className="event-box p-4 border border-gray-200 rounded-lg shadow-md mb-4">
//             <h3 className="text-lg font-semibold">{event.eventTitle}</h3>
//             <p className="text-gray-600 line-clamp-2">{event.eventDescription}</p>
//             <p className="text-sm text-gray-500">Categories: {event.eventCategories.join(', ')}</p>
//             <button
//                 onClick={handleEdit}
//                 className="mt-2 px-4 py-2 bg-bured text-white rounded hover:bg-bured transition-colors duration-200"
//             >
//                 Edit
//             </button>
//         </div>
//     );
// };
const EventBox = ({ event }: { event: Event }) => {
    const navigate = useNavigate();

    const handleEdit = () => {
        navigate(`/edit-event/${event.eventID}`);
    };

    return (
        
        <div
            className="relative event-box w-96 p-4 m-10 border rounded-lg shadow-md mb-4 text-white overflow-hidden"
            style={{
                backgroundImage: `url(${event.eventPhoto})`,
                backgroundSize: 'cover',
                backgroundPosition: 'center',
                minHeight: '200px',
            }}
        >
            <div className="absolute inset-0 bg-black opacity-40 rounded-lg pointer-events-none"></div>
            {/* "Go Edit Event" Button */}
            <button
                onClick={handleEdit}
                className="absolute top-2 left-2 bg-red-600 text-white px-3 py-1 rounded-md text-sm"
            >
                Go Edit Event
            </button>

            {/* "Free!" Label */}
            <div className="absolute top-2 right-2 bg-red-600 text-white px-3 py-1 rounded-md text-sm">
                {event.eventCategories[0]|| ""}
            </div>

            {/* Event Details */}
            <div className="absolute bottom-4 left-4">
                <h3 className="text-lg font-semibold">{event.eventTitle}</h3>
                <p className="text-sm">{event.eventLocation}</p>
            </div>
        </div>
    );
};

export default EventBox;
