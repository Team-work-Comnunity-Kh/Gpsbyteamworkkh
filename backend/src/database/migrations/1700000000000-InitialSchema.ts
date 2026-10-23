import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitialSchema1700000000000 implements MigrationInterface {
  name = 'InitialSchema1700000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Enable PostGIS extension
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS postgis`);
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`);

    // Create custom types
    await queryRunner.query(`
      DO $$ BEGIN
        CREATE TYPE user_role AS ENUM ('admin', 'user');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `);

    await queryRunner.query(`
      DO $$ BEGIN
        CREATE TYPE device_status AS ENUM ('active', 'inactive', 'lost', 'maintenance');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `);

    await queryRunner.query(`
      DO $$ BEGIN
        CREATE TYPE pair_status AS ENUM ('pending', 'active', 'rejected', 'expired', 'revoked');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `);

    await queryRunner.query(`
      DO $$ BEGIN
        CREATE TYPE command_type AS ENUM ('request_location', 'start_tracking', 'stop_tracking', 'ring_device', 'send_message', 'update_settings');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `);

    await queryRunner.query(`
      DO $$ BEGIN
        CREATE TYPE command_status AS ENUM ('pending', 'sent', 'delivered', 'executed', 'failed', 'cancelled');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `);

    await queryRunner.query(`
      DO $$ BEGIN
        CREATE TYPE geofence_type AS ENUM ('circle', 'polygon');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `);

    await queryRunner.query(`
      DO $$ BEGIN
        CREATE TYPE alert_type AS ENUM ('geofence_enter', 'geofence_exit', 'sos', 'low_battery', 'device_offline');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `);

    await queryRunner.query(`
      DO $$ BEGIN
        CREATE TYPE otp_purpose AS ENUM ('phone_verification', 'email_verification', 'password_reset', 'login');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `);

    // Create function to update updated_at timestamp
    await queryRunner.query(`
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
          NEW.updated_at = NOW();
          RETURN NEW;
      END;
      $$ language 'plpgsql';
    `);

    // Users table
    await queryRunner.query(`
      CREATE TABLE users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        email VARCHAR(255),
        phone VARCHAR(20),
        password VARCHAR(255) NOT NULL,
        "firstName" VARCHAR(100) NOT NULL,
        "lastName" VARCHAR(100) NOT NULL,
        role user_role DEFAULT 'user',
        avatar VARCHAR(500),
        language VARCHAR(10) DEFAULT 'km',
        "googleId" VARCHAR(50),
        "emailVerified" BOOLEAN DEFAULT FALSE,
        "phoneVerified" BOOLEAN DEFAULT FALSE,
        "isActive" BOOLEAN DEFAULT TRUE,
        "fcmToken" VARCHAR(255),
        settings JSONB,
        "lastLoginAt" TIMESTAMP,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW(),
        "deletedAt" TIMESTAMP,
        CONSTRAINT users_email_unique UNIQUE (email) WHERE email IS NOT NULL,
        CONSTRAINT users_phone_unique UNIQUE (phone) WHERE phone IS NOT NULL
      );
      
      CREATE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
      CREATE INDEX idx_users_phone ON users(phone) WHERE phone IS NOT NULL;
      CREATE INDEX idx_users_role ON users(role);
      
      CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    `);

    // Refresh tokens table
    await queryRunner.query(`
      CREATE TABLE refresh_tokens (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        token VARCHAR(500) NOT NULL UNIQUE,
        "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        "expiresAt" TIMESTAMP NOT NULL,
        "isRevoked" BOOLEAN DEFAULT FALSE,
        "ipAddress" VARCHAR(45),
        "userAgent" VARCHAR(500),
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "revokedAt" TIMESTAMP
      );
      
      CREATE INDEX idx_refresh_tokens_user_revoked ON refresh_tokens("userId", "isRevoked");
    `);

    // OTP codes table
    await queryRunner.query(`
      CREATE TABLE otp_codes (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "userId" UUID REFERENCES users(id) ON DELETE CASCADE,
        code VARCHAR(6) NOT NULL,
        purpose otp_purpose NOT NULL,
        identifier VARCHAR(100),
        "expiresAt" TIMESTAMP NOT NULL,
        "isUsed" BOOLEAN DEFAULT FALSE,
        "usedAt" TIMESTAMP,
        attempts INT DEFAULT 0,
        "createdAt" TIMESTAMP DEFAULT NOW()
      );
      
      CREATE INDEX idx_otp_user_purpose ON otp_codes("userId", purpose, "isUsed");
      CREATE INDEX idx_otp_code_expires ON otp_codes(code, "expiresAt");
    `);

    // Continue in next part...
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS otp_codes CASCADE`);
    await queryRunner.query(`DROP TABLE IF EXISTS refresh_tokens CASCADE`);
    await queryRunner.query(`DROP TABLE IF EXISTS users CASCADE`);
    await queryRunner.query(`DROP FUNCTION IF EXISTS update_updated_at_column CASCADE`);
    await queryRunner.query(`DROP TYPE IF EXISTS otp_purpose CASCADE`);
    await queryRunner.query(`DROP TYPE IF EXISTS alert_type CASCADE`);
    await queryRunner.query(`DROP TYPE IF EXISTS geofence_type CASCADE`);
    await queryRunner.query(`DROP TYPE IF EXISTS command_status CASCADE`);
    await queryRunner.query(`DROP TYPE IF EXISTS command_type CASCADE`);
    await queryRunner.query(`DROP TYPE IF EXISTS pair_status CASCADE`);
    await queryRunner.query(`DROP TYPE IF EXISTS device_status CASCADE`);
    await queryRunner.query(`DROP TYPE IF EXISTS user_role CASCADE`);
  }
}
