import React, { useEffect, useState } from 'react';
import { useNavigate } from "react-router-dom";
import { countCurrentMonthEvents } from '../../firebase/firebaseService';

const MonthlyEventCountWidget: React.FC = () => {
    const [eventCount, setEventCount] = useState<number>(0);
    const navigate = useNavigate(); // Initialize useNavigate

    const handleRedirect = () => {
        navigate("/events/upcoming"); // Redirect to the desired route
    };

    const fetchMonthlyEvents = async () => {
        try {
            const count = await countCurrentMonthEvents();
            console.log("Monthly event count:", count);
            setEventCount(count);
        } catch (error) {
            console.error("Error fetching events:", error);
        }
    };

    useEffect(() => {
        fetchMonthlyEvents();
    }, []);

    return (
        <div className="bg-white shadow-lg rounded-lg p-6 w-full max-w-3xl mx-auto text-center">
            {/* Header Section */}
            <div className="mb-4">
                <h2 className="text-gray-600 text-lg font-medium">Monthly Events</h2>
                <p className="text-back text-5xl font-bold my-2">{eventCount}</p>
            </div>

            {/* Button Section */}
            <div className="flex justify-center mt-4">
                <button 
                    className="bg-red-100 text-red-600 px-4 py-2 rounded shadow hover:bg-red-200"
                    onClick={handleRedirect}
                >
                    See All Events
                </button>
            </div>
        </div>
    );
};

export default MonthlyEventCountWidget;
