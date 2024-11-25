import React, { useState, ChangeEvent } from 'react';
import { Event } from "../../interfaces/Event.tsx";

interface URLDisplayProps {
    event: Event;
    setEvent: React.Dispatch<React.SetStateAction<Event | null>>;
}

const URLEdit: React.FC<URLDisplayProps> = ({ event, setEvent }) => {
    const [isEditing, setIsEditing] = useState(false);
    const [tempURL, setTempURL] = useState(event.eventURL);

    const handleEditClick = () => {
        setIsEditing(true);
    };

    const handleURLChange = (e: ChangeEvent<HTMLInputElement>) => {
        setTempURL(e.target.value);
    };

    const handleSaveClick = () => {
        setIsEditing(false);
        setEvent((prevURL) => prevURL ? { ...prevURL, eventURL: tempURL } : prevURL);
    };

    const handleCancelClick = () => {
        setIsEditing(false);
        setTempURL(event.eventURL);
    };

    return (
        <div className="flex flex-wrap items-center mb-6">
  {isEditing ? (
    <>
      <input
        value={tempURL}
        onChange={handleURLChange}
        className="border-gray-500 p-2 focus:outline-none w-full"
      />
      <button onClick={handleSaveClick} className="text-green-500 p-1 ml-2">Save</button>
      <button onClick={handleCancelClick} className="text-gray-500 p-1 ml-2">Cancel</button>
    </>
  ) : (
    <>
      <span className="font-semibold text-xl text-gray-700">Link:</span>
      <a
        href={event.eventURL}
        target="_blank"
        rel="noopener noreferrer"
        className="text-blue-500 underline ml-2 break-words max-w-full"
      >
        {event.eventURL}
      </a>
      <button onClick={handleEditClick} className="ml-2 text-red-500 flex-shrink-0">
        <img src="/public/icons/pen.png" alt="Edit" className="h-5 w-5" />
      </button>
    </>
  )}
</div>


    );
};

export default URLEdit;
