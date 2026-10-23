import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsEnum, IsOptional, IsEmail, Matches } from 'class-validator';
import { OtpPurpose } from '../entities/otp-code.entity';

export class SendOtpDto {
  @ApiProperty({ example: 'user@example.com', required: false })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiProperty({ example: '+855123456789', required: false })
  @IsOptional()
  @Matches(/^\+?[1-9]\d{1,14}$/)
  phone?: string;

  @ApiProperty({
    example: 'phone_verification',
    enum: OtpPurpose,
  })
  @IsEnum(OtpPurpose)
  purpose: OtpPurpose;
}
