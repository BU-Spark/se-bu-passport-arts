import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Event } from "../interfaces/Event";
import { fetchSingleEvent, updateSingleEvent } from '../firebase/firebaseService';
import { DateTime } from 'luxon';

import TitleEdit from '../components/eventEdit/TitleEdit.tsx'
import CategoryEdit from '../components/eventEdit/CategoryEdit.tsx'
import PointEdit from '../components/eventEdit/PointEdit.tsx'
// import { APIProvider } from '@vis.gl/react-google-maps';
// import { Map, Marker } from "@vis.gl/react-google-maps";

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

  const handleSave = async () => {
    if (event && eventID) {
      try {
        const success = await updateSingleEvent(event);
        if (success) {
          navigate("/"); // Redirect after save
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
    <div className="max-w-7xl mx-auto p-6 bg-white rounded shadow-md overflow-y-auto">
      {/* Header Section with Event Image */}
      {event.eventPhoto && (
        <div className="relative mb-6">
          <img src={event.eventPhoto} alt="Event Preview" className="w-full h-72 object-cover rounded" />
          <button className="absolute top-3 right-3 bg-red-500 text-white p-2 rounded-full">✎</button>
        </div>
      )}

      <TitleEdit event={event} setEvent={setEvent}></TitleEdit>
      <CategoryEdit event={event} setEvent={setEvent}></CategoryEdit>

      <hr className="border-gray-400 mb-4" />

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* First Column: Points Section */}
        <div>
          <PointEdit event={event} setEvent={setEvent}></PointEdit>

          <hr className="border-gray-400 mb-4" />

          {/* Location Section */}
          <div>
            <h3 className="text-gray-700 text-3xl font-semibold mb-2">Location:</h3>
            <div className="rounded overflow-hidden">
              <iframe
                width="100%"
                height="200"
                style={{ border: 0 }}
                src={`https://www.google.com/maps/embed/v1/place?key=${googleMapKey}&q=${encodeURIComponent(event.eventLocation)}`}
                allowFullScreen
              ></iframe>
            </div>
          </div>
        </div>

        {/* Second Column: Description and Link */}
        <div>
          {/* Description Section */}
          <h3 className="text-gray-700 text-3xl font-semibold mb-2">Description:</h3>
          <textarea
            className="w-full border border-gray-300 p-2 rounded mt-1 resize-none h-40"
            value={event.eventDescription}
            onChange={(e) => setEvent({ ...event, eventDescription: e.target.value })}
            placeholder="Enter the event description here..."
          />

          {/* Link Section */}
          <div className="mt-4">
            <span className="font-semibold text-xl text-gray-700">Link:</span>
            <a href={event.eventURL} target="_blank" rel="noopener noreferrer" className="text-blue-500 underline ml-2">
              {event.eventURL}
            </a>
          </div>
        </div>
      </div>

      {/* Sessions */}
      <div className="mb-6">
        <h3 className="text-gray-700 font-semibold mb-2">Sessions:</h3>
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
      {/* Save and Cancel Buttons */}
      <div className="flex justify-end space-x-3">
        <button
          onClick={() => navigate("/events")}
          className="px-4 py-2 bg-gray-300 text-gray-700 rounded hover:bg-gray-400 transition-colors duration-200"
        >
          Cancel
        </button>
        <button
          onClick={handleSave}
          className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition-colors duration-200 flex items-center space-x-1"
        >
          <span>Save</span>
          <span>💾</span>
        </button>
      </div>
    </div>
  );
};

export default EditEvent;
