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
    return <p className="text-gray-500">Loading dashboard...</p>;
  }

  if (data.length === 0) {
    return <p className="text-gray-500">No dashboard data available.</p>;
  }

  const xLabels = data.map((item) => item.month);
  const yData = data.map((item) => item.count);
  const trackedMonths = data.length;
  const peakMonth = data.reduce((highest, current) => (current.count > highest.count ? current : highest), data[0]);
  const formattedPeakMonth = new Date(`${peakMonth.month}-01T00:00:00`).toLocaleDateString('en-US', {
    month: 'long',
    year: 'numeric',
  });

  return (
    <div className="max-w-7xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-semibold text-bured">Dashboard</h1>
        <p className="mt-1 text-sm text-gray-500">
          Overview of recent user registrations and current BU Arts events.
        </p>
      </div>

      <div className="rounded-2xl bg-white p-6 shadow-md">
        <div className="mb-8 grid grid-cols-1 gap-4 lg:grid-cols-3">
          <div className="rounded-xl border border-gray-200 p-6">
            <p className="text-sm font-medium text-gray-500">Tracked Months</p>
            <p className="mt-2 text-4xl font-bold text-sidebar-grey">{trackedMonths}</p>
            <p className="mt-1 text-sm text-gray-500">Visible points in the selected registration range.</p>
          </div>

          <div className="rounded-xl border border-gray-200 p-6">
            <p className="text-sm font-medium text-gray-500">Peak Month</p>
            <p className="mt-2 text-4xl font-bold text-sidebar-grey">{peakMonth.count}</p>
            <p className="mt-1 text-sm text-gray-500">{formattedPeakMonth}</p>
          </div>

          <MonthlyEventCountWidget />
        </div>

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
