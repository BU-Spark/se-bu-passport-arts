import React, { useState, ChangeEvent } from 'react';
import { Event } from "../../interfaces/Event.tsx";

interface PointsDisplayProps {
    event: Event;
    setEvent: React.Dispatch<React.SetStateAction<Event | null>>;
}

const PointsEdit: React.FC<PointsDisplayProps> = ({ event, setEvent }) => {
    const [isEditing, setIsEditing] = useState(false);
    const [tempPoints, setTempPoints] = useState(event.eventPoints);

    const handleEditClick = () => {
        setIsEditing(true);
    };

    const handlePointsChange = (e: ChangeEvent<HTMLInputElement>) => {
        setTempPoints(Number(e.target.value));
    };

    const handleSaveClick = () => {
        setIsEditing(false);
        setEvent((prevPoints) => prevPoints ? { ...prevPoints, eventPoints: tempPoints } : prevPoints);
    };

    const handleCancelClick = () => {
        setIsEditing(false);
        setTempPoints(event.eventPoints); // Reset to original points if canceled
    };

    return (
        <div className="flex items-center mb-6">
            <img src="/public/icons/reward.png" alt="reward icon" className="h-16 mr-5" />
            {isEditing ? (
                <>
                    <input
                        type="number"
                        value={tempPoints}
                        onChange={handlePointsChange}
                        className="text-4xl font-semibold text-gray-700 border-b-2 border-gray-300 focus:outline-none"
                    />
                    <button onClick={handleSaveClick} className="text-green-500 p-1 ml-2">Save</button>
                    <button onClick={handleCancelClick} className="text-gray-500 p-1 ml-2">Cancel</button>
                </>
            ) : (
                <>
                    <p className="text-gray-700 font-semibold text-4xl">Pts: {event.eventPoints}</p>
                    <button onClick={handleEditClick} className="ml-2 text-red-500">
                        <img src="/public/icons/pen.png" alt="Edit" className="h-5 w-5" />
                    </button>
                </>
            )}
        </div>
    );
};

export default PointsEdit;
