import React from 'react';
import { User } from '../../interfaces/User';
import AttendanceRow from './AttendanceRow';

interface AttendenceProps {
    users: User[];
    eventName: string;
}

const AttendanceTable: React.FC<AttendenceProps> = ({ users, eventName }) => {
    return (
        <div className="overflow-x-auto">
            <table className="min-w-full bg-white rounded-lg shadow-md">
                <thead>
                    <tr className="bg-bured text-white text-left">
                        <th className="py-3 px-10 font-semibold">BUID</th>
                        <th className="py-3 px-10 font-semibold">Event Name</th>
                        <th className="py-3 px-9 font-semibold">Status</th>
                        <th className="py-3 px-10 font-semibold">Action</th>
                    </tr>
                </thead>
                <tbody>
                    {users.map((user) => (
                        <AttendanceRow key={user.userUID} user={user} eventName={eventName}/>
                    ))}
                </tbody>
            </table>
        </div>
    )
}
export default AttendanceTable