import { useNavigate } from 'react-router-dom';
import { Event } from "../interfaces/Event";

const PastEventBox = ({ event }: { event: Event }) => {
    const navigate = useNavigate();

    const handleEdit = () => {
        navigate(`/view-event/${event.eventID}`);
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
            {/* "See Event Details" Button */}
            <button
                onClick={handleEdit}
                className="absolute top-2 left-2 bg-red-600 text-white px-3 py-1 rounded-md text-sm"
            >
                See Event Details
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

export default PastEventBox;