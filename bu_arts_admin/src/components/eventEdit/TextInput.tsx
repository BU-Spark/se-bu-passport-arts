// src/components/eventEdit/TextInput.tsx
import React from 'react';

interface TextInputProps {
  label: string;
  value: string;
  onChange: (value: string) => void; // Expects a string
  className?: string;
  placeholder?: string;
  disabled?: boolean;
}

const TextInput: React.FC<TextInputProps> = ({
  label,
  value,
  onChange,
  className = '',
  placeholder = '',
  disabled = false,
}) => {
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = e.target.value;
    onChange(newValue); // Passes the string to onChange
  };

  return (
    <div className={`mb-4 ${className}`}>
      <label className="block text-gray-700 mb-1">{label}</label>
      <input
        type="text"
        className="w-full border border-gray-300 p-2 rounded mt-1"
        value={value}
        onChange={handleChange}
        placeholder={placeholder}
        disabled={disabled}
      />
    </div>
  );
};

export default TextInput;
