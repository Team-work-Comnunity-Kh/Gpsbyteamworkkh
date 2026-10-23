import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static final _tabs = [
    _TabItem(path: '/map', icon: Icons.map_outlined, activeIcon: Icons.map, label: 'ផែនទី'),
    _TabItem(path: '/measurement', icon: Icons.straighten_outlined, activeIcon: Icons.straighten, label: 'វាស់ដី'),
    _TabItem(path: '/devices', icon: Icons.devices_outlined, activeIcon: Icons.devices, label: 'ឧបករណ៍'),
    _TabItem(path: '/tracks', icon: Icons.route_outlined, activeIcon: Icons.route, label: 'ប្រវត្តិ'),
    _TabItem(path: '/tools', icon: Icons.build_outlined, activeIcon: Icons.build, label: 'ឧបករណ៍ GPS'),
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

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          context.go(_tabs[index].path);
        },
        destinations: _tabs.map((tab) {
          final isSelected = _tabs.indexOf(tab) == currentIndex;
          return NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.activeIcon, color: AppColors.primary),
            label: tab.label,
          );
        }).toList(),
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
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
