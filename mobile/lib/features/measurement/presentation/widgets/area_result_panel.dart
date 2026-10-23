import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/area_calculator.dart';

class AreaResultPanel extends StatelessWidget {
  final AreaResult areaResult;
  final int pointCount;
  final VoidCallback onSave;
  final VoidCallback onExport;

  const AreaResultPanel({
    super.key,
    required this.areaResult,
    required this.pointCount,
    required this.onSave,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 16, left: 16, right: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Main area display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ក្រឡាផ្ទៃ',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      areaResult.toKhmerDisplay(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      areaResult.toMetricDisplay(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Action buttons
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onExport,
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Export'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.save, size: 16),
                    label: const Text('រក្សាទុក'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              _StatItem(
                label: 'ចំណុច',
                value: '$pointCount',
                icon: Icons.place_outlined,
              ),
              _StatItem(
                label: 'បរិមាត្រ',
                value: areaResult.perimeterM >= 1000
                    ? '${(areaResult.perimeterKm).toStringAsFixed(2)}km'
                    : '${areaResult.perimeterM.toStringAsFixed(1)}m',
                icon: Icons.straighten,
              ),
              _StatItem(
                label: 'ហិកតា',
                value: areaResult.hectares.toStringAsFixed(4),
                icon: Icons.crop_square,
              ),
              _StatItem(
                label: 'ម²',
                value: areaResult.sqm >= 1000
                    ? '${(areaResult.sqm / 1000).toStringAsFixed(1)}k'
                    : areaResult.sqm.toStringAsFixed(1),
                icon: Icons.grid_on,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(height: 2),
          Text(value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
