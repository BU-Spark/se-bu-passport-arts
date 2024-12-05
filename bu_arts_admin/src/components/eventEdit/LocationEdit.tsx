import React, { useState, ChangeEvent } from 'react';
import { Event } from "../../interfaces/Event.tsx";

interface LocationEditProps {
    event: Event;
    setEvent: React.Dispatch<React.SetStateAction<Event | null>>;
    googleMapKey: string;
}

const LocationEdit: React.FC<LocationEditProps> = ({ event, setEvent, googleMapKey }) => {
    const [isEditing, setIsEditing] = useState(false);
    const [tempLocation, setTempLocation] = useState(event.eventLocation);

    const handleEditClick = () => {
        setIsEditing(true);
    };

    const handleLocationChange = (e: ChangeEvent<HTMLInputElement>) => {
        setTempLocation(e.target.value);
    };

    const handleSaveClick = () => {
        setIsEditing(false);
        setEvent((prevEvent) => prevEvent ? { ...prevEvent, eventLocation: tempLocation } : prevEvent);
    };

    const handleCancelClick = () => {
        setIsEditing(false);
        setTempLocation(event.eventLocation);
    };

    return (
        <div>
            <h3 className="text-gray-700 text-3xl font-semibold mb-2">Location:</h3>
            {isEditing ? (
                <div className="flex items-center mb-6">
                    <input
                        value={tempLocation}
                        onChange={handleLocationChange}
                        className="border-gray-500 p-2 focus:outline-none w-full"
                    />
                    <button onClick={handleSaveClick} className="text-green-500 p-1 ml-2">Save</button>
                    <button onClick={handleCancelClick} className="text-gray-500 p-1 ml-2">Cancel</button>
                </div>
            ) : (
                <div className="rounded overflow-hidden">
                    <iframe
                        width="100%"
                        height="200"
                        style={{ border: 0 }}
                        src={`https://www.google.com/maps/embed/v1/place?key=${googleMapKey}&q=${encodeURIComponent(event.eventLocation)}`}
                        allowFullScreen
                    ></iframe>
                    <div className="flex items-center mt-2">
                        <span className="font-semibold text-xl text-gray-700">Address:</span>
                        <span className="ml-2 text-gray-600">{event.eventLocation}</span>
                        <button onClick={handleEditClick} className="ml-2 text-red-500">
                            <img src="/public/icons/pen.png" alt="Edit" className="h-5 w-5" />
                        </button>
                    </div>
                </div>
            )}
        </div>
    );
};

export default LocationEdit;
