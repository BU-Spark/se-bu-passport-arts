import React, { useState, useEffect } from "react";
import { searchUsers } from "../firebase/firebaseService";
import { User } from "../interfaces/User";
import StudentTable from "../components/student/StudentTableComponent";

const ViewStudentsPage = () => {
    const [loading, setLoading] = useState<boolean>(true);
    const [error, setError] = useState<string | null>(null);

    const [users, setUsers] = useState<User[]>([]);
    const [searchText, setSearchText] = useState('');

    const handleInputChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
        const text = event.target.value;
        setSearchText(text);
        let result = await searchUsers(text);
        setUsers(result);
    };

    useEffect(() => {
        const fetchEvents = async () => {
            try {
                const usersData = await searchUsers('');
                setUsers(usersData);
            } catch (error) {
                setError('Failed to load users');
                console.error('Error fetching users:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchEvents();
    }, []);


    if (loading) return <p className="text-center text-lg text-gray-500">Loading events...</p>;
    if (error) return <p className="text-center text-red-500">{error}</p>;

    return (
        <div className="p-8 bg-gray-50 min-h-screen">

            <div className="flex items-center justify-between mb-6">
                <h2 className="text-2xl font-bold text-bured">Students</h2>
                <input
                    type="text"
                    placeholder="Search student name or BUID"
                    value={searchText}
                    onChange={handleInputChange}
                    className="w-2/3 p-3 rounded-full border border-gray-300 focus:outline-none focus:border-red-600"
                />
            </div>

            <StudentTable users={users}></StudentTable>
        </div>
    );
};

export default ViewStudentsPage;
