import React from 'react';
import { useNavigate } from "react-router-dom";
import { User } from '../../interfaces/User';

interface StudentRowProps {
    user: User;
}

const StudentRow: React.FC<StudentRowProps> = ({ user }) => {
    const navigate = useNavigate();

    const handleButtonClick = () => {
        navigate(`/students/${user.userUID}`);
    };
    return (
        <tr className="border-b hover:bg-gray-100">
            <td className="py-4 px-4 flex items-center">
                <img
                    src={user.userProfileURL || "https://via.placeholder.com/50"}
                    alt="Profile"
                    className="w-14 h-14 rounded-full mr-4"
                />
                <span className="font-medium text-gray-800">
                    {user.firstName} {user.lastName}
                </span>
            </td>
            <td className="py-4 px-4 text-gray-600">{user.userBUID}</td>
            <td className="py-4 px-12">
                <img
                    src="public/icons/ranking_badge.png"
                    alt="Ranking"
                    className="w-10 h-10"
                />
            </td>
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

export default StudentRow;
