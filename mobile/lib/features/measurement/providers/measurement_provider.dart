import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

enum MeasurementMode { tap, walk }

class MeasurementState {
  final List<LatLng> points;
  final MeasurementMode mode;
  final bool isClosed;
  final List<List<LatLng>> history; // for undo
  final List<List<LatLng>> future;  // for redo

  const MeasurementState({
    this.points = const [],
    this.mode = MeasurementMode.tap,
    this.isClosed = false,
    this.history = const [],
    this.future = const [],
  });

  MeasurementState copyWith({
    List<LatLng>? points,
    MeasurementMode? mode,
    bool? isClosed,
    List<List<LatLng>>? history,
    List<List<LatLng>>? future,
  }) => MeasurementState(
    points: points ?? this.points,
    mode: mode ?? this.mode,
    isClosed: isClosed ?? this.isClosed,
    history: history ?? this.history,
    future: future ?? this.future,
  );
}

class MeasurementNotifier extends StateNotifier<MeasurementState> {
  MeasurementNotifier() : super(const MeasurementState());

  void addPoint(LatLng point) {
    if (state.isClosed) return;
    final newHistory = [...state.history, List<LatLng>.from(state.points)];
    state = state.copyWith(
      points: [...state.points, point],
      history: newHistory,
      future: [], // clear redo stack
    );
  }

  void removePoint(int index) {
    final newHistory = [...state.history, List<LatLng>.from(state.points)];
    final newPoints = List<LatLng>.from(state.points)..removeAt(index);
    state = state.copyWith(
      points: newPoints,
      history: newHistory,
      future: [],
      isClosed: state.isClosed && newPoints.length >= 3,
    );
  }

  void undo() {
    if (state.history.isEmpty) return;
    final prevPoints = state.history.last;
    final newHistory = state.history.sublist(0, state.history.length - 1);
    final newFuture = [List<LatLng>.from(state.points), ...state.future];
    state = state.copyWith(
      points: prevPoints,
      history: newHistory,
      future: newFuture,
      isClosed: false,
    );
  }

  void redo() {
    if (state.future.isEmpty) return;
    final nextPoints = state.future.first;
    final newFuture = state.future.sublist(1);
    final newHistory = [...state.history, List<LatLng>.from(state.points)];
    state = state.copyWith(
      points: nextPoints,
      history: newHistory,
      future: newFuture,
    );
  }

  void closePolygon() {
    if (state.points.length >= 3) {
      state = state.copyWith(isClosed: true);
    }
  }

  void setMode(MeasurementMode mode) {
    state = state.copyWith(mode: mode);
  }

  void clearAll() {
    state = const MeasurementState();
  }
}

final measurementProvider =
    StateNotifierProvider<MeasurementNotifier, MeasurementState>(
  (ref) => MeasurementNotifier(),
);
