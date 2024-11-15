import React, { useState, useEffect } from 'react';
import { NavLink, useLocation } from 'react-router-dom';

interface NoncollapsibleMenuProps {
    title: string;
    image: string;
    hoverImage: string;
    to: string;
    activeLink: string;
    setActiveLink: (link: string) => void;
}

const NoncollapsibleMenu: React.FC<NoncollapsibleMenuProps> = ({ title, image, hoverImage, to, activeLink, setActiveLink }) => {
    const location = useLocation();
    const [iconSrc, setIconSrc] = useState(image);
    const [selected, setSelected] = useState(false); // Track if the item is selected

    useEffect(() => {
        // Check if the current path matches the menu item's path
        if (location.pathname === to) {
            setSelected(true);
            setIconSrc(hoverImage); // Keep hover image when active
        } else {
            setSelected(false);
            setIconSrc(image); // Reset to default image when not active
        }
    }, [location, to, hoverImage, image]);

    const handleMouseEnter = () => {
        if (!selected) {
            setIconSrc(hoverImage);
        }
    };

    const handleMouseLeave = () => {
        if (!selected) {
            setIconSrc(image);
        }
    };

    const handleClick = () => {
        setSelected(true);
        setActiveLink(title); 
        setIconSrc(hoverImage); // Persistently set to hover image on click
    };

    return (
        <li className="w-full">
            <NavLink
                to={to}
                onMouseEnter={handleMouseEnter}
                onMouseLeave={handleMouseLeave}
                onClick={handleClick}
                className={({ isActive }) =>
                    `w-full text-left flex items-center justify-between rounded-lg p-2 ${isActive || selected ? 'text-sidebar-red' : 'text-sidebar-grey'
                    } hover:text-sidebar-red hover:bg-gray-100`
                }
            >
                <div className="flex items-center">
                    <img src={iconSrc} alt="menu_icon" className="w-5 h-5 mr-2" />
                    <span className="font-semibold">{title}</span>
                </div>
            </NavLink>
        </li>
    );
};

export default NoncollapsibleMenu;
