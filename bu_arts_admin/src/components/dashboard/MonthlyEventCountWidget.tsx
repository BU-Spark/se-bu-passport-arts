import React, { useEffect, useState } from 'react';
import { useNavigate } from "react-router-dom";
import { countCurrentMonthBuEvents } from '../../services/buEventsService';

const MonthlyEventCountWidget: React.FC = () => {
    const [eventCount, setEventCount] = useState<number>(0);
    const navigate = useNavigate();

    const handleRedirect = () => {
        navigate("/events/upcoming"); // Redirect to the desired route
    };

    const fetchMonthlyEvents = async () => {
        try {
            const count = await countCurrentMonthBuEvents();
            setEventCount(count);
        } catch (error) {
            console.error("Error fetching events:", error);
        }
    };

    useEffect(() => {
        fetchMonthlyEvents();
    }, []);

    return (
        <div className="rounded-xl border border-gray-200 bg-white p-6">
            <div className="mb-6">
                <h2 className="text-lg font-medium text-gray-600">Monthly Events</h2>
                <p className="mt-2 text-5xl font-bold text-sidebar-grey">{eventCount}</p>
                <p className="mt-1 text-sm text-gray-500">Events happening this calendar month.</p>
            </div>

            <div className="flex justify-start">
                <button 
                    className="rounded-full bg-red-50 px-4 py-2 text-bured transition hover:bg-red-100"
                    onClick={handleRedirect}
                >
                    See All Events
                </button>
            </div>
        </div>
    );
};

export default MonthlyEventCountWidget;
