import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateSpatialTables1700000000002 implements MigrationInterface {
  name = 'CreateSpatialTables1700000000002';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Parcels table (Land measurements)
    await queryRunner.query(`
      CREATE TABLE parcels (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(200) NOT NULL,
        description TEXT,
        geometry GEOGRAPHY(Polygon, 4326) NOT NULL,
        coordinates JSONB NOT NULL,
        "areaSquareMeters" FLOAT NOT NULL,
        "areaHectares" FLOAT NOT NULL,
        "areaKhmer" JSONB,
        "perimeterMeters" FLOAT NOT NULL,
        "centerLatitude" FLOAT,
        "centerLongitude" FLOAT,
        category VARCHAR(50),
        metadata JSONB,
        photos TEXT[],
        tags TEXT[],
        color VARCHAR(7) DEFAULT '#0FA3A3',
        "isFavorite" BOOLEAN DEFAULT FALSE,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW(),
        "deletedAt" TIMESTAMP
      );
      
      CREATE INDEX idx_parcels_user ON parcels("userId");
      CREATE INDEX idx_parcels_geometry ON parcels USING GIST(geometry);
      CREATE INDEX idx_parcels_category ON parcels(category);
      
      CREATE TRIGGER update_parcels_updated_at BEFORE UPDATE ON parcels
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    `);

    // Waypoints table
    await queryRunner.query(`
      CREATE TABLE waypoints (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(200) NOT NULL,
        description TEXT,
        location GEOGRAPHY(Point, 4326) NOT NULL,
        latitude FLOAT NOT NULL,
        longitude FLOAT NOT NULL,
        altitude FLOAT,
        accuracy FLOAT,
        category VARCHAR(50),
        icon VARCHAR(50),
        color VARCHAR(7) DEFAULT '#F97316',
        photos TEXT[],
        tags TEXT[],
        metadata JSONB,
        "isFavorite" BOOLEAN DEFAULT FALSE,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW(),
        "deletedAt" TIMESTAMP
      );
      
      CREATE INDEX idx_waypoints_user ON waypoints("userId");
      CREATE INDEX idx_waypoints_location ON waypoints USING GIST(location);
      CREATE INDEX idx_waypoints_category ON waypoints(category);
      
      CREATE TRIGGER update_waypoints_updated_at BEFORE UPDATE ON waypoints
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    `);

    // Tracks table
    await queryRunner.query(`
      CREATE TABLE tracks (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(200) NOT NULL,
        description TEXT,
        geometry GEOGRAPHY(LineString, 4326),
        "startTime" TIMESTAMP NOT NULL,
        "endTime" TIMESTAMP,
        "totalDistanceMeters" FLOAT DEFAULT 0,
        "totalDurationSeconds" INT DEFAULT 0,
        "maxSpeed" FLOAT,
        "avgSpeed" FLOAT,
        "maxAltitude" FLOAT,
        "minAltitude" FLOAT,
        "elevationGain" FLOAT,
        "elevationLoss" FLOAT,
        "pointCount" INT DEFAULT 0,
        color VARCHAR(7) DEFAULT '#0FA3A3',
        photos TEXT[],
        tags TEXT[],
        metadata JSONB,
        "isRecording" BOOLEAN DEFAULT FALSE,
        "isFavorite" BOOLEAN DEFAULT FALSE,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW(),
        "deletedAt" TIMESTAMP
      );
      
      CREATE INDEX idx_tracks_user ON tracks("userId");
      CREATE INDEX idx_tracks_time ON tracks("startTime", "endTime");
      CREATE INDEX idx_tracks_recording ON tracks("isRecording");
      
      CREATE TRIGGER update_tracks_updated_at BEFORE UPDATE ON tracks
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    `);

    // Track points table
    await queryRunner.query(`
      CREATE TABLE track_points (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "trackId" UUID NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
        location GEOGRAPHY(Point, 4326) NOT NULL,
        latitude FLOAT NOT NULL,
        longitude FLOAT NOT NULL,
        altitude FLOAT,
        speed FLOAT,
        heading FLOAT,
        accuracy FLOAT,
        timestamp TIMESTAMP NOT NULL,
        sequence INT,
        "gpsInfo" JSONB,
        "createdAt" TIMESTAMP DEFAULT NOW()
      );
      
      CREATE INDEX idx_track_points_track_time ON track_points("trackId", timestamp);
      CREATE INDEX idx_track_points_location ON track_points USING GIST(location);
      CREATE INDEX idx_track_points_sequence ON track_points("trackId", sequence);
    `);

    // Geofences table
    await queryRunner.query(`
      CREATE TABLE geofences (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(200) NOT NULL,
        description TEXT,
        type geofence_type NOT NULL,
        geometry GEOGRAPHY(Polygon, 4326) NOT NULL,
        "centerLatitude" FLOAT,
        "centerLongitude" FLOAT,
        "radiusMeters" FLOAT,
        coordinates JSONB,
        "alertOnEnter" BOOLEAN DEFAULT TRUE,
        "alertOnExit" BOOLEAN DEFAULT TRUE,
        "isActive" BOOLEAN DEFAULT TRUE,
        color VARCHAR(7) DEFAULT '#F97316',
        settings JSONB,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW(),
        "deletedAt" TIMESTAMP
      );
      
      CREATE INDEX idx_geofences_user ON geofences("userId");
      CREATE INDEX idx_geofences_geometry ON geofences USING GIST(geometry);
      CREATE INDEX idx_geofences_active ON geofences("isActive");
      
      CREATE TRIGGER update_geofences_updated_at BEFORE UPDATE ON geofences
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    `);

    // Geofence alerts table
    await queryRunner.query(`
      CREATE TABLE geofence_alerts (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        "geofenceId" UUID REFERENCES geofences(id) ON DELETE CASCADE,
        "deviceId" UUID REFERENCES devices(id) ON DELETE SET NULL,
        "alertType" alert_type NOT NULL,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        latitude FLOAT,
        longitude FLOAT,
        metadata JSONB,
        "isRead" BOOLEAN DEFAULT FALSE,
        "readAt" TIMESTAMP,
        "createdAt" TIMESTAMP DEFAULT NOW()
      );
      
      CREATE INDEX idx_geofence_alerts_user_read ON geofence_alerts("userId", "isRead");
      CREATE INDEX idx_geofence_alerts_geofence_created ON geofence_alerts("geofenceId", "createdAt");
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS geofence_alerts CASCADE`);
    await queryRunner.query(`DROP TABLE IF EXISTS geofences CASCADE`);
    await queryRunner.query(`DROP TABLE IF EXISTS track_points CASCADE`);
    await queryRunner.query(`DROP TABLE IF EXISTS tracks CASCADE`);
    await queryRunner.query(`DROP TABLE IF EXISTS waypoints CASCADE`);
    await queryRunner.query(`DROP TABLE IF EXISTS parcels CASCADE`);
  }
}
