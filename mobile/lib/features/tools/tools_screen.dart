import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/coordinate_converter.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../shared/providers/auth_provider.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key});

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  UTMCoordinate? _utmResult;
  String? _dmsLat;
  String? _dmsLng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ឧបករណ៍ GPS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Coordinate Converter ──────────────────────────────────
          _SectionCard(
            title: 'បំលែងកូអរដោនេ',
            icon: Icons.swap_horiz,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latController,
                        decoration: const InputDecoration(labelText: 'Latitude'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _lngController,
                        decoration: const InputDecoration(labelText: 'Longitude'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _convertCoordinates,
                  child: const Text('បំលែង'),
                ),
                if (_utmResult != null) ...[
                  const SizedBox(height: 12),
                  _ResultRow(label: 'UTM', value: _utmResult.toString()),
                  _ResultRow(label: 'DMS Lat', value: _dmsLat ?? ''),
                  _ResultRow(label: 'DMS Lng', value: _dmsLng ?? ''),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Compass ──────────────────────────────────────────────
          _SectionCard(
            title: 'ត្រីវិស័យ / Compass',
            icon: Icons.explore,
            child: const _CompassView(),
          ),
          const SizedBox(height: 16),
          if (!kReleaseMode)
            _SectionCard(
              title: 'API server',
              icon: Icons.dns_outlined,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SelectableText(ref.read(authServiceProvider).dio.options.baseUrl),
                const SizedBox(height: 8),
                OutlinedButton.icon(onPressed: _configureServer, icon: const Icon(Icons.edit), label: const Text('Change server')),
              ]),
            ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'គណនី',
            icon: Icons.account_circle_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Builder(builder: (context) {
                  final user = ref.watch(authStateProvider).asData?.value;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user?.displayName.isNotEmpty == true
                        ? user!.displayName
                        : 'SmartGPS account'),
                    subtitle: Text(user?.email ?? user?.phone ?? ''),
                  );
                }),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('ចាកចេញពីគណនី'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ចាកចេញពីគណនី?'),
        content: const Text('អ្នកអាចចូលគណនីវិញបានគ្រប់ពេល។'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('បោះបង់'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.logout),
            label: const Text('ចាកចេញ'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(authStateProvider.notifier).logout();
  }

  void _convertCoordinates() {
    try {
      final lat = double.parse(_latController.text);
      final lng = double.parse(_lngController.text);
      setState(() {
        _utmResult = CoordinateConverter.decimalToUTM(lat, lng);
        _dmsLat = CoordinateConverter.decimalToDMS(lat, isLat: true);
        _dmsLng = CoordinateConverter.decimalToDMS(lng, isLat: false);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ទិន្នន័យមិនត្រឹមត្រូវ')),
      );
    }
  }

  Future<void> _configureServer() async {
    final service = ref.read(authServiceProvider);
    final controller = TextEditingController(text: service.dio.options.baseUrl.replaceFirst(RegExp(r'/api$'), ''));
    final value = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      title: const Text('API server'),
      content: TextField(controller: controller, keyboardType: TextInputType.url,
        decoration: const InputDecoration(labelText: 'Server URL', hintText: 'https://api.example.com',
          helperText: 'Release builds require HTTPS; local HTTP works in debug builds.')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
      ],
    ));
    controller.dispose();
    if (value == null) return;
    try {
      await service.setApiUrl(value);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Server saved')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }
}

class _CompassView extends StatelessWidget {
  const _CompassView();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 200,
    child: StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        final heading = snapshot.data?.heading;
        if (heading == null) return const Center(child: Text('Compass sensor is unavailable on this device'));
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Transform.rotate(angle: -heading * (3.141592653589793 / 180),
            child: const Icon(Icons.navigation, size: 88, color: AppColors.primary)),
          const SizedBox(height: 8),
          Text('${heading.toStringAsFixed(0)}°', style: Theme.of(context).textTheme.headlineSmall),
          const Text('Magnetic heading'),
        ]);
      },
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              ],
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
              )),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
