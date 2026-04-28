import React, { useEffect, useMemo, useState } from 'react';
import { PieChart } from '@mui/x-charts/PieChart';
import {
  fetchUpcomingEventInsights,
  UpcomingEventInsights,
} from '../../firebase/firebaseService';

const PIE_COLORS = ['#CC0000', '#EF4444', '#F97316', '#F59E0B', '#6B7280', '#9CA3AF'];

const CurrentMonthEventInsightsSection: React.FC = () => {
  const [insights, setInsights] = useState<UpcomingEventInsights | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadInsights = async () => {
      try {
        const data = await fetchUpcomingEventInsights();
        setInsights(data);
      } catch (error) {
        console.error('Error fetching upcoming event insights:', error);
      } finally {
        setLoading(false);
      }
    };

    loadInsights();
  }, []);

  const pieData = useMemo(
    () =>
      (insights?.categorySplit || []).map((item, index) => ({
        id: item.category,
        value: item.count,
        label: item.category,
        color: PIE_COLORS[index % PIE_COLORS.length],
      })),
    [insights],
  );

  if (loading) {
    return (
      <div className="mb-8 grid grid-cols-1 gap-4 xl:grid-cols-2">
        <div className="rounded-xl border border-gray-200 bg-white p-6 text-sm text-gray-500 shadow-sm">
          Loading top events...
        </div>
        <div className="rounded-xl border border-gray-200 bg-white p-6 text-sm text-gray-500 shadow-sm">
          Loading category split...
        </div>
      </div>
    );
  }

  return (
    <div className="mb-8 grid grid-cols-1 items-stretch gap-4 xl:grid-cols-2">
      <div className="h-full rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <div className="mb-4">
          <h2 className="text-lg font-medium text-gray-600">Upcoming Events by Signups</h2>
          <p className="mt-1 text-sm text-gray-500">
            All upcoming events, sorted in ascending signup order.
          </p>
        </div>

        {insights && insights.topEvents.length > 0 ? (
          <div className="max-h-[420px] overflow-y-auto overflow-x-hidden pr-3">
            <table className="min-w-full text-left text-sm">
              <thead>
                <tr className="border-b border-gray-200 text-gray-500">
                  <th className="w-12 pb-3 pr-4 font-medium">#</th>
                  <th className="pb-3 pr-4 font-medium">Event</th>
                  <th className="pb-3 pr-4 font-medium">Category</th>
                  <th className="w-24 pb-3 text-right font-medium">Signups</th>
                </tr>
              </thead>
              <tbody>
                {insights.topEvents.map((event, index) => (
                  <tr key={event.eventID} className="border-b border-gray-100 last:border-b-0">
                    <td className="py-3 pr-4 text-gray-500">{index + 1}</td>
                    <td className="py-3 pr-4 font-medium text-sidebar-grey">{event.eventTitle}</td>
                    <td className="py-3 pr-4 text-gray-500">{event.categories.join(', ')}</td>
                    <td className="py-3 text-right font-semibold text-bured">{event.signupCount}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <p className="text-sm text-gray-500">No upcoming event data found.</p>
        )}
      </div>

      <div className="flex h-full flex-col rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <div className="mb-4">
          <h2 className="text-lg font-medium text-gray-600">Event Category Split</h2>
          <p className="mt-1 text-sm text-gray-500">
            Category distribution across all upcoming events.
          </p>
        </div>

        {pieData.length > 0 ? (
          <div className="flex h-full flex-col rounded-xl border border-gray-200 bg-gray-50 px-4 py-4">
            <div className="flex flex-1 items-center justify-center">
              <PieChart
                width={420}
                height={320}
                series={[
                  {
                    data: pieData,
                    innerRadius: 56,
                    outerRadius: 112,
                    paddingAngle: 2,
                    cornerRadius: 4,
                    cx: 210,
                    cy: 150,
                  },
                ]}
                margin={{ top: 10, right: 10, bottom: 10, left: 10 }}
                slotProps={{ legend: { hidden: true } }}
              />
            </div>

            <div className="mt-4 flex flex-wrap justify-center gap-x-4 gap-y-2">
              {pieData.map((item) => (
                <div key={item.id} className="flex items-center gap-2 text-xs text-gray-600">
                  <span
                    className="inline-block h-3 w-3 rounded-sm"
                    style={{ backgroundColor: item.color }}
                  />
                  <span>{item.label}</span>
                </div>
              ))}
            </div>
          </div>
        ) : (
          <p className="text-sm text-gray-500">No upcoming event categories found.</p>
        )}
      </div>
    </div>
  );
};

export default CurrentMonthEventInsightsSection;
