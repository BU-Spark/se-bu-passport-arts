import React, { useState, ChangeEvent } from 'react';
import { Event } from "../../interfaces/Event.tsx";

interface DescriptionDisplayProps {
    event: Event;
    setEvent: React.Dispatch<React.SetStateAction<Event | null>>;
}

const DescriptionEdit: React.FC<DescriptionDisplayProps> = ({ event, setEvent }) => {
    const [isEditing, setIsEditing] = useState(false);
    const [tempDescription, setTempDescription] = useState(event.eventDescription);

    const handleEditClick = () => {
        setIsEditing(true);
    };

    const handleDescriptionChange = (e: ChangeEvent<HTMLTextAreaElement>) => {
        setTempDescription(e.target.value);
    };

    const handleSaveClick = () => {
        setIsEditing(false);
        setEvent((prevEvent) => prevEvent ? { ...prevEvent, eventDescription: tempDescription } : prevEvent);
    };

    const handleCancelClick = () => {
        setIsEditing(false);
        setTempDescription(event.eventDescription); // Reset to original description if canceled
    };

    return (
        <div className="mb-6">
            <div className="flex items-center justify-between mb-2">
                <h3 className="text-gray-700 text-3xl font-semibold">Description:</h3>
                <button onClick={handleEditClick} className="ml-2 text-red-500">
                    <img src="/public/icons/pen.png" alt="Edit" className="h-5 w-5" />
                </button>
            </div>
            {isEditing ? (
                <div>
                    <textarea
                        value={tempDescription}
                        onChange={handleDescriptionChange}
                        className="w-full border border-gray-300 p-2 rounded mt-1 resize-none h-40 focus:outline-none focus:ring focus:ring-indigo-300"
                        placeholder="Enter the event description here..."
                    />
                    <div className="flex mt-2">
                        <button onClick={handleSaveClick} className="text-green-500 p-1">Save</button>
                        <button onClick={handleCancelClick} className="text-gray-500 p-1 ml-2">Cancel</button>
                    </div>
                </div>
            ) : (
                <p className="text-gray-700">{event.eventDescription}</p>
            )}
        </div>
    );
};

export default DescriptionEdit;
