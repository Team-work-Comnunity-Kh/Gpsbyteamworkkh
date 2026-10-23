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
    String? error,
    List<SatelliteInfo>? satellites,
    SignalStrength? signalStrength,
  }) => LocationState(
    position: position ?? this.position,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
    satellites: satellites ?? this.satellites,
    signalStrength: signalStrength ?? this.signalStrength,
  );
}

enum SignalStrength { none, weak, medium, strong }

class SatelliteInfo {
  final String constellation; // GPS, GLONASS, BeiDou, Galileo
  final int count;
  final double snr;
  const SatelliteInfo({required this.constellation, required this.count, required this.snr});
}

class LocationNotifier extends StateNotifier<LocationState> {
  StreamSubscription<Position>? _positionSub;

  LocationNotifier() : super(const LocationState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        isLoading: false,
        error: 'Location service is disabled',
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permission denied',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        isLoading: false,
        error: 'Location permission permanently denied',
      );
      return;
    }

    // Start listening to location updates
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 2, // Update every 2 meters
      ),
    ).listen(
      (position) {
        state = state.copyWith(
          position: position,
          isLoading: false,
          error: null,
          signalStrength: _calcSignalStrength(position.accuracy),
        );
      },
      onError: (error) {
        state = state.copyWith(error: error.toString(), isLoading: false);
      },
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

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);
