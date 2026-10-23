import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { User } from './entities/user.entity';
import { RefreshToken } from './entities/refresh-token.entity';
import { OtpCode, OtpPurpose } from './entities/otp-code.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(RefreshToken)
    private refreshTokenRepository: Repository<RefreshToken>,
    @InjectRepository(OtpCode)
    private otpCodeRepository: Repository<OtpCode>,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async register(registerDto: RegisterDto) {
    const { email, phone, password, firstName, lastName, language } = registerDto;

    // Validate that at least email or phone is provided
    if (!email && !phone) {
      throw new BadRequestException('Email or phone number is required');
    }

    // Check if user already exists
    if (email) {
      const existingUser = await this.userRepository.findOne({ where: { email } });
      if (existingUser) {
        throw new ConflictException('User with this email already exists');
      }
    }

    if (phone) {
      const existingUser = await this.userRepository.findOne({ where: { phone } });
      if (existingUser) {
        throw new ConflictException('User with this phone number already exists');
      }
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = this.userRepository.create({
      email,
      phone,
      password: hashedPassword,
      firstName,
      lastName,
      language: language || 'km',
    });

    await this.userRepository.save(user);

    // Generate tokens
    const tokens = await this.generateTokens(user);

    return {
      user: this.sanitizeUser(user),
      ...tokens,
    };
  }

  async login(loginDto: LoginDto, ipAddress?: string, userAgent?: string) {
    const { email, phone, password } = loginDto;

    if (!email && !phone) {
      throw new BadRequestException('Email or phone number is required');
    }

    // Find user
    const user = await this.userRepository.findOne({
      where: email ? { email } : { phone },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.isActive) {
      throw new UnauthorizedException('Account is deactivated');
    }

    // Update last login
    user.lastLoginAt = new Date();
    await this.userRepository.save(user);

    // Generate tokens
    const tokens = await this.generateTokens(user, ipAddress, userAgent);

    return {
      user: this.sanitizeUser(user),
      ...tokens,
    };
  }

  async refreshToken(refreshToken: string, ipAddress?: string, userAgent?: string) {
    const tokenRecord = await this.refreshTokenRepository.findOne({
      where: {
        token: refreshToken,
        isRevoked: false,
        expiresAt: MoreThan(new Date()),
      },
      relations: ['user'],
    });

    if (!tokenRecord) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    // Revoke old refresh token
    tokenRecord.isRevoked = true;
    tokenRecord.revokedAt = new Date();
    await this.refreshTokenRepository.save(tokenRecord);

    // Generate new tokens
    const tokens = await this.generateTokens(
      tokenRecord.user,
      ipAddress,
      userAgent,
    );

    return tokens;
  }

  async sendOtp(sendOtpDto: SendOtpDto) {
    const { email, phone, purpose } = sendOtpDto;

    if (!email && !phone) {
      throw new BadRequestException('Email or phone number is required');
    }

    const identifier = email || phone;

    // Generate 6-digit OTP
    const code = Math.floor(100000 + Math.random() * 900000).toString();

    // Create OTP record
    const otp = this.otpCodeRepository.create({
      code,
      purpose,
      identifier,
      expiresAt: new Date(Date.now() + 10 * 60 * 1000), // 10 minutes
    });

    await this.otpCodeRepository.save(otp);

    // TODO: Send OTP via SMS/Email service
    console.log(`OTP for ${identifier}: ${code}`);

    return {
      message: 'OTP sent successfully',
      identifier,
      expiresAt: otp.expiresAt,
    };
  }

  async verifyOtp(verifyOtpDto: VerifyOtpDto) {
    const { code, identifier, purpose } = verifyOtpDto;

    const otp = await this.otpCodeRepository.findOne({
      where: {
        code,
        identifier,
        purpose,
        isUsed: false,
        expiresAt: MoreThan(new Date()),
      },
    });

    if (!otp) {
      throw new BadRequestException('Invalid or expired OTP code');
    }

    // Update OTP as used
    otp.isUsed = true;
    otp.usedAt = new Date();
    await this.otpCodeRepository.save(otp);

    // If verification purpose, update user
    if (purpose === OtpPurpose.PHONE_VERIFICATION) {
      const user = await this.userRepository.findOne({ where: { phone: identifier } });
      if (user) {
        user.phoneVerified = true;
        await this.userRepository.save(user);
      }
    } else if (purpose === OtpPurpose.EMAIL_VERIFICATION) {
      const user = await this.userRepository.findOne({ where: { email: identifier } });
      if (user) {
        user.emailVerified = true;
        await this.userRepository.save(user);
      }
    }

    return {
      message: 'OTP verified successfully',
      verified: true,
    };
  }

  async logout(userId: string, refreshToken?: string) {
    if (refreshToken) {
      await this.refreshTokenRepository.update(
        { token: refreshToken, userId },
        { isRevoked: true, revokedAt: new Date() },
      );
    } else {
      // Revoke all refresh tokens
      await this.refreshTokenRepository.update(
        { userId, isRevoked: false },
        { isRevoked: true, revokedAt: new Date() },
      );
    }

    return { message: 'Logged out successfully' };
  }

  private async generateTokens(
    user: User,
    ipAddress?: string,
    userAgent?: string,
  ) {
    const payload = {
      sub: user.id,
      email: user.email,
      phone: user.phone,
      role: user.role,
    };

    const accessToken = this.jwtService.sign(payload, {
      secret: this.configService.get('JWT_SECRET'),
      expiresIn: this.configService.get('JWT_EXPIRES_IN', '15m'),
    });

    const refreshToken = this.jwtService.sign(payload, {
      secret: this.configService.get('REFRESH_TOKEN_SECRET'),
      expiresIn: this.configService.get('REFRESH_TOKEN_EXPIRES_IN', '7d'),
    });

    // Save refresh token
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // 7 days

    const refreshTokenRecord = this.refreshTokenRepository.create({
      token: refreshToken,
      userId: user.id,
      expiresAt,
      ipAddress,
      userAgent,
    });

    await this.refreshTokenRepository.save(refreshTokenRecord);

    return {
      accessToken,
      refreshToken,
      expiresIn: this.configService.get('JWT_EXPIRES_IN', '15m'),
    };
  }

  private sanitizeUser(user: User) {
    const { password, ...result } = user;
    return result;
  }
}
