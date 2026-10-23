import { Controller, Delete, ForbiddenException, Get, Param, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UsersService } from './users.service';

@ApiTags('users')
@ApiBearerAuth()
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @ApiOperation({ summary: 'List users (admin only)' })
  async listUsers(
    @CurrentUser('role') role: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('search') search?: string,
    @Query('role') roleFilter?: string,
    @Query('active') active?: string,
  ) {
    if (role !== 'admin') {
      throw new ForbiddenException('Admin access required');
    }

    return this.usersService.list({ page, limit, search, role: roleFilter, active });
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Deactivate and soft-delete a user (admin only)' })
  async deleteUser(
    @CurrentUser('role') role: string,
    @CurrentUser('id') actorId: string,
    @Param('id') userId: string,
  ) {
    if (role !== 'admin') {
      throw new ForbiddenException('Admin access required');
    }
    if (actorId === userId) {
      throw new ForbiddenException('You cannot delete your own account');
    }

    return this.usersService.delete(userId);
  }
}
