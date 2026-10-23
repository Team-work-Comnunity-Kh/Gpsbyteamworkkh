import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import { Device } from '../devices/entities/device.entity';
import { Track } from '../tracks/entities/track.entity';
import { User } from '../auth/entities/user.entity';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(User) private readonly users: Repository<User>,
    @InjectRepository(Device) private readonly devices: Repository<Device>,
    @InjectRepository(Track) private readonly tracks: Repository<Track>,
  ) {}

  async getStats() {
    const onlineSince = new Date(Date.now() - 5 * 60 * 1000);
    const [totalUsers, totalDevices, onlineDevices, recordedTracks] =
      await Promise.all([
        this.users.count({ where: { deletedAt: IsNull() } }),
        this.devices.count({ where: { deletedAt: IsNull() } }),
        this.devices
          .createQueryBuilder('device')
          .where('device.deletedAt IS NULL')
          .andWhere('COALESCE(device.lastSeenAt, device.lastLocationTime, device.updatedAt) > :onlineSince', { onlineSince })
          .getCount(),
        this.tracks.count({ where: { deletedAt: IsNull() } }),
      ]);

    return { totalUsers, totalDevices, onlineDevices, recordedTracks };
  }

  async getDevices() {
    const devices = await this.devices
      .createQueryBuilder('device')
      .leftJoinAndSelect('device.user', 'user')
      .where('device.deletedAt IS NULL')
      .orderBy('device.updatedAt', 'DESC')
      .getMany();

    return devices.map((device) => ({
      id: device.id,
      deviceId: device.deviceId,
      deviceName: device.deviceName,
      deviceModel: device.deviceModel,
      osVersion: device.osVersion,
      appVersion: device.appVersion,
      status: device.status,
      isOnline:
        (device.lastSeenAt ?? device.lastLocationTime ?? device.updatedAt).getTime() >
        Date.now() - 5 * 60 * 1000,
      isTracking: device.isTracking,
      batteryLevel: device.batteryLevel,
      lastLatitude: device.lastLatitude,
      lastLongitude: device.lastLongitude,
      lastLocationTime: device.lastLocationTime,
      lastSeenAt: device.lastSeenAt,
      user: device.user
        ? {
            firstName: device.user.firstName,
            lastName: device.user.lastName,
            email: device.user.email,
            phone: device.user.phone,
          }
        : null,
    }));
  }

  async getLocations() {
    const devices = await this.devices
      .createQueryBuilder('device')
      .leftJoinAndSelect('device.user', 'user')
      .where('device.deletedAt IS NULL')
      .andWhere('device.lastLatitude IS NOT NULL')
      .andWhere('device.lastLongitude IS NOT NULL')
      .orderBy('device.lastLocationTime', 'DESC', 'NULLS LAST')
      .take(500)
      .getMany();

    return devices.map((device) => ({
      id: device.id,
      deviceName: device.deviceName,
      latitude: device.lastLatitude,
      longitude: device.lastLongitude,
      lastLocationTime: device.lastLocationTime,
      isTracking: device.isTracking,
      userName: device.user
        ? `${device.user.firstName} ${device.user.lastName}`.trim()
        : 'Unknown user',
    }));
  }

  async getActivity() {
    const since = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const [tracks, devices] = await Promise.all([
      this.tracks
        .createQueryBuilder('track')
        .leftJoinAndSelect('track.user', 'user')
        .where('track.deletedAt IS NULL')
        .andWhere('track.createdAt > :since', { since })
        .orderBy('track.createdAt', 'DESC')
        .take(50)
        .getMany(),
      this.devices
        .createQueryBuilder('device')
        .leftJoinAndSelect('device.user', 'user')
        .where('device.deletedAt IS NULL')
        .andWhere('device.lastLocationTime IS NOT NULL')
        .andWhere('device.lastLocationTime > :since', { since })
        .orderBy('device.lastLocationTime', 'DESC')
        .take(50)
        .getMany(),
    ]);

    const activity = [
      ...tracks.map((track) => ({
        id: `track-${track.id}`,
        type: track.isRecording ? 'track-recording' : 'track',
        description: track.isRecording
          ? `Started recording: ${track.name}`
          : `Track: ${track.name}`,
        userName: track.user
          ? `${track.user.firstName} ${track.user.lastName}`.trim()
          : 'Unknown user',
        timestamp: track.updatedAt,
      })),
      ...devices.map((device) => ({
        id: `location-${device.id}`,
        type: 'location',
        description: `Location updated: ${device.deviceName}`,
        userName: device.user
          ? `${device.user.firstName} ${device.user.lastName}`.trim()
          : 'Unknown user',
        timestamp: device.lastLocationTime,
      })),
    ];

    return activity.sort(
      (a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime(),
    );
  }
}
