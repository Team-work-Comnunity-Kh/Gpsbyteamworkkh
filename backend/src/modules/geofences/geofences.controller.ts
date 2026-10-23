import { Controller, Get, Post, Body, Param, Delete, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { GeofencesService } from './geofences.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('geofences')
@Controller('geofences')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class GeofencesController {
  constructor(private readonly geofencesService: GeofencesService) {}

  @Get()
  @ApiOperation({ summary: 'Get all user geofences' })
  findAll(@CurrentUser('id') userId: string) {
    return this.geofencesService.findAll(userId);
  }

  @Post()
  @ApiOperation({ summary: 'Create new geofence' })
  create(@CurrentUser('id') userId: string, @Body() data: any) {
    return this.geofencesService.create(userId, data);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete geofence' })
  remove(@Param('id') id: string, @CurrentUser('id') userId: string) {
    return this.geofencesService.remove(id, userId);
  }

  @Get('alerts')
  @ApiOperation({ summary: 'Get alerts' })
  getAlerts(@CurrentUser('id') userId: string) {
    return this.geofencesService.getAlerts(userId);
  }
}
