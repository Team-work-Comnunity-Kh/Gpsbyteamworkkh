import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/services/api_service.dart';
import '../providers/location_provider.dart';
import 'widgets/gps_status_panel.dart';
import 'widgets/map_controls.dart';

/// ផ្ទាំងផែនទីដំបូង — Real-time GPS Map Screen
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  final _mapController = MapController();
  MapType _mapType = MapType.street;
  bool _isFollowing = true;
  bool _showGpsPanel = true;
  bool _registrationStarted = false;
  String? _deviceId;
  DateTime? _lastLocationSentAt;
  late AnimationController _compassAnim;

  @override
  void initState() {
    super.initState();
    _compassAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _compassAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);

    if (!_registrationStarted) {
      _registrationStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _registerDevice());
    }

    // Follow GPS position
    ref.listen(locationProvider, (_, next) {
      if (_isFollowing && next.position != null) {
        _mapController.move(
          LatLng(next.position!.latitude, next.position!.longitude),
          _mapController.camera.zoom,
        );
        _compassAnim.forward(from: 0);
      }
      final position = next.position;
      if (position != null) _sendDeviceLocation(position);
    });

    return Scaffold(
      body: Stack(
        children: [
          // ─── Map ───────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(11.5564, 104.9282), // Phnom Penh
              initialZoom: 15,
              onTap: (_, __) => setState(() => _isFollowing = false),
              onMapEvent: (event) {
                if (event is MapEventRotate) {
                  setState(() {});
                }
              },
            ),
            children: [
              // Tile Layer
              TileLayer(
                urlTemplate: _getTileUrl(_mapType),
              userAgentPackageName: 'com.smartgps.smartgps',
                maxZoom: 19,
              ),

              // Current position marker
              if (locationState.position != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        locationState.position!.latitude,
                        locationState.position!.longitude,
                      ),
                      width: 80,
                      height: 80,
                      child: _buildLocationMarker(
                        locationState.position!,
                        _mapController.camera.rotation,
                      ),
                    ),
                  ],
                ),

              // Accuracy circle
              if (locationState.position != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(
                        locationState.position!.latitude,
                        locationState.position!.longitude,
                      ),
                      radius: locationState.position!.accuracy,
                      useRadiusInMeter: true,
                      color: AppColors.primary.withOpacity(0.1),
                      borderColor: AppColors.primary.withOpacity(0.4),
                      borderStrokeWidth: 1,
                    ),
                  ],
                ),
            ],
          ),

          // ─── GPS Status Panel ──────────────────────────────────────
          if (_showGpsPanel)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: GpsStatusPanel(locationState: locationState),
            ),

          // ─── Map Controls ──────────────────────────────────────────
          Positioned(
            right: 12,
            bottom: 16,
            child: MapControls(
              mapController: _mapController,
              mapType: _mapType,
              isFollowing: _isFollowing,
              compassRotation: _mapController.camera.rotation,
              onFollowToggle: () {
                setState(() => _isFollowing = !_isFollowing);
                if (_isFollowing && locationState.position != null) {
                  _mapController.move(
                    LatLng(
                      locationState.position!.latitude,
                      locationState.position!.longitude,
                    ),
                    18,
                  );
                }
              },
              onMapTypeChange: (type) => setState(() => _mapType = type),
              onResetNorth: () => _mapController.rotate(0),
            ),
          ),

          // ─── Coordinates display ───────────────────────────────────
          if (locationState.position != null)
            Positioned(
              bottom: 16,
              left: 12,
              child: _CoordinatesCard(position: locationState.position!),
            ),
        ],
      ),
    );
  }

  Future<void> _registerDevice() async {
    try {
      final device = await ref.read(apiServiceProvider).registerCurrentDevice();
      if (!mounted) return;
      setState(() => _deviceId = device['deviceId'] as String?);
      final position = ref.read(locationProvider).position;
      if (position != null) _sendDeviceLocation(position, force: true);
    } catch (_) {
      if (mounted) _registrationStarted = false;
    }
  }

  void _sendDeviceLocation(Position position, {bool force = false}) {
    final deviceId = _deviceId;
    final now = DateTime.now();
    if (deviceId == null ||
        (!force && _lastLocationSentAt != null &&
            now.difference(_lastLocationSentAt!) < const Duration(seconds: 15))) {
      return;
    }
    _lastLocationSentAt = now;
    ref.read(apiServiceProvider).updateDeviceLocation(
      deviceId,
      PositionData(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        accuracy: position.accuracy,
      ),
    ).catchError((_) {});
  }

  Widget _buildLocationMarker(Position position, double mapRotation) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing accuracy ring
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.15),
          ),
        ),
        // Direction arrow
        Transform.rotate(
          angle: (position.heading - mapRotation) * (3.14159 / 180),
          child: const Icon(
            Icons.navigation,
            color: AppColors.primary,
            size: 32,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
      ],
    );
  }

  String _getTileUrl(MapType type) => switch (type) {
    MapType.satellite =>
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    MapType.terrain =>
      'https://tile.opentopomap.org/{z}/{x}/{y}.png',
    _ =>
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  };
}

enum MapType { street, satellite, terrain }

class _CoordinatesCard extends StatelessWidget {
  final Position position;
  const _CoordinatesCard({required this.position});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lat: ${position.latitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Lng: ${position.longitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
            if (position.altitude != 0)
              Text(
                'Alt: ${position.altitude.toStringAsFixed(1)}m',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            Text(
              '±${position.accuracy.toStringAsFixed(1)}m',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _accuracyColor(position.accuracy),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accuracyColor(double accuracy) {
    if (accuracy < 5) return AppColors.signalStrong;
    if (accuracy < 15) return AppColors.signalMedium;
    return AppColors.signalWeak;
  }
}
