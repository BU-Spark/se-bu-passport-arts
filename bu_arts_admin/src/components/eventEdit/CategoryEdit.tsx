import React, { useState, ChangeEvent } from 'react';
import { Event } from "../../interfaces/Event.tsx";

interface CategoryEditProps {
    event: Event;
    setEvent: React.Dispatch<React.SetStateAction<Event | null>>;
}

const CategoryEdit: React.FC<CategoryEditProps> = ({ event, setEvent }) => {
    const [isEditing, setIsEditing] = useState(false);
    const [categories, setCategories] = useState(event.eventCategories || []);
    const [originalCategories, setOriginalCategories] = useState<string[]>([]);

    const handleEditClick = () => {
        setIsEditing(true);
        setOriginalCategories([...categories]); // Store original categories
    };

    const handleCategoryChange = (e: ChangeEvent<HTMLInputElement>, index: number) => {
        const newCategories = [...categories];
        newCategories[index] = e.target.value;
        setCategories(newCategories);
    };

    const handleAddCategory = () => {
        setCategories([...categories, "New Category"]);
    };

    const handleDeleteCategory = (index: number) => {
        const newCategories = categories.filter((_, i) => i !== index);
        setCategories(newCategories);
    };

    const handleSave = () => {
        setIsEditing(false);
        setEvent((prevEvent) => prevEvent ? { ...prevEvent, eventCategories: categories } : prevEvent);
    };

    const handleCancel = () => {
        setIsEditing(false);
        setCategories([...originalCategories]); // Revert to original categories
    };

    return (
        <div className="flex items-center space-x-2 mb-6">
            <div className="flex flex-wrap items-center space-x-2">
                {categories.map((category, index) => (
                    <div key={index} className="flex items-center space-x-2 mb-2">
                        {isEditing ? (
                            <input
                                type="text"
                                value={category}
                                onChange={(e) => handleCategoryChange(e, index)}
                                className="text-sm font-semibold text-gray-800 bg-white border-b-2 border-gray-300 focus:outline-none px-2 py-1 rounded"
                            />
                        ) : (
                            <span className="bg-red-500 text-white px-3 py-1 rounded-full text-sm font-semibold">{category}</span>
                        )}
                        {isEditing && (
                            <button onClick={() => handleDeleteCategory(index)} className="text-gray-500 hover:text-red-500">
                                ✕
                            </button>
                        )}
                    </div>
                ))}
            </div>
            {isEditing && (
                <>
                    <button onClick={handleAddCategory} className="text-gray-500 hover:text-green-500 p-2 rounded-full">
                        Add Category
                    </button>
                    <button onClick={handleCancel} className="text-gray-500 hover:text-gray-800 p-2 rounded-full">
                        Cancel
                    </button>
                </>
            )}
            <div>
                <button onClick={isEditing ? handleSave : handleEditClick} className="text-gray-500 hover:text-red-500 p-2 rounded-full">
                    {isEditing ? "Save" : <img src="/public/icons/pen.png" alt="Edit" className="h-4 w-4" />}
                </button>
            </div>
        </div>
    );
};

export default CategoryEdit;
