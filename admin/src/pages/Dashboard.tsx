import { useCallback, useEffect, useState } from 'react';
import {
  Activity, ArrowUpRight, Clock3, MapPin, RefreshCw, Route, ShieldCheck,
  Smartphone, Users,
} from 'lucide-react';
import apiClient from '../api/client';

interface AdminStats {
  totalUsers: number;
  totalDevices: number;
  onlineDevices: number;
  recordedTracks: number;
}

interface ActivityItem {
  id: string;
  type: string;
  description: string;
  userName: string;
  timestamp: string;
}

const metricCards = [
  { key: 'totalUsers', label: 'អ្នកប្រើប្រាស់សរុប', english: 'Total users', icon: Users, tint: 'bg-blue-50 text-blue-600 dark:bg-blue-500/10 dark:text-blue-300' },
  { key: 'totalDevices', label: 'ឧបករណ៍បានភ្ជាប់', english: 'Registered devices', icon: Smartphone, tint: 'bg-violet-50 text-violet-600 dark:bg-violet-500/10 dark:text-violet-300' },
  { key: 'onlineDevices', label: 'កំពុងដំណើរការ', english: 'Online in last 5 min', icon: Activity, tint: 'bg-emerald-50 text-emerald-600 dark:bg-emerald-500/10 dark:text-emerald-300' },
  { key: 'recordedTracks', label: 'ផ្លូវដែលបានកត់ត្រា', english: 'Recorded tracks', icon: Route, tint: 'bg-amber-50 text-amber-600 dark:bg-amber-500/10 dark:text-amber-300' },
] as const;

function formatTime(value: string) {
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? '—' : date.toLocaleString(undefined, { dateStyle: 'medium', timeStyle: 'short' });
}

