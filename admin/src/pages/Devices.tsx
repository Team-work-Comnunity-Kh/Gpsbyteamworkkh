import { useCallback, useEffect, useState } from 'react';
import { RefreshCw, Smartphone } from 'lucide-react';
import apiClient from '../api/client';

interface DeviceRecord {
  id: string;
  deviceId: string;
  deviceName: string;
  deviceModel: string | null;
  appVersion: string | null;
  isOnline: boolean;
  isTracking: boolean;
  batteryLevel: number | null;
  lastLocationTime: string | null;
  user: { firstName: string; lastName: string; email: string | null; phone: string | null } | null;
}

export default function Devices() {
  const [devices, setDevices] = useState<DeviceRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadDevices = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const response = await apiClient.get<{ data: DeviceRecord[] }>('/admin/devices');
      setDevices(response.data.data);
    } catch (requestError: any) {
      setError(requestError.response?.data?.message || 'មិនអាចទាញយកបញ្ជីឧបករណ៍បានទេ');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadDevices();
  }, [loadDevices]);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white khmer-font">ឧបករណ៍</h2>
          <p className="mt-1 text-sm text-gray-600 dark:text-gray-400 khmer-font">បញ្ជីឧបករណ៍ដែលអ្នកប្រើបានភ្ជាប់</p>
        </div>
        <button onClick={() => void loadDevices()} disabled={loading} className="inline-flex items-center gap-2 rounded-lg border px-3 py-2 text-sm disabled:opacity-50">
          <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} /> ធ្វើបច្ចុប្បន្នភាព
        </button>
      </div>

      {error && <p role="alert" className="rounded-lg bg-red-50 p-4 text-sm text-red-700">{error}</p>}
      <div className="overflow-x-auto rounded-lg bg-white shadow dark:bg-gray-800">
        {loading && devices.length === 0 ? (
          <p className="p-6 text-gray-500">កំពុងទាញយកទិន្នន័យ…</p>
        ) : devices.length === 0 ? (
          <div className="flex flex-col items-center gap-2 p-12 text-center text-gray-500">
            <Smartphone className="h-10 w-10" />
            <p className="font-medium khmer-font">មិនទាន់មានឧបករណ៍បានចុះឈ្មោះទេ</p>
            <p className="text-sm khmer-font">ឧបករណ៍នឹងបង្ហាញនៅទីនេះក្រោយពេលអ្នកប្រើចូល app និងភ្ជាប់ឧបករណ៍។</p>
          </div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200 text-sm dark:divide-gray-700">
            <thead className="bg-gray-50 text-left text-gray-600 dark:bg-gray-700 dark:text-gray-300">
              <tr>{['ឈ្មោះឧបករណ៍', 'ម្ចាស់', 'ម៉ូដែល / App', 'ស្ថានភាព', 'ថ្ម', 'ទីតាំងចុងក្រោយ'].map((label) => <th key={label} className="px-4 py-3 font-medium khmer-font">{label}</th>)}</tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-700">
              {devices.map((device) => (
                <tr key={device.id}>
                  <td className="px-4 py-3 font-medium">{device.deviceName}</td>
                  <td className="px-4 py-3">{device.user?.firstName} {device.user?.lastName}<div className="text-xs text-gray-500">{device.user?.email || device.user?.phone || '—'}</div></td>
                  <td className="px-4 py-3">{device.deviceModel || '—'}<div className="text-xs text-gray-500">{device.appVersion ? `App ${device.appVersion}` : '—'}</div></td>
                  <td className="px-4 py-3"><span className={`rounded-full px-2 py-1 text-xs ${device.isOnline ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'}`}>{device.isOnline ? 'Online' : 'Offline'}</span>{device.isTracking && <span className="ml-2 text-xs text-teal-700">កំពុងតាមដាន</span>}</td>
                  <td className="px-4 py-3">{device.batteryLevel == null ? '—' : `${device.batteryLevel}%`}</td>
                  <td className="px-4 py-3">{device.lastLocationTime ? new Date(device.lastLocationTime).toLocaleString() : 'មិនទាន់មាន'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
