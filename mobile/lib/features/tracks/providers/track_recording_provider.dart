import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/services/api_service.dart';

final trackRecordingProvider = StateNotifierProvider<TrackRecordingNotifier, TrackRecordingState>(
  (ref) => TrackRecordingNotifier(ref.read(apiServiceProvider)),
);

class TrackRecordingState {
  const TrackRecordingState({
    this.trackId,
    this.trackName,
    this.pointCount = 0,
    this.isStarting = false,
    this.error,
  });

  final String? trackId;
  final String? trackName;
  final int pointCount;
  final bool isStarting;
  final String? error;

  bool get isRecording => trackId != null;
}

class TrackRecordingNotifier extends StateNotifier<TrackRecordingState> {
  TrackRecordingNotifier(this._api) : super(const TrackRecordingState());

  final ApiService _api;
  StreamSubscription<Position>? _subscription;
  int _sequence = 0;

  Future<void> start(String name) async {
    if (state.isRecording || state.isStarting) return;
    state = const TrackRecordingState(isStarting: true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('បើក Location នៅលើទូរស័ព្ទសិន');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('កម្មវិធីត្រូវការសិទ្ធិទីតាំង ដើម្បីកត់ត្រាផ្លូវ');
      }

      final track = await _api.startTrack(name);
      final id = track['id'] as String;
      state = TrackRecordingState(trackId: id, trackName: name, pointCount: 0);
      _sequence = 0;
      _subscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
        ),
      ).listen(_recordPoint, onError: (Object error) {
        state = TrackRecordingState(
          trackId: state.trackId,
          trackName: state.trackName,
          pointCount: state.pointCount,
          error: error.toString(),
        );
      });
    } catch (error) {
      state = TrackRecordingState(error: error.toString());
      rethrow;
    }
  }

  Future<void> _recordPoint(Position position) async {
    final id = state.trackId;
    if (id == null) return;
    try {
      await _api.addTrackPoint(
        id,
        PositionData(
          latitude: position.latitude,
          longitude: position.longitude,
          altitude: position.altitude,
          speed: position.speed,
          heading: position.heading,
          accuracy: position.accuracy,
          sequence: _sequence++,
        ),
      );
      state = TrackRecordingState(
        trackId: id,
        trackName: state.trackName,
        pointCount: state.pointCount + 1,
      );
    } catch (error) {
      state = TrackRecordingState(
        trackId: id,
        trackName: state.trackName,
        pointCount: state.pointCount,
        error: error.toString(),
      );
    }
  }

  Future<void> stop() async {
    final id = state.trackId;
    if (id == null) return;
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _api.stopTrack(id);
      state = const TrackRecordingState();
    } catch (error) {
      state = TrackRecordingState(
        trackId: id,
        trackName: state.trackName,
        pointCount: state.pointCount,
        error: error.toString(),
      );
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
