import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../providers/auth_provider.dart';
import 'auth_service.dart';

final apiServiceProvider = Provider<ApiService>(
  (ref) => ApiService(ref.watch(authServiceProvider)),
);

class ApiService {
  ApiService(this.auth) : _dio = auth.dio;

  final AuthService auth;
  final Dio _dio;

  dynamic _data(Response<dynamic> response) => auth.unwrap(response.data);

  Future<List<Map<String, dynamic>>> getParcels() async {
    final response = await _dio.get('/parcels');
    return List<Map<String, dynamic>>.from(
      (_data(response) as List).map((item) => Map<String, dynamic>.from(item as Map)),
    );
  }

  Future<Map<String, dynamic>> createParcel({
    required String name,
    required List<LatLng> points,
    String? description,
  }) async {
    final ring = points
        .map((point) => [point.longitude, point.latitude])
        .toList(growable: true);
    if (ring.isNotEmpty &&
        (ring.first[0] != ring.last[0] || ring.first[1] != ring.last[1])) {
      ring.add(List<double>.from(ring.first));
    }
    final response = await _dio.post('/parcels', data: {
      'name': name.trim(),
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
      'coordinates': [ring],
    });
    return Map<String, dynamic>.from(_data(response) as Map);
  }

  Future<void> deleteParcel(String id) async => _dio.delete('/parcels/$id');

  Future<void> toggleParcelFavorite(String id) async =>
      _dio.post('/parcels/$id/favorite');

  Future<List<Map<String, dynamic>>> getTracks() async {
    final response = await _dio.get('/tracks');
    return List<Map<String, dynamic>>.from(
      (_data(response) as List).map((item) => Map<String, dynamic>.from(item as Map)),
    );
  }

  Future<Map<String, dynamic>> startTrack(String name) async {
    final response = await _dio.post('/tracks', data: {'name': name.trim()});
    return Map<String, dynamic>.from(_data(response) as Map);
  }

  Future<void> addTrackPoint(String trackId, PositionData point) async {
    await _dio.post('/tracks/$trackId/points', data: point.toJson());
  }

  Future<void> stopTrack(String id) async => _dio.post('/tracks/$id/stop');

  Future<void> deleteTrack(String id) async => _dio.delete('/tracks/$id');

  Future<List<Map<String, dynamic>>> getDevices() async {
    final response = await _dio.get('/devices');
    return List<Map<String, dynamic>>.from(
      (_data(response) as List).map((item) => Map<String, dynamic>.from(item as Map)),
    );
  }

  Future<List<Map<String, dynamic>>> getPairedDevices(String deviceRecordId) async {
    final response = await _dio.get('/devices/$deviceRecordId/paired');
    return List<Map<String, dynamic>>.from(
      (_data(response) as List).map((item) => Map<String, dynamic>.from(item as Map)),
    );
  }

  Future<Map<String, dynamic>> registerCurrentDevice() async {
    final box = Hive.box('settings');
    var deviceId = box.get('installation_id') as String?;
    if (deviceId == null) {
      final random = Random.secure();
      deviceId = List.generate(32, (_) => random.nextInt(16).toRadixString(16)).join();
      await box.put('installation_id', deviceId);
    }
    final platform = kIsWeb ? 'Web' : (Platform.isAndroid ? 'Android' : 'Mobile');
    final response = await _dio.post('/devices/register', data: {
      'deviceId': deviceId,
      'deviceName': 'SmartGPS $platform',
      'deviceModel': platform,
      'appVersion': '1.0.0',
    });
    return Map<String, dynamic>.from(_data(response) as Map);
  }

  Future<void> updateDeviceLocation(String deviceId, PositionData position) async {
    await _dio.put('/devices/$deviceId/location', data: position.toJson());
  }

  Future<Map<String, dynamic>> createPairingCode(String deviceId) async {
    final response = await _dio.post('/devices/$deviceId/pairing-code');
    return Map<String, dynamic>.from(_data(response) as Map);
  }

  Future<Map<String, dynamic>> pairWithCode(String pairingCode) async {
    final response = await _dio.post('/devices/pair', data: {'pairingCode': pairingCode});
    return Map<String, dynamic>.from(_data(response) as Map);
  }
}

class PositionData {
  const PositionData({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    this.accuracy,
    this.sequence,
  });

  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final double? heading;
  final double? accuracy;
  final int? sequence;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (altitude != null) 'altitude': altitude,
        if (speed != null) 'speed': speed,
        if (heading != null) 'heading': heading,
        if (accuracy != null) 'accuracy': accuracy,
        if (sequence != null) 'sequence': sequence,
      };
}
