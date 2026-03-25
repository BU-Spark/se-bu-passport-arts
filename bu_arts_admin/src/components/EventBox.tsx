import { useNavigate } from 'react-router-dom';
import { Event } from "../interfaces/Event";
import { getEventVisualSrc } from '../utils/eventVisuals';

const EventBox = ({ event }: { event: Event }) => {
    const navigate = useNavigate();
    const eventVisualSrc = getEventVisualSrc(event);

    const handleEdit = () => {
        navigate(`/edit-event/${event.eventID}`);
    };

    const handleKeyDown = (event: React.KeyboardEvent<HTMLDivElement>) => {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            handleEdit();
        }
    };

    return (
        
        <div
            className="relative event-box p-4 border rounded-lg shadow-md text-white overflow-hidden cursor-pointer"
            onClick={handleEdit}
            onKeyDown={handleKeyDown}
            role="button"
            tabIndex={0}
            style={{
                backgroundImage: `url(${eventVisualSrc})`,
                backgroundSize: 'cover',
                backgroundPosition: 'center',
                minHeight: '200px',
            }}
        >
            <div className="absolute inset-0 bg-black/20 rounded-lg pointer-events-none"></div>

            <div className="absolute top-2 right-2 flex max-w-[55%] flex-wrap justify-end gap-2">
                {event.eventCategories.map((category) => (
                    <span
                        key={category}
                        className="bg-red-600 text-white px-3 py-1 rounded-md text-sm"
                    >
                        {category}
                    </span>
                ))}
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
