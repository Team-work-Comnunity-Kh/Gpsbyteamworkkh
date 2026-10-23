import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/location_provider.dart';

class GpsStatusPanel extends StatelessWidget {
  final LocationState locationState;
  const GpsStatusPanel({super.key, required this.locationState});

  @override
  Widget build(BuildContext context) {
    final pos = locationState.position;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // Signal icon
                _SignalIcon(strength: locationState.signalStrength),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _signalLabel(locationState.signalStrength),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _signalColor(locationState.signalStrength),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (pos != null)
                        Text(
                          'ភាពត្រឹមត្រូវ: ±${pos.accuracy.toStringAsFixed(1)}m',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                // Speed
                if (pos != null && pos.speed > 0.5) ...[
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.speed,
                    label: '${(pos.speed * 3.6).toStringAsFixed(1)} km/h',
                  ),
                ],
                // Altitude
                if (pos != null && pos.altitude != 0) ...[
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.height,
                    label: '${pos.altitude.toStringAsFixed(0)}m',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _signalColor(SignalStrength s) => switch (s) {
    SignalStrength.strong => AppColors.signalStrong,
    SignalStrength.medium => AppColors.signalMedium,
    SignalStrength.weak => AppColors.signalWeak,
    SignalStrength.none => AppColors.signalNone,
  };

  String _signalLabel(SignalStrength s) => switch (s) {
    SignalStrength.strong => 'GPS ខ្លាំង',
    SignalStrength.medium => 'GPS មធ្យម',
    SignalStrength.weak => 'GPS ខ្សោយ',
    SignalStrength.none => 'គ្មាន GPS',
  };
}

class _SignalIcon extends StatelessWidget {
  final SignalStrength strength;
  const _SignalIcon({required this.strength});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.gps_fixed,
          color: switch (strength) {
            SignalStrength.strong => AppColors.signalStrong,
            SignalStrength.medium => AppColors.signalMedium,
            SignalStrength.weak => AppColors.signalWeak,
            SignalStrength.none => AppColors.signalNone,
          },
          size: 28,
        ),
        if (strength == SignalStrength.none)
          const Icon(Icons.gps_off, color: AppColors.signalNone, size: 28),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
