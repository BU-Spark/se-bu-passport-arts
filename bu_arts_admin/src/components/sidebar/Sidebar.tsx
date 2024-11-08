import React from 'react';
import { SignedIn, SignedOut, SignInButton } from '@clerk/clerk-react';
import UserProfile from './UserProfile';
import NavMenu from './NavMenu';

const Sidebar: React.FC = () => {
    return (
        <aside className="w-80 h-screen bg-white p-6 shadow-md flex flex-col items-start text-white">
            {/* Logo and Title */}
            <div className="mb-8">
                <img src="../public/icons/bu_arts.png" alt="BU Arts Initiative" />
                <h1 className="text-white text-2xl font-bold">BU Arts Initiative</h1>
            </div>

            <NavMenu></NavMenu>

            {/* User Profile */}
            <div className="mt-auto w-full">
                <SignedOut>
                    <SignInButton>
                        <button className="w-full px-4 py-2 bg-white text-red-800 rounded hover:bg-gray-200 transition">
                            Sign In
                        </button>
                    </SignInButton>
                </SignedOut>
                <SignedIn>
                    <UserProfile />
                </SignedIn>
            </div>
        </aside>
    )

}

export default Sidebar