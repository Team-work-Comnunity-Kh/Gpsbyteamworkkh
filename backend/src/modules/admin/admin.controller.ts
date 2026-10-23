import {
  Controller,
  ForbiddenException,
  Get,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AdminService } from './admin.service';

@ApiTags('admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  private requireAdmin(role: string) {
    if (role !== 'admin') throw new ForbiddenException('Admin access required');
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get live admin dashboard statistics' })
  getStats(@CurrentUser('role') role: string) {
    this.requireAdmin(role);
    return this.adminService.getStats();
  }

  @Get('devices')
  @ApiOperation({ summary: 'List all registered devices for administrators' })
  getDevices(@CurrentUser('role') role: string) {
    this.requireAdmin(role);
    return this.adminService.getDevices();
  }

  @Get('locations')
  @ApiOperation({ summary: 'List latest known device locations for administrators' })
  getLocations(@CurrentUser('role') role: string) {
    this.requireAdmin(role);
    return this.adminService.getLocations();
  }

  @Get('activity')
  @ApiOperation({ summary: 'List recent real device and track activity' })
  getActivity(@CurrentUser('role') role: string) {
    this.requireAdmin(role);
    return this.adminService.getActivity();
  }
}
