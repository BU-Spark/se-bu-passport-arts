import React from 'react';
import { UserButton, useUser } from '@clerk/clerk-react';

const UserProfile: React.FC = () => {
    const { user } = useUser();
    return (
        <div className="relative flex w-full items-center space-x-3 rounded-lg border border-gray-200 bg-white p-3 text-sidebar-grey">
            <div className="absolute right-0 top-0 h-5 w-5 rounded-tr-lg border-r-4 border-t-4 border-black" />
            <UserButton
                appearance={{
                    elements: {
                        avatarBox: 'w-10 h-10', // Size for avatar
                    },
                }}
            />
            {user && (
                <div className="min-w-0">
                    <p className="text-sm font-semibold">{user.fullName}</p>
                    <p className="text-xs">{user.primaryEmailAddress?.emailAddress}</p>
                </div>
            )}
        </div>
    );
};

export default UserProfile;