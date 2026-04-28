import { useNavigate } from 'react-router-dom';
import { Event } from "../interfaces/Event";

const EventBox = ({ event }: { event: Event }) => {
    const navigate = useNavigate();

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
            className="relative flex min-h-[200px] cursor-pointer flex-col rounded-lg border border-gray-200 bg-white p-4 text-sidebar-grey shadow-sm transition-shadow hover:shadow-md"
            onClick={handleEdit}
            onKeyDown={handleKeyDown}
            role="button"
            tabIndex={0}
        >
            <div className="absolute right-0 top-0 h-5 w-5 rounded-tr-lg border-r-4 border-t-4 border-black" />

            <div className="mb-4 flex flex-wrap gap-2">
                {event.eventCategories.map((category) => (
                    <span
                        key={category}
                        className="bg-red-600 text-white px-3 py-1 rounded-md text-sm"
                    >
                        {category}
                    </span>
                ))}
            </div>

            <div className="mt-auto">
                <h3 className="text-lg font-semibold">{event.eventTitle}</h3>
                <p className="text-sm">{event.eventLocation}</p>
            </div>
        </div>
    );
};

export default EventBox;
