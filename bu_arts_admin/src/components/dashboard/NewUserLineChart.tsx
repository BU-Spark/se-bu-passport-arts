import React from 'react';
import { LineChart } from '@mui/x-charts/LineChart';

interface UserChartProps {
  xLabels: string[]; // X-axis labels (e.g., months)
  yData: number[];   // Y-axis data (e.g., user registrations)
  width?: number;    // Chart width (optional)
  height?: number;   // Chart height (optional)
  range: string;     // Selected time range
  setRange: (range: string) => void; // Function to update the time range
}

const NewUserLineChart: React.FC<UserChartProps> = ({
  xLabels,
  yData,
  width = 800,
  height = 300,
  range,
  setRange,
}) => {
  // Map range values to descriptive text
  const getRangeDescription = (range: string): string => {
    switch (range) {
      case '3':
        return 'Last 3 Months';
      case '6':
        return 'Last 6 Months';
      case '12':
        return 'Last Year';
      case 'all':
        return 'All Time';
      default:
        return '';
    }
  };

  return (
    <div className="bg-white shadow-lg rounded-lg p-6 max-w-fit mx-auto">
      {/* Header Section */}
      <div className="flex flex-col items-start mb-4">
        <h2 className="text-gray-600 text-lg font-medium">Total Participant</h2>
        <p className="text-red-600 text-5xl font-bold underline">3,278</p>
        <p className="text-gray-500 text-sm mt-1">{getRangeDescription(range)}</p>
      </div>

      {/* Time Range Selector */}
      <div className="flex justify-between items-center mb-4 w-full">
        <div></div> {/* Empty div for spacing */}
        <div className="flex items-center">
          <label htmlFor="rangeSelect" className="text-sm font-medium text-gray-600 mr-2">
            Select Time Range:
          </label>
          <select
            id="rangeSelect"
            value={range}
            onChange={(e) => {
              e.preventDefault(); // Prevent any default browser behavior
              setRange(e.target.value); // Update the state
            }}
            className="p-2 border rounded w-40 text-gray-700"
          >
            <option value="3">Last 3 Months</option>
            <option value="6">Last 6 Months</option>
            <option value="12">Last Year</option>
            <option value="all">All</option>
          </select>
        </div>
      </div>

      {/* Chart Section */}
      <div className="w-full">
        <LineChart
          width={width}
          height={height}
          series={[
            { data: yData, label: 'New Users', color: 'orange' },
          ]}
          xAxis={[
            {
              scaleType: 'point',
              data: xLabels,
              label: 'Month',
            },
          ]}
        />
      </div>
    </div>
  );
};

export default NewUserLineChart;
