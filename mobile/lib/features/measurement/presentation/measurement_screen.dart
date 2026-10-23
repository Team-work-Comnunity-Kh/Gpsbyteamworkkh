import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/area_calculator.dart';
import '../../../shared/services/api_service.dart';
import '../../map/providers/location_provider.dart';
import '../providers/measurement_provider.dart';
import 'widgets/area_result_panel.dart';
import 'widgets/measurement_toolbar.dart';

/// ផ្ទាំងវាស់ដី — Land Measurement Screen
class MeasurementScreen extends ConsumerStatefulWidget {
  const MeasurementScreen({super.key});

  @override
  ConsumerState<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends ConsumerState<MeasurementScreen> {
  final _mapController = MapController();
  bool _showResultPanel = false;

  @override
  Widget build(BuildContext context) {
    final measureState = ref.watch(measurementProvider);
    final locationState = ref.watch(locationProvider);

    final points = measureState.points;
    final isClosed = measureState.isClosed;

    // Calculate area if we have 3+ points
    AreaResult? areaResult;
    if (points.length >= 3) {
      try {
        areaResult = GeoCalculator.calculateArea(points);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('វាស់ដី'),
        actions: [
          if (points.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'ដក (Undo)',
              onPressed: () => ref.read(measurementProvider.notifier).undo(),
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              tooltip: 'ធ្វើឡើងវិញ (Redo)',
              onPressed: () => ref.read(measurementProvider.notifier).redo(),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'លុបទាំងអស់',
              onPressed: _confirmClear,
              color: AppColors.error,
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          // ─── Map with tap to add points ──────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: locationState.position != null
                  ? LatLng(locationState.position!.latitude, locationState.position!.longitude)
                  : const LatLng(11.5564, 104.9282),
              initialZoom: 18,
              onTap: measureState.mode == MeasurementMode.tap
                  ? (_, point) => ref
                      .read(measurementProvider.notifier)
                      .addPoint(point)
                  : null,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'app.smartgps',
              ),

              // Polygon fill
              if (points.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: points,
                      color: AppColors.parcelFill,
                      borderColor: AppColors.parcelStroke,
                      borderStrokeWidth: 2.5,
                      isFilled: true,
                    ),
                  ],
                ),

              // Lines connecting points
              if (points.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: isClosed ? [...points, points.first] : points,
                      color: AppColors.parcelStroke,
                      strokeWidth: 2.5,
                    ),
                  ],
                ),

              // Point markers
              MarkerLayer(
                markers: points.asMap().entries.map((e) {
                  final i = e.key;
                  final point = e.value;
                  return Marker(
                    point: point,
                    width: 30,
                    height: 30,
                    child: GestureDetector(
                      onLongPress: () =>
                          ref.read(measurementProvider.notifier).removePoint(i),
                      child: Container(
                        decoration: BoxDecoration(
                          color: i == 0 ? AppColors.accentDark : AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Current GPS position
              if (locationState.position != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        locationState.position!.latitude,
                        locationState.position!.longitude,
                      ),
                      width: 16,
                      height: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ─── Toolbar (Walk mode / Tap mode) ──────────────────────
          Positioned(
            top: 8,
            left: 12,
            right: 12,
            child: MeasurementToolbar(
              mode: measureState.mode,
              pointCount: points.length,
              isClosed: isClosed,
              onModeChange: (mode) =>
                  ref.read(measurementProvider.notifier).setMode(mode),
              onAddCurrentLocation: locationState.position != null
                  ? () => ref.read(measurementProvider.notifier).addPoint(
                        LatLng(
                          locationState.position!.latitude,
                          locationState.position!.longitude,
                        ),
                      )
                  : null,
              onClose: points.length >= 3
                  ? () => ref
                      .read(measurementProvider.notifier)
                      .closePolygon()
                  : null,
            ),
          ),

          // ─── Area Result Panel ────────────────────────────────────
          if (areaResult != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AreaResultPanel(
                areaResult: areaResult,
                pointCount: points.length,
                onSave: () => _showSaveDialog(areaResult!),
                onExport: () => _showExportMenu(areaResult!),
              ),
            ),
        ],
      ),

      // FAB: Add current GPS position
      floatingActionButton: measureState.mode == MeasurementMode.walk &&
              locationState.position != null
          ? FloatingActionButton.extended(
              onPressed: () => ref.read(measurementProvider.notifier).addPoint(
                    LatLng(
                      locationState.position!.latitude,
                      locationState.position!.longitude,
                    ),
                  ),
              icon: const Icon(Icons.add_location_alt),
              label: const Text('ចំណុចនេះ'),
              backgroundColor: AppColors.accent,
            )
          : null,
    );
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('លុបចំណុចទាំងអស់?'),
        content: const Text('ចំណុចទាំងអស់នឹងត្រូវបានលុប។'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('បោះបង់'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(measurementProvider.notifier).clearAll();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('លុប'),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog(AreaResult areaResult) {
    final nameController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16, right: 16, top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('រក្សាទុកដី', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'ឈ្មោះដី *'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'កំណត់ចំណាំ'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            // Show area summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ក្រឡាផ្ទៃ: ${areaResult.toKhmerDisplay()}',
                    style: Theme.of(ctx).textTheme.bodyMedium),
                  Text('${areaResult.toMetricDisplay()} | '
                    'បរិមាត្រ: ${areaResult.perimeterM.toStringAsFixed(1)}m',
                    style: Theme.of(ctx).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                try {
                  await ref.read(apiServiceProvider).createParcel(
                    name: nameController.text.trim(),
                    description: noteController.text,
                    points: ref.read(measurementProvider).points,
                  );
                } catch (error) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not save parcel: $error')),
                  );
                  return;
                }
                ref.read(measurementProvider.notifier).clearAll();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('រក្សាទុករួចរាល់ ✓')),
                );
              },
              child: const Text('រក្សាទុក'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportMenu(AreaResult areaResult) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('GeoJSON'),
            onTap: () { Navigator.pop(context); _exportParcel('geojson'); },
          ),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('KML (Google Earth)'),
            onTap: () { Navigator.pop(context); _exportParcel('kml'); },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('CSV'),
            onTap: () { Navigator.pop(context); _exportParcel('csv'); },
          ),
        ],
      ),
    );
  }

  Future<void> _exportParcel(String format) async {
    final points = ref.read(measurementProvider).points;
    final ring = [...points, if (points.isNotEmpty && points.first != points.last) points.first];
    String content;
    String extension;
    if (format == 'geojson') {
      content = jsonEncode({
        'type': 'Feature',
        'properties': {'name': 'SmartGPS measurement'},
        'geometry': {'type': 'Polygon', 'coordinates': [ring.map((p) => [p.longitude, p.latitude]).toList()]},
      });
      extension = 'geojson';
    } else if (format == 'kml') {
      final coords = ring.map((p) => '${p.longitude},${p.latitude},0').join(' ');
      content = '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document><Placemark><name>SmartGPS measurement</name><Polygon><outerBoundaryIs><LinearRing><coordinates>$coords</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark></Document></kml>';
      extension = 'kml';
    } else {
      content = 'index,latitude,longitude\n${points.asMap().entries.map((e) => '${e.key + 1},${e.value.latitude},${e.value.longitude}').join('\n')}';
      extension = 'csv';
    }
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/smartgps_measurement_${DateTime.now().millisecondsSinceEpoch}.$extension');
      await file.writeAsString(content, encoding: utf8);
      await Share.shareXFiles([XFile(file.path)], text: 'SmartGPS $format measurement');
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $error')));
    }
  }
}
