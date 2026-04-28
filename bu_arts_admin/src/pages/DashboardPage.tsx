import React, { useEffect, useState } from 'react';
import { fetchUserRegistrationStats } from '../firebase/firebaseService';
import CurrentMonthEventInsightsSection from '../components/dashboard/CurrentMonthEventInsights';
import NewUserLineChart from '../components/dashboard/NewUserLineChart';

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
    return <p className="text-gray-500">Loading dashboard...</p>;
  }

  if (data.length === 0) {
    return <p className="text-gray-500">No dashboard data available.</p>;
  }

  const xLabels = data.map((item) => item.month);
  const yData = data.map((item) => item.count);

  return (
    <div className="max-w-7xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-semibold text-bured">Dashboard</h1>
      </div>

      <div className="rounded-2xl bg-white p-6 shadow-md">
        <CurrentMonthEventInsightsSection />

        <div>
          <NewUserLineChart
            xLabels={xLabels}
            yData={yData}
            range={range}
            setRange={setRange}
          />
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;
