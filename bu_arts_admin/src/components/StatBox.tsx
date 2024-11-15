import React from 'react';

interface StatBoxProps {
  icon: React.ReactNode;
  label: string;
  value: string | number;
  bgColor: string;
}

const StatBox: React.FC<StatBoxProps> = ({ icon, label, value, bgColor }) => {
  return (
    <div className="flex items-center p-4 rounded-lg shadow-sm bg-white w-60 h-24">
      {/* Icon on the left with custom background color */}
      <div className={`flex items-center justify-center w-12 h-12 rounded-md ${bgColor} mr-4`}>
        <div className="text-2xl text-gray-800">{icon}</div>
      </div>
      
      {/* Label and Value on the right */}
      <div>
        <p className="text-sm text-gray-600">{label}</p>
        <p className="text-2xl font-semibold text-gray-800">{value}</p>
      </div>
    </div>
  );
};

export default StatBox;
