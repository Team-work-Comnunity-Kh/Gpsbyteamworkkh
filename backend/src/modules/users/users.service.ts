import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Brackets, IsNull, Repository } from 'typeorm';
import { User } from '../auth/entities/user.entity';
import { RefreshToken } from '../auth/entities/refresh-token.entity';

interface ListUsersOptions {
  page?: string;
  limit?: string;
  search?: string;
  role?: string;
  active?: string;
}

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User) private readonly users: Repository<User>,
    @InjectRepository(RefreshToken) private readonly refreshTokens: Repository<RefreshToken>,
  ) {}

  async delete(id: string) {
    const user = await this.users.findOne({ where: { id, deletedAt: IsNull() } });
    if (!user) throw new NotFoundException('User not found');
    if (user.role === 'admin') {
      throw new ForbiddenException('Administrator accounts cannot be deleted here');
    }

    const deletedAt = new Date();
    await this.users.manager.transaction(async (manager) => {
      await manager.getRepository(User).update(id, { isActive: false, deletedAt });
      await manager.getRepository(RefreshToken).update(
        { userId: id, isRevoked: false },
        { isRevoked: true, revokedAt: deletedAt },
      );
    });

    return { success: true, id };
  }

  async list(options: ListUsersOptions) {
    const page = this.toPositiveInteger(options.page, 1, 1_000_000);
    const limit = this.toPositiveInteger(options.limit, 20, 100);
    const search = options.search?.trim().slice(0, 120);
    const query = this.users
      .createQueryBuilder('user')
      .where('user.deletedAt IS NULL');

    if (search) {
      query.andWhere(
        new Brackets((qb) => {
          qb.where('user.email ILIKE :search', { search: `%${search}%` })
            .orWhere('user.phone ILIKE :search', { search: `%${search}%` })
            .orWhere('user.firstName ILIKE :search', { search: `%${search}%` })
            .orWhere('user.lastName ILIKE :search', { search: `%${search}%` });
        }),
      );
    }

    if (options.role === 'admin' || options.role === 'user') {
      query.andWhere('user.role = :role', { role: options.role });
    }
    if (options.active === 'true' || options.active === 'false') {
      query.andWhere('user.isActive = :active', { active: options.active === 'true' });
    }

    const [items, total] = await query
      .select([
        'user.id',
        'user.email',
        'user.phone',
        'user.firstName',
        'user.lastName',
        'user.role',
        'user.avatar',
        'user.emailVerified',
        'user.phoneVerified',
        'user.isActive',
        'user.lastLoginAt',
        'user.createdAt',
      ])
      .orderBy('user.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getManyAndCount();

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  private toPositiveInteger(value: string | undefined, fallback: number, max: number) {
    const parsed = Number.parseInt(value ?? '', 10);
    return Number.isFinite(parsed) && parsed > 0 ? Math.min(parsed, max) : fallback;
  }
}
