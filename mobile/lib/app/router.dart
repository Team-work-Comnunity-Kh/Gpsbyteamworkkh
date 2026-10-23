import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/map/presentation/map_screen.dart';
import '../features/measurement/presentation/measurement_screen.dart';
import '../features/devices/presentation/devices_screen.dart';
import '../features/devices/presentation/pair_device_screen.dart';
import '../features/tracks/tracks_screen.dart';
import '../features/tools/tools_screen.dart';
import '../shared/providers/auth_provider.dart';
import '../shared/widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/map',
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/map';
      return null;
    },
    routes: [
      // ─── Auth Routes ──────────────────────────────────────────────
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),


      // ─── Main Shell (Bottom Navigation) ──────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/map',
            name: 'map',
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: '/measurement',
            name: 'measurement',
            builder: (context, state) => const MeasurementScreen(),
          ),
          GoRoute(
            path: '/devices',
            name: 'devices',
            builder: (context, state) => const DevicesScreen(),
            routes: [
              GoRoute(
                path: 'pair',
                name: 'pair-device',
                builder: (context, state) => const PairDeviceScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/tracks',
            name: 'tracks',
            builder: (context, state) => const TracksScreen(),
          ),
          GoRoute(
            path: '/tools',
            name: 'tools',
            builder: (context, state) => const ToolsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