export default function Dashboard() {
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [activity, setActivity] = useState<ActivityItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadDashboard = useCallback(async () => {
    setLoading(true);
    setError('');
    const [statsResult, activityResult] = await Promise.allSettled([
      apiClient.get<{ data: AdminStats }>('/admin/stats'),
      apiClient.get<{ data: ActivityItem[] }>('/admin/activity'),
    ]);
    if (statsResult.status === 'fulfilled') setStats(statsResult.value.data.data);
    else setError((statsResult.reason as any)?.response?.data?.message || 'មិនអាចទាញយកស្ថិតិពី server បានទេ');
    if (activityResult.status === 'fulfilled') setActivity(activityResult.value.data.data.slice(0, 8));
    else setActivity([]);
    setLoading(false);
  }, []);

  useEffect(() => { void loadDashboard(); }, [loadDashboard]);

  const activePercent = stats?.totalDevices
    ? Math.min(100, Math.round((stats.onlineDevices / stats.totalDevices) * 100))
    : 0;

  return (
    <div className="dashboard-enter space-y-6 sm:space-y-8">
      <section className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-primary-700 via-primary-600 to-teal-500 px-6 py-7 text-white shadow-lg shadow-primary-900/10 sm:px-8 sm:py-9">
        <div className="absolute -right-10 -top-24 h-64 w-64 rounded-full border-[36px] border-white/10" />
        <div className="absolute -bottom-32 right-36 h-56 w-56 rounded-full bg-white/5 blur-2xl" />
        <div className="relative flex flex-wrap items-end justify-between gap-5">
          <div>
            <p className="mb-2 text-sm font-medium text-white/75">SMARTGPS · ADMIN</p>
            <h1 className="khmer-font text-2xl font-bold sm:text-3xl">ផ្ទាំងគ្រប់គ្រង</h1>
            <p className="mt-2 max-w-xl text-sm text-white/80">ទិដ្ឋភាពសង្ខេបនៃអ្នកប្រើ ឧបករណ៍ និងសកម្មភាពថ្មីៗ</p>
          </div>
          <button
            type="button"
            onClick={() => void loadDashboard()}
            disabled={loading}
            className="inline-flex items-center gap-2 rounded-xl border border-white/25 bg-white/10 px-4 py-2.5 text-sm font-semibold backdrop-blur transition hover:bg-white/20 disabled:opacity-60"
          >
            <RefreshCw size={16} className={loading ? 'animate-spin' : ''} /> ធ្វើបច្ចុប្បន្នភាព
          </button>
        </div>
      </section>

      {error && <div role="alert" className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700 dark:border-red-900 dark:bg-red-950/40 dark:text-red-300">{error}</div>}

      <section aria-label="Live statistics" className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {metricCards.map(({ key, label, english, icon: Icon, tint }, index) => (
          <article key={key} style={{ animationDelay: `${index * 70}ms` }} className="metric-card rounded-2xl border border-gray-100 bg-white p-5 shadow-sm transition duration-200 hover:-translate-y-1 hover:shadow-lg dark:border-gray-800 dark:bg-gray-800 sm:p-6">
            <div className="flex items-start justify-between gap-3">
              <div>
                <p className="khmer-font text-sm font-medium text-gray-500 dark:text-gray-400">{label}</p>
                <p className="mt-1 text-xs text-gray-400">{english}</p>
              </div>
              <span className={`rounded-xl p-3 ${tint}`}><Icon size={21} /></span>
            </div>
            <div className="mt-6 flex items-end justify-between">
              <p className="text-3xl font-bold tracking-tight text-gray-900 dark:text-white">
                {loading && !stats ? <span className="inline-block h-9 w-20 animate-pulse rounded-lg bg-gray-100 dark:bg-gray-700" /> : (stats?.[key] ?? 0).toLocaleString()}
              </p>
              <span className="text-xs text-gray-400">Live data</span>
            </div>
          </article>
        ))}
      </section>

      <section className="grid grid-cols-1 gap-5 xl:grid-cols-3">
        <article className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-800 sm:p-6 xl:col-span-1">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="khmer-font text-lg font-bold text-gray-900 dark:text-white">ស្ថានភាពប្រព័ន្ធ</h2>
              <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">ឧបករណ៍សកម្មក្នុងរយៈពេល ៥ នាទី</p>
            </div>
            <span className="rounded-xl bg-emerald-50 p-3 text-emerald-600 dark:bg-emerald-500/10 dark:text-emerald-300"><ShieldCheck size={21} /></span>
          </div>
          <div className="mt-7 flex items-baseline gap-2">
            <span className="text-4xl font-bold text-gray-900 dark:text-white">{loading && !stats ? '—' : `${activePercent}%`}</span>
            <span className="text-sm text-gray-500">online</span>
          </div>
          <div className="mt-4 h-2.5 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-700">
            <div className="h-full rounded-full bg-gradient-to-r from-emerald-400 to-teal-500 transition-all duration-700" style={{ width: `${activePercent}%` }} />
          </div>
          <div className="mt-3 flex justify-between text-sm text-gray-500 dark:text-gray-400">
            <span>{stats?.onlineDevices ?? 0} online</span><span>{stats?.totalDevices ?? 0} total</span>
          </div>
          <div className="mt-6 rounded-xl bg-gray-50 p-4 dark:bg-gray-900/60">
            <div className="flex items-center gap-3">
              <span className="rounded-lg bg-white p-2 text-primary-600 shadow-sm dark:bg-gray-800 dark:text-primary-300"><MapPin size={18} /></span>
              <div><p className="text-sm font-semibold text-gray-800 dark:text-gray-100">GPS device activity</p><p className="text-xs text-gray-500">Based on latest device heartbeat</p></div>
              <ArrowUpRight size={16} className="ml-auto text-gray-400" />
            </div>
          </div>
        </article>

        <article className="rounded-2xl border border-gray-100 bg-white shadow-sm dark:border-gray-800 dark:bg-gray-800 xl:col-span-2">
          <div className="flex items-center justify-between border-b border-gray-100 px-5 py-5 dark:border-gray-700 sm:px-6">
            <div>
              <h2 className="khmer-font text-lg font-bold text-gray-900 dark:text-white">សកម្មភាពថ្មីៗ</h2>
              <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">ព្រឹត្តិការណ៍ពិតពីឧបករណ៍ និងផ្លូវ GPS</p>
            </div>
            <Clock3 size={19} className="text-gray-400" />
          </div>
          {activity.length ? (
            <div className="divide-y divide-gray-100 dark:divide-gray-700">
              {activity.map((item) => (
                <div key={item.id} className="flex items-start gap-3 px-5 py-4 transition-colors hover:bg-gray-50/80 dark:hover:bg-gray-700/30 sm:px-6">
                  <span className={`mt-0.5 rounded-lg p-2 ${item.type === 'location' ? 'bg-teal-50 text-teal-600 dark:bg-teal-500/10 dark:text-teal-300' : 'bg-blue-50 text-blue-600 dark:bg-blue-500/10 dark:text-blue-300'}`}>
                    {item.type === 'location' ? <MapPin size={17} /> : <Route size={17} />}
                  </span>
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-semibold text-gray-800 dark:text-gray-100">{item.description}</p>
                    <p className="mt-1 text-xs text-gray-500">{item.userName}</p>
                  </div>
                  <time className="shrink-0 pt-1 text-right text-xs text-gray-400">{formatTime(item.timestamp)}</time>
                </div>
              ))}
            </div>
          ) : (
            <div className="flex min-h-48 flex-col items-center justify-center px-6 text-center">
              <span className="rounded-2xl bg-gray-50 p-4 text-gray-400 dark:bg-gray-900"><Activity size={24} /></span>
              <p className="khmer-font mt-3 text-sm font-medium text-gray-600 dark:text-gray-300">មិនទាន់មានសកម្មភាពថ្មីទេ</p>
              <p className="mt-1 text-xs text-gray-400">សកម្មភាពនឹងបង្ហាញនៅទីនេះ ពេលឧបករណ៍ផ្ញើទិន្នន័យមក server</p>
            </div>
          )}
        </article>
      </section>
    </div>
  );
}
