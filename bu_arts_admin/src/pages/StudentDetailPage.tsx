import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from 'react-router-dom';
import { fetchSingleUser } from "../firebase/firebaseService";
import { User } from "../interfaces/User";
import { FaArrowLeftLong } from "react-icons/fa6";
import { searchUsers } from "../firebase/firebaseService";

const StudentDetailPage = () => {
    const navigate = useNavigate();

    const { userID } = useParams<{ userID: string }>();
    const [user, setUser] = useState<User>();
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);


    const handleArrowClick = () => {
        navigate("/students");
    };

    useEffect(() => {
        const fetchEvent = async () => {
            if (!userID) {
                setError("Event ID is missing.");
                setLoading(false);
                return;
            }
            try {
                const data = await fetchSingleUser(userID);
                if (data) {
                    setUser(data);
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
    }, [userID]);

    if (loading) return <p>Loading...</p>;
    if (error) return <p>{error}</p>;
    if (!user) return <p>User not found</p>;

    // console.log(searchUsers())


    return (
        <div className="p-8 bg-gray-50 min-h-screen">

            <div className="flex items-center justify-between mb-6">
                <div className="flex items-center">
                    <FaArrowLeftLong 
                    style={{ fontSize: "2rem", strokeWidth: "2" }}
                    className="text-bured mr-4 cursor-pointer hover:text-red-900"
                    onClick={handleArrowClick}
                    />
                    <h2 className="text-2xl font-bold text-bured">Student Profile</h2>
                </div>
                <input
                    type="text"
                    placeholder="Search student name or BUID"
                    className="w-2/3 p-3 rounded-full border border-gray-300 focus:outline-none focus:border-red-600"
                />
            </div>

            {/* Table structure */}
            {/* <StudentTable users={users}></StudentTable> */}
        </div>
    );
};

export default StudentDetailPage;
