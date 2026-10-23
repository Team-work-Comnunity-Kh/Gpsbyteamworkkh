import { useEffect, useState } from 'react';
import { CircleMarker, MapContainer, Popup, TileLayer } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import apiClient from '../api/client';

interface DeviceLocation {
  id: string;
  deviceName: string;
  latitude: number;
  longitude: number;
  lastLocationTime: string | null;
  isTracking: boolean;
  userName: string;
}

export default function LiveMap() {
  const [locations, setLocations] = useState<DeviceLocation[]>([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    const loadLocations = async () => {
      try {
        const response = await apiClient.get<{ data: DeviceLocation[] }>('/admin/locations');
        if (!cancelled) {
          setLocations(response.data.data);
          setError('');
        }
      } catch (requestError: any) {
        if (!cancelled) setError(requestError.response?.data?.message || 'មិនអាចទាញយកទីតាំងបានទេ');
      } finally {
        if (!cancelled) setLoading(false);
      }
    };

    void loadLocations();
    const timer = window.setInterval(() => void loadLocations(), 30_000);
    return () => {
      cancelled = true;
      window.clearInterval(timer);
    };
  }, []);

  const center: [number, number] = locations.length
    ? [locations[0].latitude, locations[0].longitude]
    : [12.5657, 104.991];

  return (
    <div className="space-y-4">
      <div>
        <h2 className="text-2xl font-bold text-gray-900 dark:text-white khmer-font">ផែនទីទីតាំងឧបករណ៍</h2>
        <p className="mt-1 text-sm text-gray-600 dark:text-gray-400 khmer-font">ទីតាំងចុងក្រោយដែលឧបករណ៍បានផ្ញើមក server។ ទិន្នន័យធ្វើបច្ចុប្បន្នភាពរៀងរាល់ ៣០ វិនាទី។</p>
      </div>
      {error && <p role="alert" className="rounded-lg bg-red-50 p-4 text-sm text-red-700">{error}</p>}
      {!loading && !error && locations.length === 0 && (
        <p className="rounded-lg bg-amber-50 p-4 text-sm text-amber-800 khmer-font">មិនទាន់មានទីតាំងពិតទេ។ សូមចូល app នៅលើឧបករណ៍ និងអនុញ្ញាត Location រួចចាប់ផ្តើមតាមដាន GPS។</p>
      )}
      <div className="h-[65vh] min-h-[420px] overflow-hidden rounded-lg shadow">
        <MapContainer key={`${center[0]}-${center[1]}`} center={center} zoom={locations.length ? 12 : 7} scrollWheelZoom className="h-full w-full">
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          {locations.map((location) => (
            <CircleMarker key={location.id} center={[location.latitude, location.longitude]} radius={9} pathOptions={{ color: '#0f766e', fillColor: '#14b8a6', fillOpacity: 0.85 }}>
              <Popup>
                <strong>{location.deviceName}</strong><br />
                {location.userName}<br />
                {location.isTracking ? 'កំពុងតាមដាន GPS' : 'ទីតាំងចុងក្រោយ'}<br />
                {location.lastLocationTime ? new Date(location.lastLocationTime).toLocaleString() : '—'}
              </Popup>
            </CircleMarker>
          ))}
        </MapContainer>
      </div>
    </div>
  );
}
