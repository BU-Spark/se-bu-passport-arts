import React, { useState, ChangeEvent } from 'react';
import { Event } from "../../interfaces/Event.tsx";

interface PhotoDisplayProps {
    event: Event;
    setEvent: React.Dispatch<React.SetStateAction<Event | null>>;
}

const PhotoEdit: React.FC<PhotoDisplayProps> = ({ event, setEvent }) => {
    const [isEditing, setIsEditing] = useState(false);
    const [tempPhoto, setTempPhoto] = useState(event.eventPhoto);

    const handleEditClick = () => {
        setIsEditing(true);
    };

    const handlePhotoChange = (e: ChangeEvent<HTMLInputElement>) => {
        setTempPhoto(e.target.value);
    };

    const handleSaveClick = () => {
        setIsEditing(false);
        setEvent((prevEvent) => prevEvent ? { ...prevEvent, eventPhoto: tempPhoto } : prevEvent);
    };

    const handleCancelClick = () => {
        setIsEditing(false);
        setTempPhoto(event.eventPhoto); // Reset to original photo URL if canceled
    };

    return (
        <div className="relative mb-6">
            <div className="relative w-full h-80">
                <img src={event.eventPhoto} alt="Event Preview" className="w-full h-full object-cover rounded" />
                <button 
                    onClick={handleEditClick} 
                    className="absolute top-4 right-4"
                >
                    <img src="/public/icons/pen.png" alt="Edit" className="h-5 w-5" />
                </button>
            </div>

            {isEditing && (
                <div className="flex items-center mt-4">
                    <input
                        type="text"
                        value={tempPhoto}
                        onChange={handlePhotoChange}
                        placeholder="Enter image URL"
                        className="w-full p-2 border rounded focus:outline-none focus:ring focus:ring-indigo-300"
                    />
                    <button onClick={handleSaveClick} className="ml-2 text-green-500 p-2">Save</button>
                    <button onClick={handleCancelClick} className="ml-2 text-gray-500 p-2">Cancel</button>
                </div>
            )}
        </div>
    );
};

export default PhotoEdit;
