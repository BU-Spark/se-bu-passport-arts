import React from 'react';
import { User } from '../../interfaces/User';
import StudentRow from './StudentRowComponent';

interface StudentsProps {
    users: User[];
}

const StudentTable: React.FC<StudentsProps> = ({ users }) => {
    return (
        <div className="overflow-x-auto">
            <table className="min-w-full bg-white rounded-lg shadow-md">
                <thead>
                    <tr className="bg-bured text-white text-left">
                        <th className="py-3 px-24 font-semibold">Name</th>
                        <th className="py-3 px-10 font-semibold">BUID</th>
                        <th className="py-3 px-9 font-semibold">Ranking</th>
                        <th className="py-3 px-10 font-semibold">Action</th>
                    </tr>
                </thead>
                <tbody>
                    {users.map((user) => (
                        <StudentRow key={user.userUID} user={user} />
                    ))}
                </tbody>
            </table>
        </div>
    )
}
export default StudentTable