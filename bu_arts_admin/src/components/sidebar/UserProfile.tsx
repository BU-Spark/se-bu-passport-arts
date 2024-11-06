import React from 'react';
import { UserButton, useUser } from '@clerk/clerk-react';

const UserProfile: React.FC = () => {
    const { user } = useUser();
    return (
        <div className="flex items-center space-x-3 text-white bg-red-600 p-3 rounded-lg w-full">
            <UserButton
                appearance={{
                    elements: {
                        avatarBox: 'w-10 h-10', // Size for avatar
                    },
                }}
            />
            {user && (
                <div>
                    <p className="text-sm font-semibold">{user.fullName}</p>
                    <p className="text-xs">{user.primaryEmailAddress?.emailAddress}</p>
                </div>
            )}
        </div>
    );
};

export default UserProfile;