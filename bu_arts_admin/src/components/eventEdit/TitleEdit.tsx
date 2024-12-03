import React, { useState, ChangeEvent } from 'react';
import { Event } from "../../interfaces/Event.tsx";

interface EventTitleProps {
  event: Event;
  setEvent: React.Dispatch<React.SetStateAction<Event | null>>;
}

const TitleEdit: React.FC<EventTitleProps> = ({ event, setEvent }) => {
  const [isEditing, setIsEditing] = useState(false);
  const [tempTitle, setTempTitle] = useState(event.eventTitle);

  const handleEditClick = () => {
    setIsEditing(true);
  };

  const handleTitleChange = (e: ChangeEvent<HTMLInputElement>) => {
    setTempTitle(e.target.value);
  };

  const handleSave = () => {
    setIsEditing(false);
    setEvent((prevEvent) => prevEvent ? { ...prevEvent, eventTitle: tempTitle } : prevEvent);
  };

  const handleCancel = () => {
    setIsEditing(false);
    setTempTitle(event.eventTitle); // Reset to original title
  };

  return (
    <div className="flex items-center justify-between mb-4">
      <div className="flex items-center">
        {isEditing ? (
          <>
            <input
              type="text"
              value={tempTitle}
              onChange={handleTitleChange}
              style={{ width: "1000px" }} 
              autoFocus
              className="text-3xl font-bold text-gray-800 border-b-2 border-gray-300 focus:outline-none"
            />
            <button onClick={handleSave} className="text-green-500 p-1 ml-2">
              Save
            </button>
            <button onClick={handleCancel} className="text-gray-500 p-1 ml-2">
              Cancel
            </button>
          </>
        ) : (
          <>
            <h2 className="text-3xl font-bold text-gray-800">{event.eventTitle}</h2>
            <button onClick={handleEditClick} className="text-red-500 p-2 rounded-full ml-2">
              <img src="/public/icons/pen.png" alt="Edit" className="h-5 w-5" />
            </button>
          </>
        )}
      </div>
    </div>
  );
};

export default TitleEdit;
