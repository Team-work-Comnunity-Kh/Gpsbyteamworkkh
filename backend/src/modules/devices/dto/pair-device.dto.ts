import { ApiProperty } from '@nestjs/swagger';
import { IsString, Length, IsOptional, IsBoolean } from 'class-validator';

export class PairDeviceDto {
  @ApiProperty({ example: '123456', description: '6-digit pairing code' })
  @IsString()
  @Length(6, 6)
  pairingCode: string;

  @ApiProperty({ example: 'My Friend Phone', required: false })
  @IsOptional()
  @IsString()
  nickname?: string;
}

export class UpdatePairPermissionsDto {
  @ApiProperty({ example: true })
  @IsOptional()
  @IsBoolean()
  canViewLocation?: boolean;

  @ApiProperty({ example: true })
  @IsOptional()
  @IsBoolean()
  canSendCommands?: boolean;

  @ApiProperty({ example: false })
  @IsOptional()
  @IsBoolean()
  canViewHistory?: boolean;

  @ApiProperty({ example: true })
  @IsOptional()
  @IsBoolean()
  canRingDevice?: boolean;

  @ApiProperty({ example: true })
  @IsOptional()
  @IsBoolean()
  canSendMessages?: boolean;
}

export class SendCommandDto {
  @ApiProperty({ 
    example: 'request_location',
    enum: ['request_location', 'start_tracking', 'stop_tracking', 'ring_device', 'send_message', 'update_settings']
  })
  @IsString()
  commandType: string;

  @ApiProperty({ example: { duration: 30 }, required: false })
  @IsOptional()
  parameters?: Record<string, any>;
}
