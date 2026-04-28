import React from 'react';
import { Link } from "react-router-dom";
import { User } from '../../interfaces/User';

interface StudentRowProps {
    user: User;
    index: number;
}

const StudentRow: React.FC<StudentRowProps> = ({ user, index }) => {
    return (
        <tr className={index % 2 === 0 ? 'bg-white' : 'bg-gray-50/70'}>
            <td className="px-4 py-4 text-base font-medium text-sidebar-grey">
                <div className="flex items-center gap-4">
                    <img
                        src={user.userProfileURL || "https://via.placeholder.com/50"}
                        alt="Profile"
                        className="h-12 w-12 rounded-full object-cover"
                    />
                    <div className="min-w-0">
                        <Link
                            to={`/students/${user.userUID}`}
                            className="font-medium text-sidebar-grey hover:text-bured hover:underline"
                        >
                            {user.firstName} {user.lastName}
                        </Link>
                        <p className="text-xs text-gray-500">{user.userEmail}</p>
                    </div>
                </div>
            </td>
            <td className="whitespace-nowrap px-4 py-4 text-base font-medium text-sidebar-grey">{user.userBUID}</td>
            <td className="whitespace-nowrap px-4 py-4 text-base font-medium text-sidebar-grey">
                <img
                    src="public/icons/ranking_badge.png"
                    alt="Ranking"
                    className="h-10 w-10"
                />
            </td>
        </tr>
    );
};

export default StudentRow;
