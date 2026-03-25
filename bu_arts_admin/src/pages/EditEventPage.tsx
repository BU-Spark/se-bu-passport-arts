import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { DateTime } from 'luxon';
import { FaArrowLeftLong } from "react-icons/fa6";
import { fetchSingleBuEvent } from '../services/buEventsService';

import { Event } from "../interfaces/Event";
import { googleMapKey } from '../config';


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
        const data = await fetchSingleBuEvent(eventID);
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

  if (loading) return <p>Loading...</p>;
  if (error) return <p>{error}</p>;
  if (!event) return <p>Event not found</p>;

  const sessions = Object.values(event.eventSessions).sort(
    (left, right) => left.startTime.getTime() - right.startTime.getTime()
  );

  return (
    <div className="max-w-7xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center">
          <FaArrowLeftLong
            style={{ fontSize: "2rem", strokeWidth: "2" }}
            className="text-bured mr-4 cursor-pointer hover:text-red-900"
            onClick={handleArrowClick}
          />
          <div>
            <h2 className="text-2xl font-bold text-bured">Event Details</h2>
            <p className="text-sm text-gray-500">Read-only preview from the BU events API.</p>
          </div>
        </div>
      </div>

      <div className="rounded-2xl bg-white p-6 shadow-md">
        <div className="mb-6 rounded-xl border border-gray-200 bg-gray-50 p-4 text-sm text-gray-600">
          Events now load directly from the BU events API. Editing is disabled in the admin.
        </div>

        <div className="mb-6">
          <h1 className="mb-4 text-4xl font-bold text-sidebar-grey">{event.eventTitle}</h1>
          <div className="flex flex-wrap gap-2">
            {event.eventCategories.map((category) => (
              <span
                key={category}
                className="rounded-full bg-red-50 px-3 py-1 text-sm font-semibold text-bured"
              >
                {category}
              </span>
            ))}
          </div>
        </div>

        <div className="mb-8 grid grid-cols-1 gap-4 md:grid-cols-3">
          <div className="rounded-xl border border-gray-200 p-4">
            <p className="mb-1 text-sm font-medium text-gray-500">Points</p>
            <p className="text-3xl font-bold text-sidebar-grey">{event.eventPoints}</p>
          </div>
          <div className="rounded-xl border border-gray-200 p-4 md:col-span-2">
            <p className="mb-1 text-sm font-medium text-gray-500">Location</p>
            <p className="text-lg font-semibold text-sidebar-grey">{event.eventLocation}</p>
          </div>
        </div>

        <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
          <div>
            <h3 className="mb-3 text-2xl font-semibold text-sidebar-grey">Description</h3>
            <div className="rounded-xl border border-gray-200 p-4">
              <p className="leading-7 text-gray-600">{event.eventDescription}</p>
            </div>

            <div className="mt-6">
              <h3 className="mb-3 text-2xl font-semibold text-sidebar-grey">Event Link</h3>
              <div className="rounded-xl border border-gray-200 p-4">
                {event.eventURL ? (
                  <a
                    href={event.eventURL}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="break-words text-blue-600 underline"
                  >
                    {event.eventURL}
                  </a>
                ) : (
                  <p className="text-gray-500">No external link available.</p>
                )}
              </div>
            </div>
          </div>

          <div>
            <h3 className="mb-3 text-2xl font-semibold text-sidebar-grey">Location</h3>
            <div className="overflow-hidden rounded-xl border border-gray-200">
              <iframe
                width="100%"
                height="260"
                style={{ border: 0 }}
                src={`https://www.google.com/maps/embed/v1/place?key=${googleMapKey}&q=${encodeURIComponent(event.eventLocation)}`}
                allowFullScreen
              ></iframe>
            </div>
          </div>
        </div>

        <div className="mt-8">
          <h3 className="mb-4 text-2xl font-semibold text-sidebar-grey">Sessions</h3>
          <div className="space-y-4">
            {sessions.map((session) => (
              <div key={session.sessionId} className="rounded-xl border border-gray-200 p-4">
                <p className="mb-3 text-sm font-semibold uppercase tracking-wide text-gray-500">
                  Session ID: {session.sessionId}
                </p>
                <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                  <div>
                    <p className="mb-1 text-sm font-medium text-gray-500">Start</p>
                    <p className="text-lg font-semibold text-sidebar-grey">
                      {DateTime.fromJSDate(session.startTime)
                        .setZone('America/New_York')
                        .toFormat("MM/dd/yyyy, hh:mm a")}
                    </p>
                  </div>
                  <div>
                    <p className="mb-1 text-sm font-medium text-gray-500">End</p>
                    <p className="text-lg font-semibold text-sidebar-grey">
                      {DateTime.fromJSDate(session.endTime)
                        .setZone('America/New_York')
                        .toFormat("MM/dd/yyyy, hh:mm a")}
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="mt-8 flex justify-end">
          <button
            onClick={() => navigate("/events/upcoming")}
            className="rounded-full bg-bured px-5 py-2 text-white transition-colors duration-200 hover:bg-red-700"
          >
            Back to events
          </button>
        </div>
      </div>
    </div>
  );
};

export default EditEvent;
