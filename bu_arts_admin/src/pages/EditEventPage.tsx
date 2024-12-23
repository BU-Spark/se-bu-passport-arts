import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { DateTime } from 'luxon';
import { fetchSingleEvent, updateSingleEvent } from '../firebase/firebaseService';
import { FaArrowLeftLong } from "react-icons/fa6";

import { Event } from "../interfaces/Event";
import TitleEdit from '../components/eventEdit/TitleEdit.tsx'
import CategoryEdit from '../components/eventEdit/CategoryEdit.tsx'
import PointEdit from '../components/eventEdit/PointEdit.tsx'
import PhotoEdit from '../components/eventEdit/PhotoEdit.tsx';
import DescriptionEdit from '../components/eventEdit/DescriptionEdit.tsx';
import URLEdit from '../components/eventEdit/LinkEdit.tsx';
import LocationEdit from '../components/eventEdit/LocationEdit.tsx';

const googleMapKey = import.meta.env.VITE_GOOGLE_MAPS_API_KEY;


const EditEvent: React.FC = () => {
  const { eventID } = useParams<{ eventID: string }>();
  const [event, setEvent] = useState<Event | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchEvent = async () => {
      if (!eventID) {
        setError("Event ID is missing.");
        setLoading(false);
        return;
      }
      try {
        const data = await fetchSingleEvent(eventID);
        if (data) {
          setEvent(data);
        } else {
          setError("No event found with the given ID");
        }
      } catch (err) {
        setError("Failed to load event details.");
      } finally {
        setLoading(false);
      }
    };
    fetchEvent();
  }, [eventID]);

  const handleArrowClick = () => {
    navigate("/events/upcoming");
  };

  const handleSave = async () => {
    if (event && eventID) {
      try {
        const success = await updateSingleEvent(event);
        if (success) {
          navigate("/events/upcoming"); // Redirect after save
        }
      } catch (error) {
        console.error("Error saving event:", error);
      }
    }
  };

  if (loading) return <p>Loading...</p>;
  if (error) return <p>{error}</p>;
  if (!event) return <p>Event not found</p>;


  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center">
          <FaArrowLeftLong
            style={{ fontSize: "2rem", strokeWidth: "2" }}
            className="text-bured mr-4 cursor-pointer hover:text-red-900"
            onClick={handleArrowClick}
          />
          <h2 className="text-2xl font-bold text-bured">Upcoming Events</h2>
        </div>
      </div>
      <div className="max-w-7xl mx-auto p-6 bg-white rounded shadow-md overflow-y-auto">
        <PhotoEdit event={event} setEvent={setEvent}></PhotoEdit>
        <TitleEdit event={event} setEvent={setEvent}></TitleEdit>
        <CategoryEdit event={event} setEvent={setEvent}></CategoryEdit>

        <hr className="border-gray-400 mb-4" />

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <PointEdit event={event} setEvent={setEvent}></PointEdit>
            <hr className="border-gray-400 mb-4" />
            <LocationEdit event={event} setEvent={setEvent} googleMapKey={googleMapKey}></LocationEdit>
          </div>

          <div>
            <DescriptionEdit event={event} setEvent={setEvent}></DescriptionEdit>
            <URLEdit event={event} setEvent={setEvent}></URLEdit>
          </div>
        </div>

        {/* Sessions */}
        <div className="mb-6">
          <h3 className="text-gray-700 font-semibold mb-2 text-3xl">Sessions:</h3>
          {Object.entries(event.eventSessions).map(([sessionId, session]) => (
            <div key={sessionId} className="border border-gray-200 p-3 rounded mb-2">
              <p className="font-semibold">Session ID: {session.sessionId}</p>
              <div className="mb-2">
                <label className="block text-gray-700">Start Time</label>
                <input
                  type="datetime-local"
                  className="w-full border border-gray-300 p-2 rounded mt-1"
                  value={
                    session.startTime
                      ? DateTime.fromJSDate(session.startTime.toDate())
                        .setZone('America/New_York')
                        .toFormat("yyyy-MM-dd'T'HH:mm")
                      : ''
                  }
                />
                <label className="block text-gray-700">End Time</label>
                <input
                  type="datetime-local"
                  className="w-full border border-gray-300 p-2 rounded mt-1"
                  value={
                    session.endTime
                      ? DateTime.fromJSDate(session.endTime.toDate())
                        .setZone('America/New_York')
                        .toFormat("yyyy-MM-dd'T'HH:mm")
                      : ''
                  }
                />
              </div>
            </div>
          ))}
        </div>

        {/* Save and Cancel Buttons */}
        <div className="flex justify-end space-x-3">
          <button
            onClick={() => navigate("/events/upcoming")}
            className="px-4 py-2 bg-gray-300 text-gray-700 rounded-full hover:bg-gray-400 transition-colors duration-200"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            className="px-5 py-2 bg-red-600 text-white rounded-full hover:bg-red-700 transition-colors duration-200 flex items-center space-x-2"
          >
            <span>Save</span>
            <span>
              <img className="w-5" src="/public/icons/save.png" alt="save" />
            </span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default EditEvent;
