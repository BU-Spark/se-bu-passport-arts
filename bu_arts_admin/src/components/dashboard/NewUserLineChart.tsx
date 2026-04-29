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
  const formatMonthLabel = (value: string): string => {
    const [year, month] = value.split('-');
    const date = new Date(Number(year), Number(month) - 1, 1);

    return date.toLocaleDateString('en-US', {
      month: 'long',
      year: 'numeric',
    });
  };
  const totalUsers = yData.reduce((sum, value) => sum + value, 0);
  const maxYValue = Math.max(...yData);
  const yTicks =
    maxYValue <= 4
      ? Array.from({ length: maxYValue + 1 }, (_, index) => index)
      : (() => {
          const step = Math.ceil(maxYValue / 4);
          const ticks = Array.from({ length: Math.floor(maxYValue / step) + 1 }, (_, index) => index * step);

          if (ticks[ticks.length - 1] !== maxYValue) {
            ticks.push(maxYValue);
          }

          return ticks;
        })();

  return (
    <div className="rounded-xl border border-gray-200 bg-white p-6">
      <div className="mb-6 flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
        <div className="flex flex-col items-start">
          <h2 className="text-lg font-medium text-gray-600">Total New Users</h2>
          <p className="mt-2 text-5xl font-bold text-bured">{totalUsers}</p>
        </div>

        <div className="flex items-center">
          <select
            id="rangeSelect"
            aria-label="Select Time Range"
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
              valueFormatter: (value) => formatMonthLabel(value),
            },
          ]}
          yAxis={[
            {
              min: 0,
              tickMinStep: 1,
              tickInterval: yTicks,
              valueFormatter: (value) => {
                const numericValue = Number(value);
                const roundedValue = Math.round(numericValue);

                return Math.abs(numericValue - roundedValue) < 0.000001 ? String(roundedValue) : '';
              },
            },
          ]}
          slotProps={{ legend: { hidden: true } }}
        />
      </div>
    </div>
  );
};

export default NewUserLineChart;
