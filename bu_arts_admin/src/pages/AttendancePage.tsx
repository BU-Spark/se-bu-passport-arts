import { useState, useEffect } from "react";
import { useParams, useNavigate } from 'react-router-dom';
import { User } from "../interfaces/User";
import AttendanceTable from "../components/passtEvent/AttendanceTable";
import { FaArrowLeftLong } from "react-icons/fa6";
import { fetchEventAttendanceWithProfiles, fetchEventName } from "../firebase/firebaseService";
import { Attendance } from "../interfaces/Attendance";

const AttendancePage = () => {
    const { eventID } = useParams<{ eventID: string }>();
    const [attendedUsers, setattendedUsers] = useState<User[]>([]);
    const [eventName, setEventName] = useState<string>("");
    const [loading, setLoading] = useState<boolean>(true);
    const [error, setError] = useState<string | null>(null);


    const navigate = useNavigate();

    const handleArrowClick = () => {
        navigate(`/view-event/${eventID}`);
    };

    useEffect(() => {

        const fetchEvents = async () => {
            try {
                if (!eventID) {
                    setError('Event ID is missing.');
                    setLoading(false);
                    return;
                }
                const eventAttendanceWithProfiles = await fetchEventAttendanceWithProfiles(eventID);
                const attendances: Attendance[] = eventAttendanceWithProfiles.map((item) => item.attendance);
                const attendedStudents: User[] = eventAttendanceWithProfiles
                    .map((item) => item.userProfile)
                    .filter((profile): profile is User => profile !== null);
                setattendedUsers(attendedStudents);
                const eventName = await fetchEventName(eventID);
                if (eventName) {
                    setEventName(eventName);
                } else {
                    setError('No event found with the given ID');
                }
            } catch (error) {
                setError('Failed to load users');
                console.error('Error fetching attended users:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchEvents();
    }, []);


    if (loading) return <p className="text-center text-lg text-gray-500">Loading events...</p>;
    if (error) return <p className="text-center text-red-500">{error}</p>;

    return (

        <div className="p-8 bg-gray-50 min-h-screen">
            <div className="flex items-center justify-between mb-6">
                <div className="flex items-center">
                    <FaArrowLeftLong
                        style={{ fontSize: "2rem", strokeWidth: "2" }}
                        className="text-bured mr-4 cursor-pointer hover:text-red-900"
                        onClick={handleArrowClick}
                    />
                    <h2 className="text-2xl font-bold text-bured">Attendance</h2>
                </div>
            </div>

            <AttendanceTable users={attendedUsers} eventName={eventName}></AttendanceTable>
        </div>
    );
};

export default AttendancePage;
