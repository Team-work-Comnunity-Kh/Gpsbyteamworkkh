-- SmartGPS Database Initialization Script
-- Enable PostGIS extension for spatial data support

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('admin', 'user');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE device_status AS ENUM ('active', 'inactive', 'lost', 'maintenance');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE command_status AS ENUM ('pending', 'sent', 'delivered', 'executed', 'failed', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE command_type AS ENUM ('request_location', 'start_tracking', 'stop_tracking', 'ring_device', 'send_message', 'update_settings');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE geofence_type AS ENUM ('circle', 'polygon');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE alert_type AS ENUM ('geofence_enter', 'geofence_exit', 'sos', 'low_battery', 'device_offline');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create indices for better spatial query performance
-- These will be created automatically by TypeORM, but we define them here for reference

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE smartgps_db TO smartgps;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO smartgps;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO smartgps;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create function to calculate distance between two points
CREATE OR REPLACE FUNCTION calculate_distance(
    lat1 DOUBLE PRECISION,
    lon1 DOUBLE PRECISION,
    lat2 DOUBLE PRECISION,
    lon2 DOUBLE PRECISION
) RETURNS DOUBLE PRECISION AS $$
BEGIN
    RETURN ST_DistanceSphere(
        ST_MakePoint(lon1, lat1),
        ST_MakePoint(lon2, lat2)
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create function to check if point is inside polygon
CREATE OR REPLACE FUNCTION point_in_polygon(
    point_lat DOUBLE PRECISION,
    point_lon DOUBLE PRECISION,
    polygon_geom GEOMETRY
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN ST_Contains(
        polygon_geom,
        ST_SetSRID(ST_MakePoint(point_lon, point_lat), 4326)
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON DATABASE smartgps_db IS 'SmartGPS Application Database with PostGIS support';
