import React, { useState } from 'react';
import CollapsibleMenu from './CollapsibleMenu';
import NoncollapsibleMenu from './NoncollapsibleMenu';
import { NavLink } from 'react-router-dom';

const NavMenu: React.FC = () => {
    const [activeLink, setActiveLink] = useState<string>("");

    return (
        <nav className="flex-grow w-full">
            <ul className="space-y-2 w-full">
                <CollapsibleMenu
                    title="Home"
                    image="/icons/home_grey.png"
                    hoverImage="/icons/home_red.png"
                    to="/"
                    activeLink={activeLink}
                    setActiveLink={setActiveLink}
                >
                    <li className="mt-2">
                        <NavLink
                            to="/"
                            className={({ isActive }) => `pl-4 ${isActive ? 'text-sidebar-red' : 'text-sidebar-grey hover:text-sidebar-red'}`}
                            onClick={() => setActiveLink("Home")}
                        >
                            Dashboard
                        </NavLink>
                    </li>
                    <li>
                        <NavLink
                            to="/events"
                            className={({ isActive }) => `pl-4 ${isActive ? 'text-sidebar-red' : 'text-sidebar-grey hover:text-sidebar-red'}`}
                            onClick={() => setActiveLink("Home")}
                        >
                            Event
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
            </ul>
        </nav>
    );
};

export default NavMenu;
