import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../../core/constants/app_colors.dart';
import '../map_screen.dart';

class MapControls extends StatelessWidget {
  final MapController mapController;
  final MapType mapType;
  final bool isFollowing;
  final double compassRotation;
  final VoidCallback onFollowToggle;
  final ValueChanged<MapType> onMapTypeChange;
  final VoidCallback onResetNorth;

  const MapControls({
    super.key,
    required this.mapController,
    required this.mapType,
    required this.isFollowing,
    required this.compassRotation,
    required this.onFollowToggle,
    required this.onMapTypeChange,
    required this.onResetNorth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Compass
        if (compassRotation.abs() > 1)
          _ControlButton(
            onTap: onResetNorth,
            tooltip: 'ត្រឡប់ទិសខាងជើង',
            child: Transform.rotate(
              angle: -compassRotation * (3.14159 / 180),
              child: const Icon(Icons.explore, color: AppColors.primary),
            ),
          ),

        const SizedBox(height: 8),

        // Follow GPS
        _ControlButton(
          onTap: onFollowToggle,
          tooltip: isFollowing ? 'បញ្ឈប់តាម GPS' : 'តាម GPS',
          child: Icon(
            isFollowing ? Icons.gps_fixed : Icons.gps_not_fixed,
            color: isFollowing ? AppColors.primary : Colors.grey,
          ),
        ),

        const SizedBox(height: 8),

        // Zoom in
        _ControlButton(
          onTap: () => mapController.move(
            mapController.camera.center,
            mapController.camera.zoom + 1,
          ),
          tooltip: 'ពង្រីក',
          child: const Icon(Icons.add),
        ),

        // Zoom out
        _ControlButton(
          onTap: () => mapController.move(
            mapController.camera.center,
            mapController.camera.zoom - 1,
          ),
          tooltip: 'បង្រួម',
          child: const Icon(Icons.remove),
        ),

        const SizedBox(height: 8),

        // Map type selector
        _ControlButton(
          onTap: () => _showMapTypePicker(context),
          tooltip: 'ប្ដូរប្រភេទផែនទី',
          child: Icon(
            mapType == MapType.satellite
                ? Icons.satellite_alt
                : mapType == MapType.terrain
                    ? Icons.terrain
                    : Icons.map,
          ),
        ),
      ],
    );
  }

  void _showMapTypePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ប្រភេទផែនទី', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _MapTypeTile(
                  label: 'ផ្លូវ',
                  icon: Icons.map,
                  isSelected: mapType == MapType.street,
                  onTap: () { onMapTypeChange(MapType.street); Navigator.pop(context); },
                ),
                const SizedBox(width: 12),
                _MapTypeTile(
                  label: 'ផ្កាយរណប',
                  icon: Icons.satellite_alt,
                  isSelected: mapType == MapType.satellite,
                  onTap: () { onMapTypeChange(MapType.satellite); Navigator.pop(context); },
                ),
                const SizedBox(width: 12),
                _MapTypeTile(
                  label: 'ដី',
                  icon: Icons.terrain,
                  isSelected: mapType == MapType.terrain,
                  onTap: () { onMapTypeChange(MapType.terrain); Navigator.pop(context); },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final VoidCallback onTap;
  final String tooltip;
  final Widget child;

  const _ControlButton({
    required this.onTap,
    required this.tooltip,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _MapTypeTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapTypeTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : null, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected ? AppColors.primary : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
