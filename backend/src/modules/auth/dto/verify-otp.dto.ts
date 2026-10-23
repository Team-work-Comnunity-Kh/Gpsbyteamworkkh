import { ApiProperty } from '@nestjs/swagger';
import { IsString, Length, IsEnum } from 'class-validator';
import { OtpPurpose } from '../entities/otp-code.entity';

export class VerifyOtpDto {
  @ApiProperty({ example: '123456' })
  @IsString()
  @Length(6, 6, { message: 'OTP code must be 6 digits' })
  code: string;

  @ApiProperty({ example: 'user@example.com or +855123456789' })
  @IsString()
  identifier: string;

  @ApiProperty({
    example: 'phone_verification',
    enum: OtpPurpose,
  })
  @IsEnum(OtpPurpose)
  purpose: OtpPurpose;
}
