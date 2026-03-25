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
  width = 920,
  height = 320,
  range,
  setRange,
}) => {
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
  const totalUsers = yData.reduce((sum, value) => sum + value, 0);

  return (
    <div className="rounded-xl border border-gray-200 bg-white p-6">
      <div className="mb-6 flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
        <div className="flex flex-col items-start">
          <h2 className="text-lg font-medium text-gray-600">Total New Users</h2>
          <p className="mt-2 text-5xl font-bold text-bured">{totalUsers}</p>
          <p className="mt-1 text-sm text-gray-500">{getRangeDescription(range)}</p>
          <p className="mt-3 text-sm text-gray-500">
            User registration trend across the selected time range.
          </p>
        </div>

        <div className="flex items-center">
          <label htmlFor="rangeSelect" className="mr-2 text-sm font-medium text-gray-600">
            Select Time Range:
          </label>
          <select
            id="rangeSelect"
            value={range}
            onChange={(e) => {
              e.preventDefault();
              setRange(e.target.value);
            }}
            className="w-40 rounded-lg border border-gray-300 bg-white p-2 text-gray-700"
          >
            <option value="3">Last 3 Months</option>
            <option value="6">Last 6 Months</option>
            <option value="12">Last Year</option>
            <option value="all">All</option>
          </select>
        </div>
      </div>

      <div className="overflow-x-auto rounded-xl border border-gray-200 bg-gray-50 px-2 py-4">
        <LineChart
          width={width}
          height={height}
          series={[
            { data: yData, label: 'New Users', color: '#CC0000' },
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
