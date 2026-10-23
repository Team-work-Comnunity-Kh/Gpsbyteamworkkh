import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/services/api_service.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  List<Map<String, dynamic>> _devices = [];
  List<Map<String, dynamic>> _pairs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = ref.read(apiServiceProvider);
      await api.registerCurrentDevice();
      final devices = await api.getDevices();
      final paired = await Future.wait(devices.map((device) => api.getPairedDevices(device['id'] as String)));
      if (mounted) setState(() {
        _devices = devices;
        _pairs = paired.expand((items) => items).toList();
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createCode(Map<String, dynamic> device) async {
    try {
      final result = await ref.read(apiServiceProvider).createPairingCode(device['id'] as String);
      if (!mounted) return;
      final code = result['pairingCode']?.toString() ?? '';
      final expires = DateTime.tryParse(result['expiresAt']?.toString() ?? '')?.toLocal();
      await showDialog<void>(context: context, builder: (context) => AlertDialog(
        title: const Text('Pair another device'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Enter this code on the other signed-in device. Pairing shares this device location.'),
          const SizedBox(height: 16),
          SelectableText(code, style: Theme.of(context).textTheme.headlineMedium),
          if (expires != null) Text('Expires ${TimeOfDay.fromDateTime(expires).format(context)}'),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ));
    } catch (error) { _message(error.toString()); }
  }

  void _message(String value) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My devices'), actions: [
      IconButton(onPressed: () => context.push('/devices/pair'), icon: const Icon(Icons.link), tooltip: 'Pair a device'),
      IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
    ]),
    body: _loading ? const Center(child: CircularProgressIndicator()) : _error != null
      ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off), const SizedBox(height: 12), Text(_error!, textAlign: TextAlign.center),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ])))
      : RefreshIndicator(onRefresh: _load, child: _devices.isEmpty
        ? ListView(children: const [SizedBox(height: 160), Icon(Icons.devices, size: 56), Center(child: Text('No devices registered'))])
        : ListView.separated(padding: const EdgeInsets.all(16), itemCount: _devices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (context, index) {
          final item = _devices[index];
          final lat = item['lastLatitude']; final lng = item['lastLongitude'];
          return Card(child: ListTile(
            leading: Icon(item['isOnline'] == true ? Icons.phone_android : Icons.phone_disabled,
                color: item['isOnline'] == true ? Colors.green : Colors.grey),
            title: Text(item['deviceName']?.toString() ?? 'SmartGPS device'),
            subtitle: Text(_deviceSubtitle(item, lat, lng)),
            trailing: IconButton(icon: const Icon(Icons.qr_code_2), tooltip: 'Create pairing code', onPressed: () => _createCode(item)),
          ));
        })),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => context.push('/devices/pair'), icon: const Icon(Icons.add_link), label: const Text('Pair device')),
  );

  String _deviceSubtitle(Map<String, dynamic> device, dynamic lat, dynamic lng) {
    final shared = _pairs.where((pair) => pair['sourceDeviceId'] == device['id'] || pair['targetDeviceId'] == device['id']);
    final other = shared.map((pair) {
      final source = Map<String, dynamic>.from(pair['sourceDevice'] as Map? ?? {});
      final target = Map<String, dynamic>.from(pair['targetDevice'] as Map? ?? {});
      return pair['sourceDeviceId'] == device['id'] ? target : source;
    }).where((item) => item.isNotEmpty).map((item) {
      final pLat = item['lastLatitude']; final pLng = item['lastLongitude'];
      return '${item['deviceName'] ?? 'Paired device'}${pLat != null && pLng != null ? ' · $pLat, $pLng' : ''}';
    }).join('\n');
    final own = lat != null && lng != null ? 'Last location: $lat, $lng' : 'No location recorded yet';
    return other.isEmpty ? own : '$own\nShared: $other';
  }
}
