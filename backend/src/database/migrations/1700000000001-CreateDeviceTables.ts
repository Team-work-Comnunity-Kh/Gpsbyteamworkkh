import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateDeviceTables1700000000001 implements MigrationInterface {
  name = 'CreateDeviceTables1700000000001';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Devices table
    await queryRunner.query(`
      CREATE TABLE devices (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        "deviceId" VARCHAR(100) NOT NULL UNIQUE,
        "deviceName" VARCHAR(100) NOT NULL,
        "deviceModel" VARCHAR(50),
        "osVersion" VARCHAR(50),
        "appVersion" VARCHAR(50),
        status device_status DEFAULT 'active',
        "lastLocation" GEOGRAPHY(Point, 4326),
        "lastLatitude" FLOAT,
        "lastLongitude" FLOAT,
        "lastAltitude" FLOAT,
        "lastSpeed" FLOAT,
        "lastHeading" FLOAT,
        "lastAccuracy" FLOAT,
        "lastLocationTime" TIMESTAMP,
        "batteryLevel" INT,
        "isCharging" BOOLEAN DEFAULT FALSE,
        "isTracking" BOOLEAN DEFAULT FALSE,
        "gpsInfo" JSONB,
        settings JSONB,
        "isOnline" BOOLEAN DEFAULT TRUE,
        "lastSeenAt" TIMESTAMP,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW(),
        "deletedAt" TIMESTAMP
      );
      
      CREATE INDEX idx_devices_user ON devices("userId");
      CREATE INDEX idx_devices_device_id ON devices("deviceId");
      CREATE INDEX idx_devices_last_location ON devices USING GIST("lastLocation");
      CREATE INDEX idx_devices_status ON devices(status);
      
      CREATE TRIGGER update_devices_updated_at BEFORE UPDATE ON devices
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    `);

    // Device pairs table
    await queryRunner.query(`
      CREATE TABLE device_pairs (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "sourceDeviceId" UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
        "targetDeviceId" UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
        "sourceUserId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        "targetUserId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        "pairingCode" VARCHAR(6) NOT NULL UNIQUE,
        status pair_status DEFAULT 'pending',
        permissions JSONB DEFAULT '{}',
        nickname VARCHAR(100),
        "expiresAt" TIMESTAMP,
        "acceptedAt" TIMESTAMP,
        "revokedAt" TIMESTAMP,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW(),
        CONSTRAINT device_pairs_unique UNIQUE ("sourceDeviceId", "targetDeviceId")
      );
      
      CREATE INDEX idx_device_pairs_source ON device_pairs("sourceDeviceId");
      CREATE INDEX idx_device_pairs_target ON device_pairs("targetDeviceId");
      CREATE INDEX idx_device_pairs_code ON device_pairs("pairingCode");
      CREATE INDEX idx_device_pairs_status ON device_pairs(status);
      
      CREATE TRIGGER update_device_pairs_updated_at BEFORE UPDATE ON device_pairs
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    `);

    // Device commands table
    await queryRunner.query(`
      CREATE TABLE device_commands (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "sourceDeviceId" UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
        "targetDeviceId" UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
        "issuedByUserId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        "commandType" command_type NOT NULL,
        status command_status DEFAULT 'pending',
        parameters JSONB,
        result JSONB,
        "errorMessage" TEXT,
        "sentAt" TIMESTAMP,
        "deliveredAt" TIMESTAMP,
        "executedAt" TIMESTAMP,
        "expiresAt" TIMESTAMP,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      );
      
      CREATE INDEX idx_device_commands_target_status ON device_commands("targetDeviceId", status);
      CREATE INDEX idx_device_commands_created ON device_commands("createdAt");
      
      CREATE TRIGGER update_device_commands_updated_at BEFORE UPDATE ON device_commands
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS device_commands CASCADE`);
    await queryRunner.query(`DROP TABLE IF EXISTS device_pairs CASCADE`);
    await queryRunner.query(`DROP TABLE IF EXISTS devices CASCADE`);
  }
}
