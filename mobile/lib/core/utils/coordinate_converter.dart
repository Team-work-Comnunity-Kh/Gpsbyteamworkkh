import 'dart:math';

/// Coordinate Converter: WGS84 Decimal ↔ UTM ↔ DMS
/// Matches backend tools.service.ts
class CoordinateConverter {
  static const double _a = 6378137.0;
  static const double _f = 1 / 298.257223563;
  static const double _b = _a * (1 - _f);
  static const double _e2 = 1 - (_b * _b) / (_a * _a);
  static const double _e2p = _e2 / (1 - _e2);
  static const double _k0 = 0.9996;

  // ─── Decimal → DMS ────────────────────────────────────────────────
  static String decimalToDMS(double decimal, {required bool isLat}) {
    final abs = decimal.abs();
    final deg = abs.floor();
    final minFull = (abs - deg) * 60;
    final min = minFull.floor();
    final sec = (minFull - min) * 60;

    String dir;
    if (isLat) {
      dir = decimal >= 0 ? 'N' : 'S';
    } else {
      dir = decimal >= 0 ? 'E' : 'W';
    }

    return "${deg}°${min}'${sec.toStringAsFixed(4)}\"$dir";
  }

  // ─── DMS → Decimal ───────────────────────────────────────────────
  static double dmsToDecimal(String dms) {
    final regex = RegExp(r'(\d+)[°\s]+(\d+)[\''\s]+(\d+(?:\.\d+)?)["\s]*([NSEWnsew])');
    final match = regex.firstMatch(dms.trim());
    if (match == null) throw ArgumentError('Invalid DMS format: $dms');

    final d = double.parse(match.group(1)!);
    final m = double.parse(match.group(2)!);
    final s = double.parse(match.group(3)!);
    final dir = match.group(4)!.toUpperCase();

    var decimal = d + m / 60 + s / 3600;
    if (dir == 'S' || dir == 'W') decimal = -decimal;
    return decimal;
  }

  // ─── Decimal → UTM ───────────────────────────────────────────────
  static UTMCoordinate decimalToUTM(double lat, double lng) {
    if (lat < -80 || lat > 84) throw ArgumentError('Latitude out of UTM range');

    final zoneNum = ((lng + 180) / 6).floor() + 1;
    final centralMeridian = (zoneNum - 1) * 6 - 180 + 3;
    final band = _utmBand(lat);

    final latRad = _toRad(lat);
    final lngRad = _toRad(lng);
    final lngCM = _toRad(centralMeridian.toDouble());

    final n = _a / sqrt(1 - _e2 * pow(sin(latRad), 2));
    final t = pow(tan(latRad), 2);
    final c = _e2p * pow(cos(latRad), 2);
    final a2 = cos(latRad) * (lngRad - lngCM);

    final m = _a * (
      (1 - _e2 / 4 - 3 * _e2 * _e2 / 64 - 5 * _e2 * _e2 * _e2 / 256) * latRad
      - (3 * _e2 / 8 + 3 * _e2 * _e2 / 32 + 45 * _e2 * _e2 * _e2 / 1024) * sin(2 * latRad)
      + (15 * _e2 * _e2 / 256 + 45 * _e2 * _e2 * _e2 / 1024) * sin(4 * latRad)
      - (35 * _e2 * _e2 * _e2 / 3072) * sin(6 * latRad)
    );

    final easting = _k0 * n * (
      a2 + (1 - t + c) * pow(a2, 3) / 6 +
      (5 - 18 * t + t * t + 72 * c - 58 * _e2p) * pow(a2, 5) / 120
    ) + 500000;

    var northing = _k0 * (m + n * tan(latRad) * (
      pow(a2, 2) / 2 +
      (5 - t + 9 * c + 4 * c * c) * pow(a2, 4) / 24 +
      (61 - 58 * t + t * t + 600 * c - 330 * _e2p) * pow(a2, 6) / 720
    ));

    if (lat < 0) northing += 10000000;

    return UTMCoordinate(
      easting: (easting * 100).round() / 100,
      northing: (northing * 100).round() / 100,
      zone: zoneNum,
      band: band,
    );
  }

  // ─── UTM → Decimal ────────────────────────────────────────────────
  static ({double lat, double lng}) utmToDecimal(
    double easting,
    double northing,
    int zone, {
    required bool isNorth,
  }) {
    final e1 = (1 - sqrt(1 - _e2)) / (1 + sqrt(1 - _e2));
    final x = easting - 500000;
    var y = northing;
    if (!isNorth) y -= 10000000;

    final centralMeridian = (zone - 1) * 6 - 180 + 3;
    final M = y / _k0;
    final mu = M / (_a * (1 - _e2 / 4 - 3 * _e2 * _e2 / 64 - 5 * _e2 * _e2 * _e2 / 256));

    final phi1 = mu +
        (3 * e1 / 2 - 27 * pow(e1, 3) / 32) * sin(2 * mu) +
        (21 * pow(e1, 2) / 16 - 55 * pow(e1, 4) / 32) * sin(4 * mu) +
        (151 * pow(e1, 3) / 96) * sin(6 * mu) +
        (1097 * pow(e1, 4) / 512) * sin(8 * mu);

    final n1 = _a / sqrt(1 - _e2 * pow(sin(phi1), 2));
    final t1 = pow(tan(phi1), 2);
    final c1 = _e2p * pow(cos(phi1), 2);
    final r1 = (_a * (1 - _e2)) / pow(1 - _e2 * pow(sin(phi1), 2), 1.5);
    final d = x / (n1 * _k0);

    final lat = phi1 -
        (n1 * tan(phi1)) / r1 *
            (pow(d, 2) / 2 -
                (5 + 3 * t1 + 10 * c1 - 4 * c1 * c1 - 9 * _e2p) *
                    pow(d, 4) /
                    24 +
                (61 + 90 * t1 + 298 * c1 + 45 * t1 * t1 - 252 * _e2p - 3 * c1 * c1) *
                    pow(d, 6) /
                    720);

    final lng = _toRad(centralMeridian.toDouble()) +
        (d -
                (1 + 2 * t1 + c1) * pow(d, 3) / 6 +
                (5 - 2 * c1 + 28 * t1 - 3 * c1 * c1 + 8 * _e2p + 24 * t1 * t1) *
                    pow(d, 5) /
                    120) /
            cos(phi1);

    return (
      lat: double.parse(_toDeg(lat).toStringAsFixed(8)),
      lng: double.parse(_toDeg(lng).toStringAsFixed(8)),
    );
  }

  static String _utmBand(double lat) {
    const bands = 'CDEFGHJKLMNPQRSTUVWXX';
    final idx = ((lat + 80) / 8).floor();
    if (idx < 0 || idx >= bands.length) return 'Z';
    return bands[idx];
  }

  static double _toRad(double deg) => deg * pi / 180;
  static double _toDeg(double rad) => rad * 180 / pi;
}

class UTMCoordinate {
  final double easting;
  final double northing;
  final int zone;
  final String band;

  const UTMCoordinate({
    required this.easting,
    required this.northing,
    required this.zone,
    required this.band,
  });

  @override
  String toString() => '${zone}${band} ${easting.toStringAsFixed(2)}E ${northing.toStringAsFixed(2)}N';
}
