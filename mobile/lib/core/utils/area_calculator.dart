import 'dart:math';
import 'package:latlong2/latlong.dart';

/// Geodesic area & distance calculator (matches backend ToolsService)
/// WGS84 ellipsoid constants
class GeoCalculator {
  static const double _a = 6378137.0;       // Semi-major axis
  static const double _b = 6356752.3142;    // Semi-minor axis
  static const double _f = 1 / 298.257223563; // Flattening
  static const double _e2 = 1 - (_b * _b) / (_a * _a);

  // ─── Area ─────────────────────────────────────────────────────────
  static AreaResult calculateArea(List<LatLng> points) {
    if (points.length < 3) throw ArgumentError('At least 3 points required');

    final poly = List<LatLng>.from(points);
    if (poly.first.latitude != poly.last.latitude ||
        poly.first.longitude != poly.last.longitude) {
      poly.add(poly.first);
    }

    final sqm = _geodesicArea(poly).abs();
    final perimeter = _calculatePerimeter(poly);

    return AreaResult(
      sqm: sqm,
      sqkm: sqm / 1e6,
      hectares: sqm / 10000,
      ares: sqm / 100,
      centiares: sqm,
      perimeterM: perimeter,
      perimeterKm: perimeter / 1000,
    );
  }

  static double _geodesicArea(List<LatLng> poly) {
    const r = _a;
    var area = 0.0;
    final n = poly.length;

    for (int i = 0; i < n - 1; i++) {
      final lat1 = _toRad(poly[i].latitude);
      final lat2 = _toRad(poly[i + 1].latitude);
      final dLng = _toRad(poly[i + 1].longitude - poly[i].longitude);
      area += dLng * (2 + sin(lat1) + sin(lat2));
    }

    area = (area * r * r) / 2;
    const correction = 1 - _e2 / 6 - _e2 * _e2 / 180;
    return area * correction;
  }

  // ─── Distance (Vincenty) ──────────────────────────────────────────
  static DistanceResult calculateDistance(LatLng p1, LatLng p2) {
    final result = _vincenty(p1, p2);
    return DistanceResult(
      meters: result.distance,
      kilometers: result.distance / 1000,
      bearingDeg: _toDeg(result.azimuth1),
      backBearingDeg: _toDeg(result.azimuth2),
    );
  }

  static double _calculatePerimeter(List<LatLng> points) {
    var total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += _vincenty(points[i], points[i + 1]).distance;
    }
    return total;
  }

  static _VincentyResult _vincenty(LatLng p1, LatLng p2) {
    const a = _a;
    const b = _b;
    const f = _f;

    final L = _toRad(p2.longitude - p1.longitude);
    final U1 = atan((1 - f) * tan(_toRad(p1.latitude)));
    final U2 = atan((1 - f) * tan(_toRad(p2.latitude)));
    final sinU1 = sin(U1), cosU1 = cos(U1);
    final sinU2 = sin(U2), cosU2 = cos(U2);

    var lambda = L;
    var lambdaP = 0.0;
    var iterLimit = 100;
    double sinSigma = 0, cosSigma = 0, sigma = 0;
    double sinAlpha = 0, cosSqAlpha = 0, cos2SigmaM = 0, C = 0;

    do {
      final sinLambda = sin(lambda);
      final cosLambda = cos(lambda);
      sinSigma = sqrt(
        pow(cosU2 * sinLambda, 2) +
        pow(cosU1 * sinU2 - sinU1 * cosU2 * cosLambda, 2),
      );
      if (sinSigma == 0) return _VincentyResult(0, 0, 0);
      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
      sigma = atan2(sinSigma, cosSigma);
      sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
      cosSqAlpha = 1 - sinAlpha * sinAlpha;
      cos2SigmaM = cosSqAlpha != 0
          ? cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha
          : 0.0;
      C = (f / 16) * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
      lambdaP = lambda;
      lambda = L +
          (1 - C) *
              f *
              sinAlpha *
              (sigma +
                  C *
                      sinSigma *
                      (cos2SigmaM +
                          C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));
    } while ((lambda - lambdaP).abs() > 1e-12 && --iterLimit > 0);

    final uSq = cosSqAlpha * (a * a - b * b) / (b * b);
    final A2 = 1 + (uSq / 16384) * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    final B = (uSq / 1024) * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    final deltaSigma = B *
        sinSigma *
        (cos2SigmaM +
            (B / 4) *
                (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) -
                    (B / 6) *
                        cos2SigmaM *
                        (-3 + 4 * sinSigma * sinSigma) *
                        (-3 + 4 * cos2SigmaM * cos2SigmaM)));

    final distance = b * A2 * (sigma - deltaSigma);
    final az1 = atan2(cosU2 * sin(lambda), cosU1 * sinU2 - sinU1 * cosU2 * cos(lambda));
    final az2 = atan2(cosU1 * sin(lambda), -sinU1 * cosU2 + cosU1 * sinU2 * cos(lambda));

    return _VincentyResult(distance, az1, az2);
  }

  // ─── Helpers ─────────────────────────────────────────────────────
  static double _toRad(double deg) => deg * pi / 180;
  static double _toDeg(double rad) => rad * 180 / pi;
}

class _VincentyResult {
  final double distance, azimuth1, azimuth2;
  const _VincentyResult(this.distance, this.azimuth1, this.azimuth2);
}

class AreaResult {
  final double sqm;
  final double sqkm;
  final double hectares;
  final double ares;
  final double centiares;
  final double perimeterM;
  final double perimeterKm;

  const AreaResult({
    required this.sqm,
    required this.sqkm,
    required this.hectares,
    required this.ares,
    required this.centiares,
    required this.perimeterM,
    required this.perimeterKm,
  });

  /// Format area for display in Khmer units
  String toKhmerDisplay() {
    if (hectares >= 1) {
      final h = hectares.floor();
      final remainAres = ((hectares - h) * 100).floor();
      final remainCa = (((hectares - h) * 100 - remainAres) * 100).round();
      return '${h}ហិ ${remainAres}អា ${remainCa}ស.អា';
    } else if (ares >= 1) {
      final a = ares.floor();
      final ca = ((ares - a) * 100).round();
      return '${a}អា ${ca}ស.អា';
    } else {
      return '${centiares.toStringAsFixed(2)}ស.អា';
    }
  }

  String toMetricDisplay() {
    if (sqkm >= 1) return '${sqkm.toStringAsFixed(4)} km²';
    if (sqm >= 10000) return '${hectares.toStringAsFixed(4)} ha';
    return '${sqm.toStringAsFixed(2)} m²';
  }
}

class DistanceResult {
  final double meters;
  final double kilometers;
  final double bearingDeg;
  final double backBearingDeg;

  const DistanceResult({
    required this.meters,
    required this.kilometers,
    required this.bearingDeg,
    required this.backBearingDeg,
  });

  String toDisplay() {
    if (kilometers >= 1) return '${kilometers.toStringAsFixed(3)} km';
    return '${meters.toStringAsFixed(2)} m';
  }
}
