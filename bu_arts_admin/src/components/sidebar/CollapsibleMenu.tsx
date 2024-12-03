import React, { useEffect, useState, ReactNode } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';

interface CollapsibleMenuProps {
  title: string;
  to: string;
  image: string;
  hoverImage: string;
  children: ReactNode;
  activeLink: string;
  setActiveLink: (link: string) => void;
}

const CollapsibleMenu: React.FC<CollapsibleMenuProps> = ({
  title,
  image,
  hoverImage,
  children,
  to,
  activeLink,
  setActiveLink,
}) => {
  const defaultImageSrc = `${image}`;
  const hoverImageSrc = `${hoverImage}`;

  const navigate = useNavigate();

  const [isOpen, setIsOpen] = useState(false);
  const [iconSrc, setIconSrc] = useState(defaultImageSrc);

  useEffect(() => {
    if (activeLink.slice(0,7) === title) {
      setIconSrc(hoverImageSrc);
    } else {
      setIconSrc(defaultImageSrc);
    }
  }, [activeLink, title, hoverImageSrc, defaultImageSrc]);

  const handleMouseEnter = () => {
    if (activeLink !== title) {
      setIconSrc(hoverImageSrc);
    }
  };

  const handleMouseLeave = () => {
    if (activeLink !== title) {
      setIconSrc(defaultImageSrc);
    }
  };

  const handleClick = (e: React.MouseEvent<HTMLAnchorElement>) => {
    e.preventDefault();
    setIsOpen(!isOpen);
    setActiveLink(title);
    navigate(to);
  };

  return (
    <li className="w-full">
      <NavLink
        to={to}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={handleMouseLeave}
        onClick={handleClick}
        className={`w-full text-left flex items-center justify-between p-2 rounded-lg ${activeLink === title ? 'text-sidebar-red' : 'text-sidebar-grey'
          } hover:text-sidebar-red hover:bg-gray-100`}
      >
        <div className="flex items-center">
          <img src={iconSrc} alt="menu_icon" className="w-5 h-5 mr-2" />
          <span className="font-semibold">{title}</span>
        </div>
        <span>{isOpen ? '▲' : '▼'}</span>
      </NavLink>
      {isOpen && <ul className="pl-4 space-y-2">{children}</ul>}
    </li>
  );
};

export default CollapsibleMenu;
