import React, { useState } from 'react';
import CollapsibleMenu from './CollapsibleMenu';
import NoncollapsibleMenu from './NoncollapsibleMenu';
import { NavLink } from 'react-router-dom';

const NavMenu: React.FC = () => {
    const [activeLink, setActiveLink] = useState<string>("");

    return (
        <nav className="flex-grow w-full">
            <ul className="space-y-2 w-full">
                <NoncollapsibleMenu
                    title="Home"
                    image="/icons/home_grey.png"
                    hoverImage="/icons/home_red.png"
                    to="/dashboard"
                    activeLink={activeLink}
                    setActiveLink={setActiveLink}
                />
                <CollapsibleMenu
                    title="Events"
                    image="/icons/event_grey.png"
                    hoverImage="/icons/event_red.png"
                    to="/events"
                    activeLink={activeLink}
                    setActiveLink={setActiveLink}
                >
                    <li className="mt-2">
                        <NavLink
                            to="/upcoming-events"
                            className={({ isActive }) => `pl-4 ${isActive ? 'text-sidebar-red' : 'text-sidebar-grey hover:text-sidebar-red'}`}
                            onClick={() => setActiveLink("Events-upcomping")}
                        >
                            Upcoming
                        </NavLink>
                    </li>
                    <li>
                        <NavLink
                            to="/events"
                            className={({ isActive }) => `pl-4 ${isActive ? 'text-sidebar-red' : 'text-sidebar-grey hover:text-sidebar-red'}`}
                            onClick={() => setActiveLink("Events-past")}
                        >
                            Past
                        </NavLink>
                    </li>
                </CollapsibleMenu>
                <NoncollapsibleMenu
                    title="Download History"
                    image="/icons/download_grey.png"
                    hoverImage="/icons/download_red.png"
                    to="/download_history"
                    activeLink={activeLink}
                    setActiveLink={setActiveLink}
                />
                <NoncollapsibleMenu
                    title="Students"
                    image="/icons/student_grey.png"
                    hoverImage="/icons/student_red.png"
                    to="/students"
                    activeLink={activeLink}
                    setActiveLink={setActiveLink}
                />
            </ul>
        </nav>
    );
};

export default NavMenu;
