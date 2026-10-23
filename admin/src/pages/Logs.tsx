import { useEffect, useState } from 'react';
import { Activity, Route, MapPin } from 'lucide-react';
import apiClient from '../api/client';

interface ActivityRecord {
  id: string;
  type: string;
  description: string;
  userName: string;
  timestamp: string;
}

export default function Logs() {
  const [items, setItems] = useState<ActivityRecord[]>([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    apiClient
      .get<{ data: ActivityRecord[] }>('/admin/activity')
      .then((response) => {
        if (!cancelled) setItems(response.data.data);
      })
      .catch((requestError: any) => {
        if (!cancelled) setError(requestError.response?.data?.message || 'មិនអាចទាញយកសកម្មភាពបានទេ');
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <div className="space-y-4">
      <div>
        <h2 className="text-2xl font-bold text-gray-900 dark:text-white khmer-font">សកម្មភាពថ្មីៗ</h2>
        <p className="mt-1 text-sm text-gray-600 dark:text-gray-400 khmer-font">កំណត់ត្រាពីការផ្ញើទីតាំង និងការកត់ត្រាផ្លូវក្នុង ៣០ ថ្ងៃចុងក្រោយ។</p>
      </div>
      {error && <p role="alert" className="rounded-lg bg-red-50 p-4 text-sm text-red-700">{error}</p>}
      <div className="divide-y divide-gray-100 rounded-lg bg-white shadow dark:divide-gray-700 dark:bg-gray-800">
        {loading ? (
          <p className="p-6 text-gray-500">កំពុងទាញយកទិន្នន័យ…</p>
        ) : items.length === 0 ? (
          <div className="flex flex-col items-center gap-2 p-12 text-center text-gray-500">
            <Activity className="h-10 w-10" />
            <p className="font-medium khmer-font">មិនទាន់មានសកម្មភាពពិតទេ</p>
            <p className="text-sm khmer-font">សកម្មភាពនឹងបង្ហាញក្រោយពេលអ្នកប្រើចាប់ផ្តើមផ្ញើទីតាំង ឬកត់ត្រាផ្លូវ។</p>
          </div>
        ) : (
          items.map((item) => {
            const Icon = item.type === 'location' ? MapPin : Route;
            return (
              <div key={item.id} className="flex items-center gap-4 p-5">
                <div className="rounded-full bg-teal-50 p-3 text-teal-700 dark:bg-teal-900/30 dark:text-teal-300"><Icon className="h-5 w-5" /></div>
                <div className="min-w-0 flex-1">
                  <p className="font-medium text-gray-900 dark:text-white">{item.description}</p>
                  <p className="text-sm text-gray-500 dark:text-gray-400">{item.userName}</p>
                </div>
                <time className="shrink-0 text-xs text-gray-500 dark:text-gray-400" dateTime={item.timestamp}>{new Date(item.timestamp).toLocaleString()}</time>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}
