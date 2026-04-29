import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { DateTime } from 'luxon';
import { FaArrowLeftLong } from "react-icons/fa6";
import { fetchAllUsers, fetchEventAttendanceWithProfiles, updateEventPoints } from '../firebase/firebaseService';
import { clearBuEventsCache, fetchSingleBuEvent } from '../services/buEventsService';

import { Event } from "../interfaces/Event";
import { User } from "../interfaces/User";
import { googleMapKey } from '../config';


const EditEvent: React.FC = () => {
  const { eventID } = useParams<{ eventID: string }>();
  const [event, setEvent] = useState<Event | null>(null);
  const [savedStudents, setSavedStudents] = useState<User[]>([]);
  const [registeredStudents, setRegisteredStudents] = useState<User[]>([]);
  const [isEditingPoints, setIsEditingPoints] = useState(false);
  const [tempPoints, setTempPoints] = useState('');
  const [isSavingPoints, setIsSavingPoints] = useState(false);
  const [pointsError, setPointsError] = useState<string | null>(null);
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
        const [data, registrations, users] = await Promise.all([
          fetchSingleBuEvent(eventID),
          fetchEventAttendanceWithProfiles(eventID),
          fetchAllUsers(),
        ]);
        if (data) {
          setEvent(data);
          setTempPoints(String(data.eventPoints));

          const matchingSavedUsers = users.filter((user) => {
            const savedEvents =
              user.userSavedEvents instanceof Map
                ? Array.from(user.userSavedEvents.keys())
                : Object.keys((user.userSavedEvents as Record<string, unknown>) || {});

            return savedEvents.includes(data.eventID);
          });

          setSavedStudents(matchingSavedUsers);
        } else {
          setError("No event found with the given ID");
        }

        const uniqueUserIds = new Set<string>();
        const uniqueStudents: User[] = [];

        registrations.forEach(({ attendance, userProfile }) => {
          const userId = userProfile?.userUID ?? attendance.userID;

          if (uniqueUserIds.has(userId)) {
            return;
          }

          uniqueUserIds.add(userId);

          if (userProfile) {
            uniqueStudents.push(userProfile);
          }
        });

        setRegisteredStudents(uniqueStudents);
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

  const handleEditPointsClick = () => {
    if (!event) {
      return;
    }

    setPointsError(null);
    setTempPoints(String(event.eventPoints));
    setIsEditingPoints(true);
  };

  const handleCancelPointsClick = () => {
    if (event) {
      setTempPoints(String(event.eventPoints));
    }
    setPointsError(null);
    setIsEditingPoints(false);
  };

  const handleSavePointsClick = async () => {
    if (!event) {
      return;
    }

    const nextPoints = Number(tempPoints);

    if (!Number.isFinite(nextPoints) || nextPoints < 0) {
      setPointsError('Points must be a non-negative number.');
      return;
    }

    try {
      setIsSavingPoints(true);
      setPointsError(null);
      await updateEventPoints(event.eventID, event.eventPoints, Math.round(nextPoints));
      clearBuEventsCache();
      setEvent((previousEvent) =>
        previousEvent
          ? { ...previousEvent, eventPoints: Math.round(nextPoints) }
          : previousEvent,
      );
      setTempPoints(String(Math.round(nextPoints)));
      setIsEditingPoints(false);
    } catch (saveError) {
      setPointsError('Failed to update event points.');
    } finally {
      setIsSavingPoints(false);
    }
  };

  if (loading) return <p>Loading...</p>;
  if (error) return <p>{error}</p>;
  if (!event) return <p>Event not found</p>;

  const sessions = Object.values(event.eventSessions).sort(
    (left, right) => left.startTime.getTime() - right.startTime.getTime()
  );

  const formatSessionDate = (date: Date) =>
    DateTime.fromJSDate(date)
      .setZone('America/New_York')
      .toFormat('ccc, LLL d, yyyy');

  const formatSessionTime = (date: Date) =>
    DateTime.fromJSDate(date)
      .setZone('America/New_York')
      .toFormat('h:mm a');

  const renderStudentTable = (students: User[], emptyMessage: string) => (
    <div className="overflow-hidden rounded-[28px] border border-gray-200 bg-white shadow-sm">
      <div className="overflow-x-auto">
        <table className="min-w-full">
          <thead className="bg-gray-100 text-left">
            <tr>
              <th className="px-4 py-3 text-base font-semibold text-sidebar-grey">#</th>
              <th className="px-4 py-3 text-base font-semibold text-sidebar-grey">Student</th>
              <th className="px-4 py-3 text-base font-semibold text-sidebar-grey">BUID</th>
            </tr>
          </thead>
          <tbody>
            {students.length > 0 ? (
              students.map((student, index) => (
                <tr
                  key={student.userUID}
                  className={index % 2 === 0 ? 'bg-white' : 'bg-gray-50/70'}
                >
                  <td className="whitespace-nowrap px-4 py-4 text-base font-medium text-sidebar-grey">
                    {index + 1}
                  </td>
                  <td className="px-4 py-4 text-base font-medium text-sidebar-grey">
                    {student.firstName} {student.lastName}
                  </td>
                  <td className="whitespace-nowrap px-4 py-4 text-base font-medium text-sidebar-grey">
                    {student.userBUID}
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={3} className="px-4 py-6 text-base text-gray-500">
                  {emptyMessage}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
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
          </div>
        </div>
      </div>

      <div className="rounded-2xl bg-white p-6 shadow-md">

        <div className="mb-6">
          <div className="mb-4 flex flex-wrap items-center gap-3">
            <h1 className="text-4xl font-bold text-sidebar-grey">{event.eventTitle}</h1>
            {event.eventURL && (
              <a
                href={event.eventURL}
                target="_blank"
                rel="noopener noreferrer"
                className="max-w-full truncate rounded-full bg-red-50 px-3 py-1 text-sm font-semibold text-bured transition-colors duration-200 hover:bg-red-100"
              >
                {event.eventURL}
              </a>
            )}
          </div>
          <div className="flex flex-wrap gap-2">
            {event.eventCategories.map((category) => (
              <span
                key={category}
                className="rounded-full bg-bured px-3 py-1 text-sm font-semibold text-red-50"
              >
                {category}
              </span>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
          <div>
            <h3 className="mb-4 text-2xl font-semibold text-sidebar-grey">Description</h3>
            <div className="rounded-xl border border-gray-200 p-4">
              <p className="leading-7 text-gray-600">{event.eventDescription}</p>
            </div>

            <div className="mt-8">
              <div className="flex items-center justify-between gap-4">
                <h3 className="text-2xl font-semibold text-sidebar-grey">Points</h3>
                {!isEditingPoints && (
                  <button
                    onClick={handleEditPointsClick}
                    className="rounded-full bg-bured px-5 py-2 text-sm font-semibold text-white transition-colors hover:bg-red-700"
                  >
                    Edit Points
                  </button>
                )}
              </div>
              <div className="mt-4 rounded-xl border border-gray-200 p-4">
                {isEditingPoints ? (
                  <div className="space-y-3">
                    <input
                      type="number"
                      min="0"
                      value={tempPoints}
                      onChange={(inputEvent) => setTempPoints(inputEvent.target.value)}
                      className="w-full rounded-lg border border-gray-300 px-3 py-2 text-3xl font-bold text-sidebar-grey focus:border-bured focus:outline-none"
                    />
                    <div className="flex gap-3">
                      <button
                        onClick={handleSavePointsClick}
                        disabled={isSavingPoints}
                        className="rounded-full bg-bured px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-red-700 disabled:cursor-not-allowed disabled:bg-red-300"
                      >
                        {isSavingPoints ? 'Saving...' : 'Save'}
                      </button>
                      <button
                        onClick={handleCancelPointsClick}
                        disabled={isSavingPoints}
                        className="rounded-full border border-gray-300 px-4 py-2 text-sm font-semibold text-sidebar-grey transition-colors hover:bg-gray-50 disabled:cursor-not-allowed"
                      >
                        Cancel
                      </button>
                    </div>
                    {pointsError && (
                      <p className="text-sm text-bured">{pointsError}</p>
                    )}
                  </div>
                ) : (
                  <p className="text-3xl font-bold text-sidebar-grey">{event.eventPoints}</p>
                )}
              </div>
            </div>
          </div>

          <div>
            <h3 className="mb-4 text-2xl font-semibold text-sidebar-grey">Location</h3>
            <div className="relative overflow-hidden rounded-xl border border-gray-200">
              <iframe
                width="100%"
                height="260"
                style={{ border: 0 }}
                src={`https://www.google.com/maps/embed/v1/place?key=${googleMapKey}&q=${encodeURIComponent(event.eventLocation)}`}
                allowFullScreen
              ></iframe>
              <p className="absolute right-4 top-4 max-w-[70%] rounded-lg bg-white/90 px-3 py-2 text-right leading-7 text-gray-600 shadow-sm backdrop-blur-sm">
                {event.eventLocation}
              </p>
            </div>
          </div>
        </div>

        <div className="mt-8 grid grid-cols-1 gap-8 xl:grid-cols-2">
          <div>
            <h3 className="mb-4 text-2xl font-semibold text-sidebar-grey">Schedule</h3>
            <div className="overflow-hidden rounded-[28px] border border-gray-200 bg-white shadow-sm">
              <div className="overflow-x-auto">
                <table className="min-w-full">
                  <thead className="bg-gray-100 text-left">
                    <tr>
                      <th className="px-4 py-3 text-base font-semibold text-sidebar-grey">Date</th>
                      <th className="px-4 py-3 text-base font-semibold text-sidebar-grey">Start</th>
                      <th className="px-4 py-3 text-base font-semibold text-sidebar-grey">End</th>
                    </tr>
                  </thead>
                  <tbody>
                    {sessions.map((session, index) => (
                      <tr
                        key={session.sessionId}
                        className={index % 2 === 0 ? 'bg-white' : 'bg-gray-50/70'}
                      >
                        <td className="whitespace-nowrap px-4 py-4 text-base font-medium leading-tight text-sidebar-grey">
                          {formatSessionDate(session.startTime)}
                        </td>
                        <td className="whitespace-nowrap px-4 py-4 text-base font-medium text-sidebar-grey">
                          {formatSessionTime(session.startTime)}
                        </td>
                        <td className="whitespace-nowrap px-4 py-4 text-base font-medium text-sidebar-grey">
                          {formatSessionTime(session.endTime)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <div>
            <div className="space-y-8">
              <div>
                <h3 className="mb-4 text-2xl font-semibold text-sidebar-grey">Saved</h3>
                {renderStudentTable(savedStudents, 'No students saved this event yet.')}
              </div>

              <div>
                <h3 className="mb-4 text-2xl font-semibold text-sidebar-grey">Attendees</h3>
                {renderStudentTable(registeredStudents, 'No students attended yet.')}
              </div>
            </div>
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
