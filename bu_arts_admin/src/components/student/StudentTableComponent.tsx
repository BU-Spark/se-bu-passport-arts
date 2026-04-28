import React from 'react';
import { User } from '../../interfaces/User';
import StudentRow from './StudentRowComponent';

interface StudentsProps {
    users: User[];
}

const StudentTable: React.FC<StudentsProps> = ({ users }) => {
    return (
        <div className="overflow-hidden rounded-[28px] border border-gray-200 bg-white shadow-sm">
            <div className="overflow-x-auto">
                <table className="min-w-full">
                    <thead className="bg-gray-100 text-left">
                        <tr>
                            <th className="px-4 py-3 text-base font-semibold text-sidebar-grey">Name</th>
                            <th className="px-4 py-3 text-base font-semibold text-sidebar-grey">BUID</th>
                            <th className="px-4 py-3 text-base font-semibold text-sidebar-grey">Ranking</th>
                        </tr>
                    </thead>
                    <tbody>
                        {users.length > 0 ? (
                            users.map((user, index) => (
                                <StudentRow key={user.userUID} user={user} index={index} />
                            ))
                        ) : (
                            <tr>
                                <td colSpan={3} className="px-4 py-6 text-base text-gray-500">
                                    No students found.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    )
}
export default StudentTable