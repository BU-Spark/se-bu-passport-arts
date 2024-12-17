import React from 'react';
import { useNavigate } from "react-router-dom";
import { User } from '../../interfaces/User';

interface AttendenceRowProps {
    user: User;
    eventName: string;
}

const AttendanceRow: React.FC<AttendenceRowProps> = ({ user, eventName }) => {
    const navigate = useNavigate();

    const handleButtonClick = () => {
        navigate(`/students/${user.userUID}`);
    };
    return (
        <tr className="border-b hover:bg-gray-100">
            <td className="py-4 px-4 text-gray-600">{user.userBUID}</td>
            <td className="py-4 px-4 text-gray-600">{eventName}</td>
            <td className="py-4 px-4 text-gray-600">Attended</td>
            <td className="py-4 px-4">
                <button
                    className="bg-bured text-white px-4 py-2 rounded-md font-bold hover:bg-red-800"
                    onClick={handleButtonClick}
                >
                    Check Profile
                </button>
            </td>
        </tr>
    );
};

export default AttendanceRow;
