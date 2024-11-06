// src/components/StatsGrid.tsx
import React from 'react';
import StatBox from './StatBox';

const StatsGrid: React.FC = () => {
  return (
    <div className="bg-gray-100 p-6 rounded-lg shadow-md max-w-4xl mx-auto">
      <h2 className="text-lg font-semibold text-gray-800 mb-4">This Month</h2>
      <div className="grid grid-cols-2 gap-4">
        <StatBox
          icon="👤" // Replace with actual icons or SVGs
          label="Active Users"
          value="2,461"
          bgColor="bg-blue-100"
        />
        <StatBox
          icon="📅"
          label="Monthly Events"
          value="32"
          bgColor="bg-green-100"
        />
        <StatBox
          icon="👥"
          label="Total Participants"
          value="12,131"
          bgColor="bg-yellow-100"
        />
        <StatBox
          icon="➕"
          label="New Users"
          value="+23"
          bgColor="bg-purple-100"
        />
      </div>
    </div>
  );
};

export default StatsGrid;
