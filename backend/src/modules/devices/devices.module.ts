import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DevicesService } from './devices.service';
import { DevicesController } from './devices.controller';
import { Device } from './entities/device.entity';
import { DevicePair } from './entities/device-pair.entity';
import { DeviceCommand } from './entities/device-command.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Device, DevicePair, DeviceCommand])],
  controllers: [DevicesController],
  providers: [DevicesService],
  exports: [DevicesService],
})
export class DevicesModule {}
