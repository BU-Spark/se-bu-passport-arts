import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Event } from "../interfaces/Event";
import { fetchSingleEvent, updateSingleEvent } from '../firebase/firebaseService';
import { DateTime } from 'luxon';
import { FaArrowLeftLong } from "react-icons/fa6";

const googleMapKey = import.meta.env.VITE_GOOGLE_MAPS_API_KEY;


const PastEventViewPage: React.FC = () => {
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
    navigate("/events/past");
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
          <h2 className="text-2xl font-bold text-bured">Past Event</h2>
        </div>
      </div>
      <div className="max-w-7xl mx-auto p-6 bg-white rounded shadow-md overflow-y-auto">

        {/* eventPhoto */}
        <div className="relative mb-6">
          <div className="relative w-full h-80">
            <img src={event.eventPhoto} alt="Event Preview" className="w-full h-full object-cover rounded" />
          </div>
        </div>

        {/* eventTitle */}
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center">
            <h2 className="text-3xl font-bold text-gray-800">{event.eventTitle}</h2>
          </div>
        </div>

        {/* eventCategories */}
        <div className="flex items-center space-x-2 mb-6">
          <div className="flex flex-wrap items-center space-x-2">
            {event.eventCategories.map((category, index) => (
              <div key={index} className="flex items-center space-x-2 mb-2">
                <span className="bg-red-500 text-white px-3 py-1 rounded-full text-sm font-semibold">{category}</span>
              </div>
            ))}
          </div>

        </div>

        <hr className="border-gray-400 mb-4" />

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            {/* eventPoint */}
            <div className="flex items-center mb-6">
              <img src="/public/icons/reward.png" alt="reward icon" className="h-16 mr-5" />
              <p className="text-gray-700 font-semibold text-4xl">Pts: {event.eventPoints}</p>
            </div>
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

          <div>
            {/* eventDescription */}
            <div className="mb-6">
              <div className="flex items-center justify-between mb-2">
                <h3 className="text-gray-700 text-3xl font-semibold">Description:</h3>
              </div>
              <p className="text-gray-700">{event.eventDescription}</p>
            </div>

            {/* eventURL */}
            <div className="flex items-center mb-6">
              <span className="font-semibold text-xl text-gray-700">Link:</span>
              <a href={event.eventURL} target="_blank" rel="noopener noreferrer" className="text-blue-500 underline ml-2">
                {event.eventURL}
              </a>
            </div>
          </div>
        </div>

        {/* Sessions */}
        <div className="mb-6 mt-4">
          <h3 className="text-gray-700 font-semibold mb-2 text-3xl">Sessions:</h3>
          {Object.entries(event.eventSessions)
            .filter(([_, session]) =>
              session.endTime && DateTime.fromJSDate(session.endTime.toDate()) <= DateTime.now()
            )
            .map(([sessionId, session]) => (
              <div key={sessionId} className="border border-gray-200 p-3 rounded mb-2">
                <p className="font-semibold">Session ID: {session.sessionId}</p>
                <div className="mb-2">
                  <label className="block text-gray-700 font-semibold">Start Time:</label>
                  <p className="w-full  p-2 rounded mt-1  text-gray-700">
                    {session.startTime
                      ? DateTime.fromJSDate(session.startTime.toDate())
                        .setZone('America/New_York')
                        .toFormat("yyyy-MM-dd' 'HH:mm")
                      : 'N/A'}
                  </p>
                  <label className="block text-gray-700 font-semibold">End Time:</label>
                  <p className="w-full p-2 rounded mt-1 text-gray-700">
                    {session.endTime
                      ? DateTime.fromJSDate(session.endTime.toDate())
                        .setZone('America/New_York')
                        .toFormat("yyyy-MM-dd' 'HH:mm")
                      : 'N/A'}
                  </p>
                </div>

              </div>
            ))}
        </div>
      </div>
    </div>
  );
};

export default PastEventViewPage;
