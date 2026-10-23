import { Injectable } from '@nestjs/common';
import * as turf from '@turf/turf';
// eslint-disable-next-line @typescript-eslint/no-require-imports
const proj4 = require('proj4');

@Injectable()
export class ToolsService {
  // Define Cambodia UTM Zone 48N projection
  private readonly utm48n =
    '+proj=utm +zone=48 +datum=WGS84 +units=m +no_defs';
  private readonly wgs84 = '+proj=longlat +datum=WGS84 +no_defs';

  /**
   * Calculate area from coordinates
   */
  calculateArea(coordinates: number[][][]) {
    const polygon = turf.polygon(coordinates);
    const areaSquareMeters = turf.area(polygon);
    const areaHectares = areaSquareMeters / 10000;

    // Khmer land units
    const hectares = Math.floor(areaSquareMeters / 10000);
    const remaining = areaSquareMeters % 10000;
    const aa = Math.floor(remaining / 100);
    const sangTeeAa = Math.floor(remaining / 400);

    return {
      squareMeters: areaSquareMeters,
      hectares: areaHectares,
      khmer: { hectares, aa, sangTeeAa },
    };
  }

  /**
   * Calculate distance between two points
   */
  calculateDistance(
    from: { latitude: number; longitude: number },
    to: { latitude: number; longitude: number },
  ) {
    const point1 = turf.point([from.longitude, from.latitude]);
    const point2 = turf.point([to.longitude, to.latitude]);
    const distance = turf.distance(point1, point2, { units: 'meters' });

    return {
      meters: distance,
      kilometers: distance / 1000,
      miles: distance / 1609.34,
    };
  }

  /**
   * Convert WGS84 to UTM
   */
  wgs84ToUtm(latitude: number, longitude: number) {
    const [easting, northing] = proj4(this.wgs84, this.utm48n, [
      longitude,
      latitude,
    ]);

    return {
      easting,
      northing,
      zone: '48N',
      hemisphere: latitude >= 0 ? 'N' : 'S',
    };
  }

  /**
   * Convert UTM to WGS84
   */
  utmToWgs84(easting: number, northing: number) {
    const [longitude, latitude] = proj4(this.utm48n, this.wgs84, [
      easting,
      northing,
    ]);

    return { latitude, longitude };
  }

  /**
   * Convert decimal degrees to DMS
   */
  decimalToDms(decimal: number, isLatitude: boolean) {
    const absolute = Math.abs(decimal);
    const degrees = Math.floor(absolute);
    const minutesNotTruncated = (absolute - degrees) * 60;
    const minutes = Math.floor(minutesNotTruncated);
    const seconds = ((minutesNotTruncated - minutes) * 60).toFixed(2);

    const direction = isLatitude
      ? decimal >= 0
        ? 'N'
        : 'S'
      : decimal >= 0
        ? 'E'
        : 'W';

    return {
      degrees,
      minutes,
      seconds: parseFloat(seconds),
      direction,
      formatted: `${degrees}° ${minutes}' ${seconds}" ${direction}`,
    };
  }

  /**
   * Convert DMS to decimal degrees
   */
  dmsToDecimal(
    degrees: number,
    minutes: number,
    seconds: number,
    direction: string,
  ) {
    let decimal = degrees + minutes / 60 + seconds / 3600;

    if (direction === 'S' || direction === 'W') {
      decimal = -decimal;
    }

    return decimal;
  }
}
