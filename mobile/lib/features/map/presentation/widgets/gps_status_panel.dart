import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../providers/location_provider.dart';

class GpsStatusPanel extends StatelessWidget {
  final LocationState locationState;
  final VoidCallback onRetry;
  const GpsStatusPanel({
    super.key,
    required this.locationState,
    required this.onRetry,
  });

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
                        locationState.isLoading && pos == null
                            ? appText(context, 'កំពុងស្វែងរកទីតាំង GPS…', 'Searching for GPS…')
                            : _signalLabel(context, locationState.signalStrength),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _signalColor(locationState.signalStrength),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (pos != null)
                        Text(
                          '${appText(context, 'ភាពត្រឹមត្រូវ', 'Accuracy')}: ±${pos.accuracy.toStringAsFixed(1)}m',
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
            if (locationState.error != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_disabled,
                      color: Colors.deepOrange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _localizedError(context, locationState.error!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(appText(context, 'ព្យាយាមម្តងទៀត', 'Retry')),
                  ),
                ],
              ),
            ],
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

  String _signalLabel(BuildContext context, SignalStrength s) => switch (s) {
        SignalStrength.strong => appText(context, 'GPS ខ្លាំង', 'GPS strong'),
        SignalStrength.medium => appText(context, 'GPS មធ្យម', 'GPS fair'),
        SignalStrength.weak => appText(context, 'GPS ខ្សោយ', 'GPS weak'),
        SignalStrength.none => appText(context, 'គ្មាន GPS', 'No GPS fix'),
      };

  String _localizedError(BuildContext context, String message) {
    if (Localizations.localeOf(context).languageCode == 'en') return message;
    if (message.startsWith('Turn on Location')) {
      return 'សូមបើក Location/GPS ក្នុងការកំណត់ទូរស័ព្ទ រួចចុចព្យាយាមម្តងទៀត។';
    }
    if (message.startsWith('Location permission was denied')) {
      return 'សូមអនុញ្ញាត Location ដើម្បីប្រើ GPS ផ្ទាល់។';
    }
    if (message.startsWith('Location permission is blocked')) {
      return 'សូមចូលការកំណត់ App ហើយអនុញ្ញាត Location។';
    }
    if (message.startsWith('GPS has not found')) {
      return 'GPS មិនទាន់រកឃើញទីតាំងទេ។ សាកល្បងនៅក្រៅអគារ រួចចុចព្យាយាមម្តងទៀត។';
    }
    return message;
  }
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
