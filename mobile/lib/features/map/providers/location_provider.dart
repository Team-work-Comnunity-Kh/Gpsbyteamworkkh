import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationState {
  final Position? position;
  final bool isLoading;
  final String? error;
  final List<SatelliteInfo> satellites;
  final SignalStrength signalStrength;

  const LocationState({
    this.position,
    this.isLoading = false,
    this.error,
    this.satellites = const [],
    this.signalStrength = SignalStrength.none,
  });

  LocationState copyWith({
    Position? position,
    bool? isLoading,
    Object? error = _keepLocationError,
    List<SatelliteInfo>? satellites,
    SignalStrength? signalStrength,
  }) =>
      LocationState(
        position: position ?? this.position,
        isLoading: isLoading ?? this.isLoading,
        error: identical(error, _keepLocationError)
            ? this.error
            : error as String?,
        satellites: satellites ?? this.satellites,
        signalStrength: signalStrength ?? this.signalStrength,
      );
}

enum SignalStrength { none, weak, medium, strong }

const _keepLocationError = Object();

class SatelliteInfo {
  final String constellation; // GPS, GLONASS, BeiDou, Galileo
  final int count;
  final double snr;
  const SatelliteInfo(
      {required this.constellation, required this.count, required this.snr});
}

class LocationNotifier extends StateNotifier<LocationState> {
  StreamSubscription<Position>? _positionSub;
  bool _initializing = false;

  LocationNotifier() : super(const LocationState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    if (_initializing) return;
    _initializing = true;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: 'Turn on Location/GPS in your phone settings, then tap retry.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permission was denied. Allow it to use live GPS.',
        );
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Location permission is blocked. Open app settings and allow location.',
        );
        return;
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Location permission is unavailable. Allow location and retry.',
        );
        return;
      }

      // Start streaming first, then ask Android for an immediate current fix.
      await _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 2,
        ),
      ).listen(
        _acceptPosition,
        onError: (Object error) {
          state = state.copyWith(
              error: 'GPS update failed: $error', isLoading: false);
        },
      );

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
          timeLimit: const Duration(seconds: 20),
        );
        _acceptPosition(position);
      } on TimeoutException {
        if (state.position == null) {
          state = state.copyWith(
            isLoading: false,
            error:
                'GPS has not found your location yet. Move outdoors and retry.',
          );
        }
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not read GPS location: $error',
      );
    } finally {
      _initializing = false;
    }
  }

  Future<void> refresh() async {
    if (_initializing) return;
    await _positionSub?.cancel();
    _positionSub = null;
    await _init();
  }

  void _acceptPosition(Position position) {
    state = state.copyWith(
      position: position,
      isLoading: false,
      error: null,
      signalStrength: _calcSignalStrength(position.accuracy),
    );
  }

  SignalStrength _calcSignalStrength(double accuracy) {
    if (accuracy < 5) return SignalStrength.strong;
    if (accuracy < 15) return SignalStrength.medium;
    return SignalStrength.weak;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);
