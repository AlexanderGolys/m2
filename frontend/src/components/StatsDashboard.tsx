import { useEffect, useState } from 'react';
import { getStats, StatsResponse } from '../lib/api';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';

export function StatsDashboard() {
  const [stats, setStats] = useState<StatsResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    getStats()
      .then(setStats)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div className="p-4 text-white">Loading stats...</div>;
  if (error) return <div className="p-4 text-red-500">Error loading stats: {error}</div>;
  if (!stats) return <div className="p-4 text-white">No stats available</div>;

  // Sort dates reverse chronologically
  const dates = Object.keys(stats.requests_per_day).sort().reverse();

  return (
    <div className="p-4 space-y-4 text-white">
      <h2 className="text-2xl font-bold">Usage Statistics</h2>
      <div className="grid gap-4 md:grid-cols-2">
        <Card className="bg-slate-800 border-slate-700 text-white">
          <CardHeader>
            <CardTitle>Requests per Day</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {dates.length === 0 ? (
                <div className="text-slate-400">No data yet</div>
              ) : (
                dates.map(date => (
                  <div key={date} className="flex justify-between border-b border-slate-700 pb-2">
                    <span>{date}</span>
                    <span className="font-mono">{stats.requests_per_day[date]}</span>
                  </div>
                ))
              )}
            </div>
          </CardContent>
        </Card>

        <Card className="bg-slate-800 border-slate-700 text-white">
          <CardHeader>
            <CardTitle>Unique Users per Day</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {dates.length === 0 ? (
                <div className="text-slate-400">No data yet</div>
              ) : (
                dates.map(date => (
                  <div key={date} className="flex justify-between border-b border-slate-700 pb-2">
                    <span>{date}</span>
                    <span className="font-mono">
                      {stats.unique_users_per_day[date]?.length || 0}
                    </span>
                  </div>
                ))
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
