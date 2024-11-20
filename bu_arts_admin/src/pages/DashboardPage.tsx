import React, { useEffect, useState } from 'react';
import { fetchUserRegistrationStats } from '../firebase/firebaseService';
import NewUserLineChart from '../components/dashboard/NewUserLineChart';
import MonthlyEventCountWidget from '../components/dashboard/MonthlyEventCountWidget';

const DashboardPage: React.FC = () => {
  const [data, setData] = useState<{ month: string; count: number }[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [range, setRange] = useState<string>('6'); // Default range is 6 months

  const loadData = async (range: string) => {
    try {
      setLoading(true);
      let stats;
      if (range === 'all') {
        stats = await fetchUserRegistrationStats(0); // Fetch all data
      } else {
        stats = await fetchUserRegistrationStats(parseInt(range, 10));
      }
      const transformedData = stats.months.map((month, index) => ({
        month,
        count: stats.registrations[index],
      }));
      setData(transformedData);
    } catch (error) {
      console.error('Error fetching user registration stats:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData(range); // Load data based on the selected range
  }, [range]);

  if (loading) {
    return <p>Loading...</p>;
  }

  if (data.length === 0) {
    return <p>No data available.</p>;
  }

  const xLabels = data.map((item) => item.month); // Extract months for x-axis
  const yData = data.map((item) => item.count);   // Extract counts for y-axis

  return (
    <div>
      <div className="flex items-center space-x-4 mb-4">
        <h1 className="text-2xl font-semibold text-bured">Dashboard</h1>
      </div>
      {/* Flex container to position the chart and widget side by side */}
      <div className="flex justify-between items-start w-full space-x-1">
        {/* Chart: 8/12 of the width */}
        <div className="w-8/12">
          <NewUserLineChart
            xLabels={xLabels}
            yData={yData}
            range={range}
            setRange={setRange}
          />
        </div>
        {/* Widget: 4/12 of the width */}
        <div className="w-4/12">
          <MonthlyEventCountWidget />
        </div>
      </div>
    </div>

  );
};

export default DashboardPage;
