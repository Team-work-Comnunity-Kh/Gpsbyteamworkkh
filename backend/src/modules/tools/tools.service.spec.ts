import { Test, TestingModule } from '@nestjs/testing';
import { ToolsService } from './tools.service';

describe('ToolsService', () => {
  let service: ToolsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ToolsService],
    }).compile();

    service = module.get<ToolsService>(ToolsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('calculateArea', () => {
    it('should calculate area of a square polygon correctly', () => {
      // 100m x 100m square = 10,000 m² = 1 hectare
      const coordinates = [
        [
          [104.9199, 11.5564],
          [104.91999, 11.5564],
          [104.91999, 11.55649],
          [104.9199, 11.55649],
          [104.9199, 11.5564],
        ],
      ];

      const result = service.calculateArea(coordinates);

      expect(result.squareMeters).toBeGreaterThan(9000);
      expect(result.squareMeters).toBeLessThan(11000);
      expect(result.hectares).toBeCloseTo(1, 1);
    });

    it('should calculate Khmer land units correctly', () => {
      // 1.5 hectares = 15,000 m²
      const coordinates = [
        [
          [104.9199, 11.5564],
          [104.92003, 11.5564],
          [104.92003, 11.55653],
          [104.9199, 11.55653],
          [104.9199, 11.5564],
        ],
      ];

      const result = service.calculateArea(coordinates);

      expect(result.khmer).toBeDefined();
      expect(result.khmer.hectares).toBeGreaterThanOrEqual(0);
      expect(result.khmer.aa).toBeGreaterThanOrEqual(0);
      expect(result.khmer.sangTeeAa).toBeGreaterThanOrEqual(0);
    });

    it('should handle small areas correctly', () => {
      // Small polygon (< 1 hectare)
      const coordinates = [
        [
          [104.9199, 11.5564],
          [104.91995, 11.5564],
          [104.91995, 11.55645],
          [104.9199, 11.55645],
          [104.9199, 11.5564],
        ],
      ];

      const result = service.calculateArea(coordinates);

      expect(result.squareMeters).toBeGreaterThan(0);
      expect(result.hectares).toBeLessThan(1);
    });
  });

  describe('calculateDistance', () => {
    it('should calculate distance between two points correctly', () => {
      const from = { latitude: 11.5564, longitude: 104.9199 };
      const to = { latitude: 11.5574, longitude: 104.9199 };

      const result = service.calculateDistance(from, to);

      expect(result.meters).toBeGreaterThan(100);
      expect(result.meters).toBeLessThan(150);
      expect(result.kilometers).toBeCloseTo(result.meters / 1000, 3);
      expect(result.miles).toBeCloseTo(result.meters / 1609.34, 3);
    });

    it('should calculate zero distance for same point', () => {
      const point = { latitude: 11.5564, longitude: 104.9199 };

      const result = service.calculateDistance(point, point);

      expect(result.meters).toBe(0);
      expect(result.kilometers).toBe(0);
      expect(result.miles).toBe(0);
    });

    it('should handle long distances correctly', () => {
      // Phnom Penh to Siem Reap (approximately 314 km)
      const from = { latitude: 11.5564, longitude: 104.9282 };
      const to = { latitude: 13.3671, longitude: 103.8448 };

      const result = service.calculateDistance(from, to);

      expect(result.kilometers).toBeGreaterThan(250);
      expect(result.kilometers).toBeLessThan(350);
    });
  });

  describe('wgs84ToUtm', () => {
    it('should convert WGS84 to UTM Zone 48N correctly', () => {
      const latitude = 11.5564;
      const longitude = 104.9199;

      const result = service.wgs84ToUtm(latitude, longitude);

      expect(result.zone).toBe('48N');
      expect(result.hemisphere).toBe('N');
      expect(result.easting).toBeGreaterThan(0);
      expect(result.northing).toBeGreaterThan(0);
    });

    it('should handle southern hemisphere correctly', () => {
      const latitude = -11.5564;
      const longitude = 104.9199;

      const result = service.wgs84ToUtm(latitude, longitude);

      expect(result.hemisphere).toBe('S');
    });

    it('should produce consistent results', () => {
      const latitude = 11.5564;
      const longitude = 104.9199;

      const result1 = service.wgs84ToUtm(latitude, longitude);
      const result2 = service.wgs84ToUtm(latitude, longitude);

      expect(result1.easting).toBeCloseTo(result2.easting, 2);
      expect(result1.northing).toBeCloseTo(result2.northing, 2);
    });
  });

  describe('utmToWgs84', () => {
    it('should convert UTM to WGS84 correctly', () => {
      // First convert WGS84 to UTM
      const originalLat = 11.5564;
      const originalLon = 104.9199;
      const utm = service.wgs84ToUtm(originalLat, originalLon);

      // Then convert back to WGS84
      const result = service.utmToWgs84(utm.easting, utm.northing);

      expect(result.latitude).toBeCloseTo(originalLat, 5);
      expect(result.longitude).toBeCloseTo(originalLon, 5);
    });

    it('should be reversible with wgs84ToUtm', () => {
      const lat = 11.5564;
      const lon = 104.9199;

      const utm = service.wgs84ToUtm(lat, lon);
      const wgs84 = service.utmToWgs84(utm.easting, utm.northing);

      expect(wgs84.latitude).toBeCloseTo(lat, 5);
      expect(wgs84.longitude).toBeCloseTo(lon, 5);
    });
  });

  describe('decimalToDms', () => {
    it('should convert positive latitude correctly', () => {
      const decimal = 11.5564;

      const result = service.decimalToDms(decimal, true);

      expect(result.degrees).toBe(11);
      expect(result.minutes).toBe(33);
      expect(result.seconds).toBeCloseTo(23.04, 1);
      expect(result.direction).toBe('N');
      expect(result.formatted).toContain('11°');
      expect(result.formatted).toContain('33\'');
      expect(result.formatted).toContain('N');
    });

    it('should convert negative latitude correctly', () => {
      const decimal = -11.5564;

      const result = service.decimalToDms(decimal, true);

      expect(result.degrees).toBe(11);
      expect(result.direction).toBe('S');
    });

    it('should convert positive longitude correctly', () => {
      const decimal = 104.9199;

      const result = service.decimalToDms(decimal, false);

      expect(result.degrees).toBe(104);
      expect(result.direction).toBe('E');
    });

    it('should convert negative longitude correctly', () => {
      const decimal = -104.9199;

      const result = service.decimalToDms(decimal, false);

      expect(result.degrees).toBe(104);
      expect(result.direction).toBe('W');
    });

    it('should handle zero correctly', () => {
      const result = service.decimalToDms(0, true);

      expect(result.degrees).toBe(0);
      expect(result.minutes).toBe(0);
      expect(result.seconds).toBe(0);
      expect(result.direction).toBe('N');
    });
  });

  describe('dmsToDecimal', () => {
    it('should convert DMS to decimal correctly (North)', () => {
      const result = service.dmsToDecimal(11, 33, 23.04, 'N');

      expect(result).toBeCloseTo(11.5564, 3);
    });

    it('should convert DMS to decimal correctly (South)', () => {
      const result = service.dmsToDecimal(11, 33, 23.04, 'S');

      expect(result).toBeCloseTo(-11.5564, 3);
    });

    it('should convert DMS to decimal correctly (East)', () => {
      const result = service.dmsToDecimal(104, 55, 11.64, 'E');

      expect(result).toBeCloseTo(104.9199, 3);
    });

    it('should convert DMS to decimal correctly (West)', () => {
      const result = service.dmsToDecimal(104, 55, 11.64, 'W');

      expect(result).toBeCloseTo(-104.9199, 3);
    });

    it('should be reversible with decimalToDms', () => {
      const decimal = 11.5564;
      const dms = service.decimalToDms(decimal, true);
      const result = service.dmsToDecimal(
        dms.degrees,
        dms.minutes,
        dms.seconds,
        dms.direction,
      );

      expect(result).toBeCloseTo(decimal, 4);
    });

    it('should handle zero seconds correctly', () => {
      const result = service.dmsToDecimal(11, 30, 0, 'N');

      expect(result).toBeCloseTo(11.5, 1);
    });
  });

  describe('Integration tests', () => {
    it('should maintain precision through multiple conversions', () => {
      const originalLat = 11.5564;
      const originalLon = 104.9199;

      // WGS84 -> UTM -> WGS84
      const utm = service.wgs84ToUtm(originalLat, originalLon);
      const wgs84 = service.utmToWgs84(utm.easting, utm.northing);

      expect(wgs84.latitude).toBeCloseTo(originalLat, 5);
      expect(wgs84.longitude).toBeCloseTo(originalLon, 5);
    });

    it('should maintain precision through DMS conversion', () => {
      const original = 11.5564;

      // Decimal -> DMS -> Decimal
      const dms = service.decimalToDms(original, true);
      const decimal = service.dmsToDecimal(
        dms.degrees,
        dms.minutes,
        dms.seconds,
        dms.direction,
      );

      expect(decimal).toBeCloseTo(original, 4);
    });

    it('should calculate area for real-world Cambodia parcel', () => {
      // Example: Agricultural land in Kampong Cham
      const coordinates = [
        [
          [105.123, 12.234],
          [105.133, 12.234],
          [105.133, 12.244],
          [105.123, 12.244],
          [105.123, 12.234],
        ],
      ];

      const result = service.calculateArea(coordinates);

      expect(result.squareMeters).toBeGreaterThan(0);
      expect(result.hectares).toBeGreaterThan(0);
      expect(result.khmer.hectares).toBeDefined();
      expect(result.khmer.aa).toBeDefined();
    });
  });
});
