import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/measurement_provider.dart';

class MeasurementToolbar extends StatelessWidget {
  final MeasurementMode mode;
  final int pointCount;
  final bool isClosed;
  final ValueChanged<MeasurementMode> onModeChange;
  final VoidCallback? onAddCurrentLocation;
  final VoidCallback? onClose;

  const MeasurementToolbar({
    super.key,
    required this.mode,
    required this.pointCount,
    required this.isClosed,
    required this.onModeChange,
    this.onAddCurrentLocation,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Mode toggle
            ToggleButtons(
              isSelected: [
                mode == MeasurementMode.tap,
                mode == MeasurementMode.walk,
              ],
              onPressed: (i) =>
                  onModeChange(i == 0 ? MeasurementMode.tap : MeasurementMode.walk),
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: AppColors.primary,
              constraints: const BoxConstraints(minWidth: 56, minHeight: 36),
              children: [
                Tooltip(
                  message: 'ចុចផែនទី',
                  child: Row(
                    children: const [
                      Icon(Icons.touch_app, size: 16),
                      SizedBox(width: 4),
                      Text('ចុច', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'ដើរ GPS',
                  child: Row(
                    children: const [
                      Icon(Icons.directions_walk, size: 16),
                      SizedBox(width: 4),
                      Text('ដើរ', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),

            // Point counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ចំណុច $pointCount',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Spacer(),

            // Add GPS position button (walk mode)
            if (mode == MeasurementMode.walk && onAddCurrentLocation != null)
              IconButton(
                onPressed: onAddCurrentLocation,
                icon: const Icon(Icons.add_location_alt, color: AppColors.accent),
                tooltip: 'បន្ថែមទីតាំង GPS',
                iconSize: 20,
              ),

            // Close polygon
            if (pointCount >= 3 && !isClosed && onClose != null)
              ElevatedButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.crop_square, size: 14),
                label: const Text('បិទ', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                ),
              ),

            if (isClosed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 12, color: AppColors.success),
                    const SizedBox(width: 4),
                    const Text('បិទហើយ',
                      style: TextStyle(fontSize: 11, color: AppColors.success)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
