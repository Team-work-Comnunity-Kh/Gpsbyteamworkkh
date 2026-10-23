import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import { Device } from './entities/device.entity';
import { DevicePair } from './entities/device-pair.entity';
import { DeviceCommand } from './entities/device-command.entity';

@Injectable()
export class DevicesService {
  constructor(
    @InjectRepository(Device)
    private deviceRepository: Repository<Device>,
    @InjectRepository(DevicePair)
    private devicePairRepository: Repository<DevicePair>,
    @InjectRepository(DeviceCommand)
    private deviceCommandRepository: Repository<DeviceCommand>,
  ) {}

  async registerOrUpdateDevice(userId: string, deviceData: any) {
    let device = await this.deviceRepository.findOne({
      where: { deviceId: deviceData.deviceId },
    });

    if (device) {
      if (device.userId !== userId) {
        throw new ForbiddenException('This device is already registered to another account');
      }
      Object.assign(device, { ...deviceData, userId, lastSeenAt: new Date(), isOnline: true });
      return this.deviceRepository.save(device);
    }

    const newDevice = this.deviceRepository.create({ ...deviceData, userId, isOnline: true } as any);
    return this.deviceRepository.save(newDevice);
  }

  async updateLocation(deviceId: string, userId: string, locationData: any) {
    const device = await this.deviceRepository.findOne({ where: { deviceId, userId } });
    if (!device) throw new NotFoundException('Device not found');

    device.lastLatitude = locationData.latitude;
    device.lastLongitude = locationData.longitude;
    device.lastAltitude = locationData.altitude;
    device.lastSpeed = locationData.speed;
    device.lastHeading = locationData.heading;
    device.lastAccuracy = locationData.accuracy;
    device.lastLocationTime = new Date();
    device.lastSeenAt = new Date();
    device.isOnline = true;
    if (locationData.gpsInfo) device.gpsInfo = locationData.gpsInfo;

    return this.deviceRepository.save(device);
  }

  async createPairingCode(userId: string, deviceId: string) {
    const device = await this.deviceRepository.findOne({ where: { id: deviceId, userId } });
    if (!device) throw new NotFoundException('Device not found');

    let pairingCode: string;
    do {
      pairingCode = Math.floor(100000 + Math.random() * 900000).toString();
    } while (await this.devicePairRepository.findOne({ where: { pairingCode } }));

    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);
    const pair = this.devicePairRepository.create({
      sourceDeviceId: device.id,
      targetDeviceId: device.id,
      sourceUserId: userId,
      targetUserId: userId,
      pairingCode,
      status: 'pending',
      permissions: { canViewLocation: true },
      expiresAt,
    });
    await this.devicePairRepository.save(pair);
    return { deviceId: device.id, deviceName: device.deviceName, pairingCode, expiresAt };
  }

  async pairWithCode(userId: string, pairingCode: string, nickname?: string) {
    const pair = await this.devicePairRepository.findOne({
      where: { pairingCode, status: 'pending' },
    });
    if (!pair || !pair.expiresAt || pair.expiresAt <= new Date()) {
      throw new NotFoundException('Pairing code is invalid or expired');
    }

    const targetDevices = await this.deviceRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
    const targetDevice = targetDevices.find((item) => item.id !== pair.sourceDeviceId);
    if (!targetDevice) {
      throw new BadRequestException('Register this phone as a device before pairing');
    }

    pair.targetDeviceId = targetDevice.id;
    pair.targetUserId = userId;
    if (nickname !== undefined) pair.nickname = nickname;
    pair.status = 'active';
    pair.acceptedAt = new Date();
    pair.pairingCode = `${pairingCode}`;
    return this.devicePairRepository.save(pair);
  }

  async getPairedDevices(userId: string, deviceId: string) {
    const device = await this.deviceRepository.findOne({ where: { id: deviceId, userId } });
    if (!device) throw new NotFoundException('Device not found');
    return this.devicePairRepository.find({
      where: [
        { sourceDeviceId: deviceId, status: 'active' },
        { targetDeviceId: deviceId, status: 'active' },
      ],
      relations: ['sourceDevice', 'targetDevice'],
    });
  }

  async sendCommand(userId: string, commandData: any) {
    const command = this.deviceCommandRepository.create({
      ...commandData,
      issuedByUserId: userId,
      status: 'pending',
      expiresAt: new Date(Date.now() + 5 * 60 * 1000),
    });
    return this.deviceCommandRepository.save(command);
  }

  async getUserDevices(userId: string) {
    return this.deviceRepository.find({
      where: { userId, deletedAt: IsNull() },
      order: { createdAt: 'DESC' },
    });
  }
}
