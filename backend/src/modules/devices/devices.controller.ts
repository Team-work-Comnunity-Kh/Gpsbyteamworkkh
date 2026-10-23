import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { DevicesService } from './devices.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { PairDeviceDto, SendCommandDto } from './dto/pair-device.dto';

@ApiTags('devices')
@Controller('devices')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class DevicesController {
  constructor(private readonly devicesService: DevicesService) {}

  @Get()
  @ApiOperation({ summary: 'Get all user devices' })
  @ApiResponse({ status: 200, description: 'List of devices' })
  async getDevices(@CurrentUser('id') userId: string) {
    return this.devicesService.getUserDevices(userId);
  }

  @Post('register')
  @ApiOperation({ summary: 'Register or update device' })
  @ApiResponse({ status: 201, description: 'Device registered' })
  async registerDevice(
    @CurrentUser('id') userId: string,
    @Body() deviceData: any,
  ) {
    return this.devicesService.registerOrUpdateDevice(userId, deviceData);
  }

  @Put(':deviceId/location')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update device location' })
  @ApiResponse({ status: 200, description: 'Location updated' })
  async updateLocation(
    @Param('deviceId') deviceId: string,
    @CurrentUser('id') userId: string,
    @Body() locationData: any,
  ) {
    return this.devicesService.updateLocation(deviceId, userId, locationData);
  }

  @Post(':deviceId/pairing-code')
  @ApiOperation({ summary: 'Generate pairing code' })
  @ApiResponse({ status: 201, description: 'Pairing code generated' })
  async createPairingCode(
    @CurrentUser('id') userId: string,
    @Param('deviceId') deviceId: string,
  ) {
    return this.devicesService.createPairingCode(userId, deviceId);
  }

  @Post('pair')
  @ApiOperation({ summary: 'Pair with another device' })
  @ApiResponse({ status: 201, description: 'Devices paired' })
  async pairDevice(
    @CurrentUser('id') userId: string,
    @Body() pairDto: PairDeviceDto,
  ) {
    return this.devicesService.pairWithCode(userId, pairDto.pairingCode, pairDto.nickname);
  }

  @Get(':deviceId/paired')
  @ApiOperation({ summary: 'Get paired devices' })
  @ApiResponse({ status: 200, description: 'List of paired devices' })
  async getPairedDevices(
    @CurrentUser('id') userId: string,
    @Param('deviceId') deviceId: string,
  ) {
    return this.devicesService.getPairedDevices(userId, deviceId);
  }

  @Post(':deviceId/commands')
  @ApiOperation({ summary: 'Send command to device' })
  @ApiResponse({ status: 201, description: 'Command sent' })
  async sendCommand(
    @CurrentUser('id') userId: string,
    @Param('deviceId') deviceId: string,
    @Body() commandDto: SendCommandDto,
  ) {
    return this.devicesService.sendCommand(userId, {
      targetDeviceId: deviceId,
      ...commandDto,
    });
  }
}
