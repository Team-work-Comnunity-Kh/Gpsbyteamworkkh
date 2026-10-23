import { FormEvent, useCallback, useEffect, useState } from 'react';
import { RefreshCw, Search, Users as UsersIcon } from 'lucide-react';
import apiClient from '../api/client';

interface UserRecord {
  id: string;
  email: string | null;
  phone: string | null;
  firstName: string;
  lastName: string;
  role: string;
  emailVerified: boolean;
  phoneVerified: boolean;
  isActive: boolean;
  lastLoginAt: string | null;
  createdAt: string;
}

interface UsersResponse {
  items: UserRecord[];
  total: number;
  totalPages: number;
}

export default function Users() {
  const [users, setUsers] = useState<UserRecord[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [searchInput, setSearchInput] = useState('');
  const [filters, setFilters] = useState({ search: '', role: '', active: '' });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadUsers = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const response = await apiClient.get<{ data: UsersResponse }>('/users', {
        params: { page, limit: 20, ...filters },
      });
      const result = response.data.data;
      setUsers(result.items);
      setTotal(result.total);
      setTotalPages(Math.max(result.totalPages, 1));
    } catch (err: any) {
      setError(err.response?.data?.message || 'មិនអាចទាញបញ្ជីអ្នកប្រើប្រាស់បានទេ');
    } finally {
      setLoading(false);
    }
  }, [filters, page]);

  useEffect(() => {
    void loadUsers();
  }, [loadUsers]);

  const applySearch = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setPage(1);
    setFilters((current) => ({ ...current, search: searchInput.trim() }));
  };

  const updateFilter = (key: 'role' | 'active', value: string) => {
    setPage(1);
    setFilters((current) => ({ ...current, [key]: value }));
  };

  const formatDate = (value: string | null) =>
    value ? new Date(value).toLocaleString('km-KH', { dateStyle: 'medium' }) : 'មិនទាន់ចូល';

  return (
    <section className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h2 className="khmer-font text-2xl font-bold text-gray-900 dark:text-white">អ្នកប្រើប្រាស់</h2>
          <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
            អ្នកប្រើប្រាស់សរុប {total.toLocaleString('km-KH')} នាក់
          </p>
        </div>
        <button
          type="button"
          onClick={() => void loadUsers()}
          disabled={loading}
          className="inline-flex items-center gap-2 rounded-lg border border-gray-200 bg-white px-4 py-2 text-sm font-medium text-gray-700 shadow-sm hover:bg-gray-50 disabled:opacity-50 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-200 dark:hover:bg-gray-700"
        >
          <RefreshCw size={16} className={loading ? 'animate-spin' : ''} /> ធ្វើឱ្យថ្មី
        </button>
      </div>

      <form onSubmit={applySearch} className="flex flex-wrap gap-3 rounded-xl bg-white p-4 shadow-sm dark:bg-gray-800">
        <div className="relative min-w-56 flex-1">
          <Search size={17} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            value={searchInput}
            onChange={(event) => setSearchInput(event.target.value)}
            placeholder="ស្វែងរកឈ្មោះ អ៊ីមែល ឬលេខទូរស័ព្ទ"
            className="w-full rounded-lg border border-gray-200 bg-white py-2 pl-10 pr-3 text-sm outline-none focus:border-primary-500 focus:ring-2 focus:ring-primary-100 dark:border-gray-700 dark:bg-gray-900 dark:text-white"
          />
        </div>
        <select
          value={filters.role}
          onChange={(event) => updateFilter('role', event.target.value)}
          aria-label="តួនាទី"
          className="rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm dark:border-gray-700 dark:bg-gray-900 dark:text-white"
        >
          <option value="">គ្រប់តួនាទី</option>
          <option value="user">អ្នកប្រើប្រាស់</option>
          <option value="admin">អ្នកគ្រប់គ្រង</option>
        </select>
        <select
          value={filters.active}
          onChange={(event) => updateFilter('active', event.target.value)}
          aria-label="ស្ថានភាពគណនី"
          className="rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm dark:border-gray-700 dark:bg-gray-900 dark:text-white"
        >
          <option value="">គ្រប់ស្ថានភាព</option>
          <option value="true">សកម្ម</option>
          <option value="false">អសកម្ម</option>
        </select>
        <button type="submit" className="rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700">
          ស្វែងរក
        </button>
      </form>

      <div className="overflow-hidden rounded-xl bg-white shadow-sm dark:bg-gray-800">
        {error ? (
          <div role="alert" className="p-8 text-center text-sm text-red-600 dark:text-red-400">{error}</div>
        ) : loading ? (
          <div className="p-12 text-center text-sm text-gray-500">កំពុងទាញទិន្នន័យ…</div>
        ) : users.length === 0 ? (
          <div className="flex flex-col items-center gap-2 p-12 text-center text-gray-500">
            <UsersIcon size={28} />
            <span>មិនមានអ្នកប្រើប្រាស់ត្រូវនឹងលក្ខខណ្ឌស្វែងរកទេ</span>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-100 text-sm dark:divide-gray-700">
              <thead className="bg-gray-50 text-left text-xs uppercase text-gray-500 dark:bg-gray-900/60 dark:text-gray-400">
                <tr>
                  <th className="px-5 py-3 font-medium">អ្នកប្រើប្រាស់</th>
                  <th className="px-5 py-3 font-medium">ទំនាក់ទំនង</th>
                  <th className="px-5 py-3 font-medium">តួនាទី</th>
                  <th className="px-5 py-3 font-medium">ស្ថានភាព</th>
                  <th className="px-5 py-3 font-medium">ថ្ងៃបង្កើត</th>
                  <th className="px-5 py-3 font-medium">ចូលចុងក្រោយ</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-700">
                {users.map((user) => (
                  <tr key={user.id} className="hover:bg-gray-50/70 dark:hover:bg-gray-700/30">
                    <td className="whitespace-nowrap px-5 py-4">
                      <div className="font-medium text-gray-900 dark:text-white">{user.firstName} {user.lastName}</div>
                      <div className="mt-1 text-xs text-gray-400">{user.id.slice(0, 8)}</div>
                    </td>
                    <td className="px-5 py-4 text-gray-600 dark:text-gray-300">
                      <div>{user.email || '—'}</div>
                      <div className="mt-1 text-xs text-gray-400">{user.phone || '—'}</div>
                    </td>
                    <td className="whitespace-nowrap px-5 py-4">
                      <span className={`rounded-full px-2.5 py-1 text-xs font-medium ${user.role === 'admin' ? 'bg-violet-100 text-violet-700 dark:bg-violet-900/40 dark:text-violet-300' : 'bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-300'}`}>
                        {user.role === 'admin' ? 'អ្នកគ្រប់គ្រង' : 'អ្នកប្រើប្រាស់'}
                      </span>
                    </td>
                    <td className="whitespace-nowrap px-5 py-4">
                      <span className={`rounded-full px-2.5 py-1 text-xs font-medium ${user.isActive ? 'bg-green-100 text-green-700 dark:bg-green-900/40 dark:text-green-300' : 'bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-300'}`}>
                        {user.isActive ? 'សកម្ម' : 'អសកម្ម'}
                      </span>
                    </td>
                    <td className="whitespace-nowrap px-5 py-4 text-gray-600 dark:text-gray-300">{formatDate(user.createdAt)}</td>
                    <td className="whitespace-nowrap px-5 py-4 text-gray-600 dark:text-gray-300">{formatDate(user.lastLoginAt)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        <div className="flex items-center justify-between border-t border-gray-100 px-5 py-3 text-sm text-gray-500 dark:border-gray-700 dark:text-gray-400">
          <span>ទំព័រ {page} / {totalPages}</span>
          <div className="flex gap-2">
            <button type="button" disabled={page <= 1 || loading} onClick={() => setPage((current) => current - 1)} className="rounded-md border border-gray-200 px-3 py-1.5 disabled:opacity-40 dark:border-gray-700">មុន</button>
            <button type="button" disabled={page >= totalPages || loading} onClick={() => setPage((current) => current + 1)} className="rounded-md border border-gray-200 px-3 py-1.5 disabled:opacity-40 dark:border-gray-700">បន្ទាប់</button>
          </div>
        </div>
      </div>
    </section>
  );
}
