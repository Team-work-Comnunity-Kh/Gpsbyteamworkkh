import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/services/api_service.dart';
import 'providers/track_recording_provider.dart';

class TracksScreen extends ConsumerStatefulWidget {
  const TracksScreen({super.key});

  @override
  ConsumerState<TracksScreen> createState() => _TracksScreenState();
}

class _TracksScreenState extends ConsumerState<TracksScreen> {
  List<Map<String, dynamic>> _tracks = [];
  List<Map<String, dynamic>> _parcels = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ref.read(apiServiceProvider).getTracks(),
        ref.read(apiServiceProvider).getParcels(),
      ]);
      if (!mounted) return;
      setState(() {
        _tracks = results[0];
        _parcels = results[1];
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recording = ref.watch(trackRecordingProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ផ្លូវ និងដីឡូត៍របស់ខ្ញុំ'),
          actions: [
            IconButton(
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'ធ្វើឱ្យថ្មី',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.route), text: 'ផ្លូវ GPS'),
              Tab(icon: Icon(Icons.landscape), text: 'ដីឡូត៍'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (recording.isRecording)
              MaterialBanner(
                content: Text('កំពុងកត់ត្រា ${recording.trackName ?? 'ផ្លូវ'} · ${recording.pointCount} ចំណុច'),
                leading: const Icon(Icons.fiber_manual_record, color: Colors.red),
                actions: [
                  TextButton(
                    onPressed: () async {
                      try {
                        await ref.read(trackRecordingProvider.notifier).stop();
                        await _load();
                      } catch (error) {
                        _showMessage(error.toString());
                      }
                    },
                    child: const Text('បញ្ឈប់'),
                  ),
                ],
              ),
            if (recording.error != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(recording.error!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTrackList(),
                  _buildParcelList(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: recording.isStarting
              ? null
              : recording.isRecording
                  ? () async {
                      try {
                        await ref.read(trackRecordingProvider.notifier).stop();
                        await _load();
                      } catch (error) {
                        _showMessage(error.toString());
                      }
                    }
                  : _startTrack,
          backgroundColor: recording.isRecording ? AppColors.error : AppColors.primary,
          icon: Icon(recording.isRecording ? Icons.stop : Icons.fiber_manual_record),
          label: Text(recording.isRecording ? 'បញ្ឈប់កត់ត្រា' : 'ចាប់ផ្តើមកត់ត្រា'),
        ),
      ),
    );
  }

  Widget _buildTrackList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _errorView();
    if (_tracks.isEmpty) return _emptyView(Icons.route, 'មិនទាន់មានផ្លូវ GPS');
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        itemCount: _tracks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final track = _tracks[index];
          final distance = (track['totalDistanceMeters'] as num?)?.toDouble() ?? 0;
          final count = (track['pointCount'] as num?)?.toInt() ?? 0;
          final recording = track['isRecording'] == true;
          return Card(
            child: ListTile(
              leading: Icon(recording ? Icons.fiber_manual_record : Icons.route,
                  color: recording ? Colors.red : AppColors.primary),
              title: Text(track['name'] as String? ?? 'ផ្លូវ GPS'),
              subtitle: Text('${(distance / 1000).toStringAsFixed(2)} km · $count ចំណុច · ${_date(track['startTime'])}'),
              trailing: IconButton(
                tooltip: 'លុបផ្លូវ',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteTrack(track['id'] as String),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParcelList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _errorView();
    if (_parcels.isEmpty) return _emptyView(Icons.landscape, 'មិនទាន់មានដីឡូត៍ដែលបានរក្សាទុក');
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        itemCount: _parcels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final parcel = _parcels[index];
          final area = (parcel['areaHectares'] as num?)?.toDouble() ?? 0;
          final favorite = parcel['isFavorite'] == true;
          return Card(
            child: ListTile(
              leading: const Icon(Icons.landscape, color: AppColors.primary),
              title: Text(parcel['name'] as String? ?? 'ដីឡូត៍'),
              subtitle: Text('${area.toStringAsFixed(3)} ha · ${_date(parcel['createdAt'])}'),
              trailing: Wrap(
                spacing: 0,
                children: [
                  IconButton(
                    tooltip: favorite ? 'ដកចេញពីចំណូលចិត្ត' : 'ដាក់ចំណូលចិត្ត',
                    icon: Icon(favorite ? Icons.star : Icons.star_border, color: Colors.amber),
                    onPressed: () => _toggleFavorite(parcel['id'] as String),
                  ),
                  IconButton(
                    tooltip: 'លុបដីឡូត៍',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteParcel(parcel['id'] as String),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 42),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: const Text('ព្យាយាមម្តងទៀត')),
          ]),
        ),
      );

  Widget _emptyView(IconData icon, String message) => RefreshIndicator(
        onRefresh: _load,
        child: ListView(children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * .28),
          Icon(icon, size: 54, color: Colors.grey),
          const SizedBox(height: 12),
          Center(child: Text(message)),
        ]),
      );

  Future<void> _startTrack() async {
    final controller = TextEditingController(text: 'GPS ${DateTime.now().toLocal().toString().substring(0, 16)}');
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ដាក់ឈ្មោះផ្លូវ'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('បោះបង់')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('ចាប់ផ្តើម')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    try {
      await ref.read(trackRecordingProvider.notifier).start(name);
      await _load();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _deleteTrack(String id) async {
    if (!await _confirm('លុបផ្លូវ GPS នេះ?')) return;
    try {
      await ref.read(apiServiceProvider).deleteTrack(id);
      await _load();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _deleteParcel(String id) async {
    if (!await _confirm('លុបដីឡូត៍នេះ?')) return;
    try {
      await ref.read(apiServiceProvider).deleteParcel(id);
      await _load();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _toggleFavorite(String id) async {
    try {
      await ref.read(apiServiceProvider).toggleParcelFavorite(id);
      await _load();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<bool> _confirm(String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('បោះបង់')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('យល់ព្រម')),
          ],
        ),
      ) ?? false;

  String _date(dynamic value) {
    if (value == null) return '—';
    final date = DateTime.tryParse(value.toString())?.toLocal();
    return date == null ? '—' : MaterialLocalizations.of(context).formatMediumDate(date);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
