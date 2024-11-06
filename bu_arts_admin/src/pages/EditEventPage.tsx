import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Event } from "../interfaces/Event";
import { fetchSingleEvent, updateSingleEvent } from '../firebase/firebaseService';
import { DateTime } from 'luxon';
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
    <div className="max-w-4xl mx-auto p-6 bg-white rounded shadow-md overflow-y-auto">
      {/* Header Section with Event Image */}
      {event.eventPhoto && (
        <div className="relative mb-6">
          <img src={event.eventPhoto} alt="Event Preview" className="w-full h-72 object-cover rounded" />
          <button className="absolute top-3 right-3 bg-red-500 text-white p-2 rounded-full">✎</button>
        </div>
      )}

      {/* Event Title and Edit Icon */}
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-3xl font-bold text-gray-800">{event.eventTitle}</h2>
        <button className="text-red-500 p-2 rounded-full">✎</button>
      </div>

      {/* Date and Categories */}
      <div className="flex items-center mb-6">
        <p className="text-gray-600 font-semibold mr-2">Date:</p>
        <span className="text-gray-700">{new Date(event.eventStartDate).toLocaleDateString()} - {new Date(event.eventEndDate).toLocaleDateString()}</span>
        <button className="ml-2 text-red-500">✎</button>
      </div>
      <div className="flex space-x-2 mb-6">
        {event.eventCategories.map((category, index) => (
          <span key={index} className="bg-red-500 text-white px-3 py-1 rounded-full text-sm font-semibold">{category}</span>
        ))}
      </div>

      {/* Points Section */}
      <div className="flex items-center mb-6">
        <span className="text-red-500 text-2xl mr-2">🏅</span>
        <p className="text-gray-700 font-semibold">Pts: {event.eventPoints}</p>
        <button className="ml-2 text-red-500">✎</button>
      </div>

      {/* Location and Description */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        {/* Location Section on the Left */}
        <div>
          <h3 className="text-gray-700 font-semibold mb-2">Location:</h3>
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

        {/* Description Section on the Right */}
        <div>
          <h3 className="text-gray-700 font-semibold mb-2">Description:</h3>
          <textarea
            className="w-full border border-gray-300 p-2 rounded mt-1 resize-none h-40"
            value={event.eventDescription}
            onChange={(e) => setEvent({ ...event, eventDescription: e.target.value })}
            placeholder="Enter the event description here..."
          />
        </div>
      </div>
      

      {/* Hours and Link */}
      {/* <div className="flex items-center justify-between mb-4">
        <p className="text-gray-600"><span className="font-semibold">Hours:</span> 11:00am - 5:00pm</p>
        <button className="text-red-500">✎</button>
      </div> */}
      <div className="mb-6">
        <span className="font-semibold text-gray-700">Link:</span> <a href={event.eventURL} target="_blank" rel="noopener noreferrer" className="text-blue-500 underline">{event.eventURL}</a>
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
      <div className="flex justify-end space-x-3">
        <button
          onClick={() => navigate("/")}
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
