import { useState, useEffect } from "react";
import { useParams, useNavigate } from 'react-router-dom';
import { FaArrowLeftLong } from "react-icons/fa6";
import { User } from "../interfaces/User";
import { Event } from "../interfaces/Event";
import { fetchSingleUser, fetchUserAttendedEvents } from "../firebase/firebaseService";

const StudentDetailPage = () => {
    const navigate = useNavigate();

    const { userID } = useParams<{ userID: string }>();
    const [user, setUser] = useState<User>();
    const [attendedEvents, setAttendedEvents] = useState<Event[]>([]);
    const [activeTab, setActiveTab] = useState<string>("reviewed");
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // The following data is for demonstration purposes only
    const upcomingEvents = [
        {
            eventTitle: "Jazz Night",
            eventLocation: "Downtown Club",
            date: "09/20/2023",
            eventPhoto: "https://via.placeholder.com/300x200",
        },
        {
            eventTitle: "Art Gallery Exhibition",
            eventLocation: "City Art Center",
            date: "09/25/2023",
            eventPhoto: "https://via.placeholder.com/300x200",
        },
    ];


    const handleArrowClick = () => {
        navigate("/students");
    };

    useEffect(() => {
        const fetchUser = async () => {
            if (!userID) {
                setError("User ID is missing.");
                setLoading(false);
                return;
            }
            try {
                const data = await fetchSingleUser(userID);
                if (data) {
                    setUser(data);
                } else {
                    setError("No user found with the given ID");
                }

                const attendedEvents = await fetchUserAttendedEvents(userID);
                setAttendedEvents(attendedEvents);
            } catch (err) {
                setError("Failed to load user details.");
            } finally {
                setLoading(false);
            }
        };
        fetchUser();
    }, [userID]);

    if (loading) return <p>Loading...</p>;
    if (error) return <p>{error}</p>;
    if (!user) return <p>User not found</p>;


    return (
        <div className="p-8 bg-gray-50">

            <div className="flex items-center justify-between mb-6">
                <div className="flex items-center">
                    <FaArrowLeftLong
                        style={{ fontSize: "2rem", strokeWidth: "2" }}
                        className="text-bured mr-4 cursor-pointer hover:text-red-900"
                        onClick={handleArrowClick}
                    />
                    <h2 className="text-2xl font-bold text-bured">Student Profile</h2>
                </div>
            </div>
            <div className="relative h-screen bg-white">
                {/* Red Background */}
                <div className="bg-red-600 h-1/4 w-full absolute top-0 left-0"></div>

                {/* Content Section */}
                <div className="relative top-44 flex flex-col items-center">
                    {/* Profile Image */}
                    <img
                        src={user.userProfileURL}
                        alt={`${user.firstName} ${user.lastName}`}
                        className="h-40 w-40 rounded-full object-cover"
                    />

                    {/* Profile Name */}
                    <h1 className="mt-1 text-gray-700 text-4xl font-bold">{`${user.firstName} ${user.lastName}`}</h1>

                    {/* Ranking */}
                    <div className="flex items-center space-x-4 mt-1 text-gray-800">
                        <span className="text-2xl text-gray-500 flex items-center">
                            Ranking
                            <img
                                src="/icons/ranking_badge.png" // Adjust path to image
                                alt="Ranking Badge"
                                className="h-5 w-5 ml-1"
                            />
                        </span>
                    </div>
                    {/* Tabs Section */}
                    <div className="flex justify-center mt-4 border-b w-full">
                        <button
                            className={`px-4 py-2 font-bold text-red-600 ${activeTab === "reviewed"
                                ? "border-b-2 border-red-600"
                                : "text-gray-400"
                                }`}
                            onClick={() => setActiveTab("reviewed")}
                        >
                            Reviewed
                        </button>
                        <button
                            className={`px-4 py-2 font-bold text-red-600 ${activeTab === "upcoming"
                                ? "border-b-2 border-red-600"
                                : "text-gray-400"
                                }`}
                            onClick={() => setActiveTab("upcoming")}
                        >
                            Upcoming
                        </button>
                    </div>

                    {/* TODO: implement db query to user's reserved events */}
                    <div className="mt-8 grid grid-cols-2 gap-4">
                        {(activeTab === "reviewed" ? attendedEvents : upcomingEvents).map(
                            (event, index) => (
                                <div
                                    key={index}
                                    className="bg-white w-96 rounded-lg shadow-md overflow-hidden"
                                >
                                    {/* Event Image */}
                                    <div className="relative">
                                        <img
                                            src={event.eventPhoto}
                                            alt={event.eventTitle}
                                            className="w-full h-48 object-cover"
                                        />
                                        <div className="absolute top-0 left-0 w-full h-full bg-black bg-opacity-30 flex flex-col justify-end p-4">
                                            <h2 className="text-white text-lg font-bold">{event.eventTitle}</h2>
                                            <p className="text-gray-300">{event.eventLocation}</p>
                                        </div>
                                        <div className="absolute bottom-4 right-4 bg-white text-red-600 font-bold px-2 py-1 rounded-lg shadow-lg">
                                            {event.eventPoints}pts
                                        </div>
                                    </div>

                                    {/* Event Details */}
                                    <div className="p-4">
                                        <div className="mb-4">
                                            <span className="text-gray-400 text-sm font-bold block">
                                                {activeTab === "reviewed" ? "Attended" : "Upcoming"}
                                            </span>
                                        </div>
                                        {activeTab === "reviewed" && (
                                            <div className="flex items-center">
                                                {[...Array(5)].map((_, starIndex) => (
                                                    <svg
                                                        key={starIndex}
                                                        xmlns="http://www.w3.org/2000/svg"
                                                        className={`h-6 w-6 ${starIndex < event.rating
                                                            ? "text-red-600"
                                                            : "text-gray-300"
                                                            }`}
                                                        fill="currentColor"
                                                        viewBox="0 0 24 24"
                                                    >
                                                        <path d="M12 2l3 7h7l-5.5 4.6L17 21l-5-3-5 3 1.5-7.4L2 9h7l3-7z" />
                                                    </svg>
                                                ))}
                                            </div>
                                        )}
                                    </div>
                                </div>
                            )
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default StudentDetailPage;
