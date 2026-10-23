import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule } from '@nestjs/throttler';

// Modules
import { AuthModule } from './modules/auth/auth.module';
import { DevicesModule } from './modules/devices/devices.module';
import { ParcelsModule } from './modules/parcels/parcels.module';
import { TracksModule } from './modules/tracks/tracks.module';
import { GeofencesModule } from './modules/geofences/geofences.module';
import { ToolsModule } from './modules/tools/tools.module';
import { ExportModule } from './modules/export/export.module';
import { UsersModule } from './modules/users/users.module';

// Entities
import { User } from './modules/auth/entities/user.entity';
import { RefreshToken } from './modules/auth/entities/refresh-token.entity';
import { OtpCode } from './modules/auth/entities/otp-code.entity';
import { Device } from './modules/devices/entities/device.entity';
import { DevicePair } from './modules/devices/entities/device-pair.entity';
import { DeviceCommand } from './modules/devices/entities/device-command.entity';
import { Parcel } from './modules/parcels/entities/parcel.entity';
import { Track } from './modules/tracks/entities/track.entity';
import { TrackPoint } from './modules/tracks/entities/track-point.entity';
import { Waypoint } from './modules/tracks/entities/waypoint.entity';
import { Geofence } from './modules/geofences/entities/geofence.entity';
import { GeofenceAlert } from './modules/geofences/entities/geofence-alert.entity';

// Gateways
import { LocationGateway } from './gateways/location.gateway';

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),

        // Keep schema synchronization off in production by default. For a new
        // deployment, DB_SCHEMA_SYNC=true may be used once to create the initial
        // schema from entity metadata, then switched back to false.
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DATABASE_HOST', 'localhost'),
        port: configService.get<number>('DATABASE_PORT', 5432),
        username: configService.get('DATABASE_USER', 'smartgps'),
        password: configService.get('DATABASE_PASSWORD', 'smartgps123'),
        database: configService.get('DATABASE_NAME', 'smartgps_db'),
        entities: [
          User, RefreshToken, OtpCode,
          Device, DevicePair, DeviceCommand,
          Parcel, Track, TrackPoint, Waypoint,
          Geofence, GeofenceAlert,
        ],
        synchronize:
          configService.get('NODE_ENV') !== 'production' ||
          configService.get('DB_SCHEMA_SYNC') === 'true',
        logging: configService.get('NODE_ENV') === 'development',
        ssl: false,
        // Retry connection on failure
        retryAttempts: 3,
        retryDelay: 3000,
        // PostGIS support
        extra: {
          options: '-c search_path=public',
        },
      }),
      inject: [ConfigService],
    }),

    // Rate limiting
    ThrottlerModule.forRoot([
      {
        ttl: 60000,
        limit: 100,
      },
    ]),

    // Feature modules
    AuthModule,
    DevicesModule,
    ParcelsModule,
    TracksModule,
    GeofencesModule,
    ToolsModule,
    ExportModule,
    UsersModule,
  ],
  providers: [LocationGateway],
})
export class AppModule {}
