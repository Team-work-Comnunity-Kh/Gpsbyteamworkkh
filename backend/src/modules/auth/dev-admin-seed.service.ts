import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import * as bcrypt from 'bcrypt';
import { Repository } from 'typeorm';
import { User, UserRole } from './entities/user.entity';

@Injectable()
export class DevAdminSeedService implements OnApplicationBootstrap {
  private readonly logger = new Logger(DevAdminSeedService.name);

  constructor(
    private readonly config: ConfigService,
    @InjectRepository(User) private readonly users: Repository<User>,
  ) {}

  async onApplicationBootstrap(): Promise<void> {
    if (this.config.get('NODE_ENV') !== 'development') return;

    const email = this.config.get<string>('ADMIN_EMAIL');
    const password = this.config.get<string>('ADMIN_PASSWORD');
    if (!email || !password) {
      this.logger.warn(
        'Skipping development admin creation: set ADMIN_EMAIL and ADMIN_PASSWORD.',
      );
      return;
    }
    const existing = await this.users.findOne({ where: { email } });

    if (existing) return;

    const admin = this.users.create({
      email,
      password: await bcrypt.hash(password, 10),
      firstName: 'SmartGPS',
      lastName: 'Admin',
      role: UserRole.ADMIN,
      emailVerified: true,
      isActive: true,
    });

    await this.users.save(admin);
    this.logger.log(`Development admin account created: ${email}`);
  }
}
