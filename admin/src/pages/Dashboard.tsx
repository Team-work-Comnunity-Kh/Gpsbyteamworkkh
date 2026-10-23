import { useEffect, useState } from 'react';
import { Users, Smartphone, MapPin, AlertCircle } from 'lucide-react';
import apiClient from '../api/client';
import {
  LineChart,
  Line,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';

export default function Dashboard() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalDevices: 0,
    activeParcels: 0,
    recentAlerts: 0,
  });

  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      // Simulate API calls
      setStats({
        totalUsers: 1245,
        totalDevices: 3892,
        activeParcels: 567,
        recentAlerts: 23,
      });
    } catch (error) {
      console.error('Failed to fetch stats:', error);
    } finally {
      setLoading(false);
    }
  };

  const chartData = [
    { name: 'មករា', users: 400, devices: 240 },
    { name: 'កុម្ភៈ', users: 300, devices: 139 },
    { name: 'មីនា', users: 200, devices: 980 },
    { name: 'មេសា', users: 278, devices: 390 },
    { name: 'ឧសភា', users: 189, devices: 480 },
    { name: 'មិថុនា', users: 239, devices: 380 },
  ];

  const statsCards = [
    {
      name: 'អ្នកប្រើប្រាស់សរុប',
      value: stats.totalUsers,
      icon: Users,
      color: 'bg-blue-500',
      change: '+12.5%',
    },
    {
      name: 'ឧបករណ៍សរុប',
      value: stats.totalDevices,
      icon: Smartphone,
      color: 'bg-green-500',
      change: '+8.2%',
    },
    {
      name: 'ដីដែលបានវាស់',
      value: stats.activeParcels,
      icon: MapPin,
      color: 'bg-primary-500',
      change: '+23.1%',
    },
    {
      name: 'ការជូនដំណឹង',
      value: stats.recentAlerts,
      icon: AlertCircle,
      color: 'bg-orange-500',
      change: '-5.4%',
    },
  ];

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-500">កំពុងផ្ទុក...</div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statsCards.map((card) => (
          <div
            key={card.name}
            className="bg-white dark:bg-gray-800 rounded-lg shadow p-6"
          >
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600 dark:text-gray-400 khmer-font">
                  {card.name}
                </p>
                <p className="text-3xl font-bold text-gray-900 dark:text-white mt-2">
                  {card.value.toLocaleString()}
                </p>
                <p
                  className={`text-sm mt-2 ${
                    card.change.startsWith('+')
                      ? 'text-green-600'
                      : 'text-red-600'
                  }`}
                >
                  {card.change}
                </p>
              </div>
              <div className={`${card.color} p-3 rounded-lg`}>
                <card.icon className="h-8 w-8 text-white" />
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4 khmer-font">
            អ្នកប្រើប្រាស់ថ្មី និងឧបករណ៍
          </h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Line
                type="monotone"
                dataKey="users"
                stroke="#0FA3A3"
                strokeWidth={2}
              />
              <Line
                type="monotone"
                dataKey="devices"
                stroke="#F97316"
                strokeWidth={2}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4 khmer-font">
            ការប្រើប្រាស់ប្រចាំថ្ងៃ
          </h3>
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Area
                type="monotone"
                dataKey="devices"
                stroke="#0FA3A3"
                fill="#0FA3A3"
                fillOpacity={0.3}
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow">
        <div className="p-6 border-b border-gray-200 dark:border-gray-700">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white khmer-font">
            សកម្មភាពថ្មីៗ
          </h3>
        </div>
        <div className="p-6">
          <div className="space-y-4">
            {[1, 2, 3, 4, 5].map((i) => (
              <div
                key={i}
                className="flex items-center justify-between py-3 border-b border-gray-100 dark:border-gray-700 last:border-0"
              >
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 rounded-full bg-primary-100 dark:bg-primary-900 flex items-center justify-center">
                    <MapPin className="h-5 w-5 text-primary-600 dark:text-primary-400" />
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900 dark:text-white">
                      User {i} បានវាស់ដីថ្មី
                    </p>
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                      {i} នាទីមុន
                    </p>
                  </div>
                </div>
                <span className="text-xs text-gray-500 dark:text-gray-400">
                  2.5 ហិកតា
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
