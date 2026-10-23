import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../providers/locale_provider.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _TabItem(path: '/map', icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Map'),
    _TabItem(path: '/measurement', icon: Icons.straighten_outlined, activeIcon: Icons.straighten, label: 'Measure'),
    _TabItem(path: '/devices', icon: Icons.devices_outlined, activeIcon: Icons.devices, label: 'Devices'),
    _TabItem(path: '/tracks', icon: Icons.route_outlined, activeIcon: Icons.route, label: 'Tracks'),
    _TabItem(path: '/tools', icon: Icons.build_outlined, activeIcon: Icons.build, label: 'GPS Tools'),
  ];

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.025),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(currentLocation), child: child),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => context.go(_tabs[index].path),
        destinations: _tabs.map((tab) {
          return NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.activeIcon, color: AppColors.primary),
            label: _localizedTabLabel(context, tab.label),
          );
        }).toList(),
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  String _localizedTabLabel(BuildContext context, String key) => switch (key) {
        'Map' => appText(context, 'ផែនទី', 'Map'),
        'Measure' => appText(context, 'វាស់វែង', 'Measure'),
        'Devices' => appText(context, 'ឧបករណ៍', 'Devices'),
        'Tracks' => appText(context, 'ប្រវត្តិ', 'Tracks'),
        _ => appText(context, 'ឧបករណ៍ GPS', 'GPS Tools'),
      };
}

class _TabItem {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
