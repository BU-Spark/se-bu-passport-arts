// src/components/NumberInput.tsx
import React from 'react';

interface NumberInputProps {
  label: string;
  value: number;
  onChange: (value: number) => void; // Expects a number, not an event
  className?: string;
  min?: number;
  max?: number;
  step?: number;
  disabled?: boolean;
}

const EventNumberInput: React.FC<NumberInputProps> = ({
  label,
  value,
  onChange,
  className = '',
  min,
  max,
  step,
  disabled = false,
}) => {
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = Number(e.target.value);
    onChange(newValue); // Passes the number to onChange
  };

  return (
    <div className={`mb-4 ${className}`}>
      <label className="block text-gray-700 mb-1">{label}</label>
      <input
        type="number"
        className="w-full border border-gray-300 p-2 rounded mt-1"
        value={value}
        onChange={handleChange}
        min={min}
        max={max}
        step={step}
        disabled={disabled}
      />
    </div>
  );
};

export default EventNumberInput;
