import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Event } from "../interfaces/Event";
import { fetchSingleEvent, fetchEventAttendanceWithProfiles } from '../firebase/firebaseService';
import { Attendance } from '../interfaces/Attendance';
import { User } from '../interfaces/User';
import { DateTime } from 'luxon';
import { FaArrowLeftLong } from "react-icons/fa6";

const googleMapKey = import.meta.env.VITE_GOOGLE_MAPS_API_KEY;


const PastEventViewPage: React.FC = () => {
  const { eventID } = useParams<{ eventID: string }>();
  const [event, setEvent] = useState<Event | null>(null);
  const [attendanceCount, setattendanceCount] = useState<number>(0);
  const [attendanceProfiles, setStudentProfiles] = useState<string[]>([]);
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
        const eventAttendanceWithProfiles = await fetchEventAttendanceWithProfiles(eventID);
        const attendances: Attendance[] = eventAttendanceWithProfiles.map((item) => item.attendance);
        const attendedStudents: User[] = eventAttendanceWithProfiles
          .map((item) => item.userProfile)
          .filter((profile): profile is User => profile !== null);
        if (data) {
          setEvent(data);
        } else {
          setError("No event found with the given ID");
        }
        if (attendances) {
          setattendanceCount(attendances.length);
          console.log("attendanceCount:", attendanceCount)
        }
        if (attendedStudents) {
          setStudentProfiles(attendedStudents.map((student) => student.userProfileURL));
          console.log("attendanceProfiles", attendanceProfiles)
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

  const handleAttendanceDetailClick = () => {
    navigate(`/events/${eventID}/attendance`);
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
                <div className="flex items-center mt-2">
                  <span className="font-semibold text-xl text-gray-700">Address:</span>
                  <span className="ml-2 text-gray-600">{event.eventLocation}</span>
                </div>
              </div>
            </div>
          </div>

          <div>
            <div className="mb-6">
              <div className="grid grid-cols-2 items-center">
                {/* Attendance Count */}
                <h3 className="text-gray-700 text-2xl font-semibold text-center">
                  {attendanceCount}/{attendanceCount} Attended
                </h3>

                {/* Profile Images */}
                <div className="flex items-center justify-start flex-wrap gap-4">
                  {attendanceProfiles.slice(0, 4).map((profile, index) => (
                    <div key={index} className="text-center">
                      <img
                        src={profile}
                        alt="profile"
                        className="w-12 h-12 rounded-full object-cover"
                      />
                    </div>
                  ))}

                  {/* Show "+N" if there are more profiles */}
                  {attendanceProfiles.length > 4 && (
                    <div className="text-center text-gray-700 text-lg font-semibold">
                      +{attendanceProfiles.length - 4}
                    </div>
                  )}
                </div>
              </div>

              {/* Button Centered */}
              <div className="mt-4 text-center">
                <button
                  onClick={handleAttendanceDetailClick}
                  className="bg-bured text-white text-xl px-8 py-3 rounded-full hover:bg-red-500 w-full md:w-auto"
                >
                  Details
                </button>
              </div>
            </div>



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
                <p className="font-semibold">Session: {session.sessionId}</p>
                <div className="mb-2">
                  <div className="flex items-center mt-1">
                    <span className="font-bold text-gray-700">Start Time:</span>
                    <span className="ml-2 text-gray-700">
                      {session.startTime
                        ? DateTime.fromJSDate(session.startTime.toDate())
                          .setZone('America/New_York')
                          .toFormat("yyyy-MM-dd' 'HH:mm")
                        : 'N/A'}
                    </span>
                  </div>
                  <div className="flex items-center mt-1">
                    <span className="font-bold text-gray-700">End Time:</span>
                    <span className="ml-2 text-gray-700">
                      {session.endTime
                        ? DateTime.fromJSDate(session.endTime.toDate())
                          .setZone('America/New_York')
                          .toFormat("yyyy-MM-dd' 'HH:mm")
                        : 'N/A'}
                    </span>
                  </div>
                </div>

              </div>
            ))}
        </div>
      </div>
    </div>
  );
};

export default PastEventViewPage;
