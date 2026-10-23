import {
  Controller, Get, Post, Delete, Body, Param, UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { TracksService } from './tracks.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('tracks')
@Controller('tracks')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class TracksController {
  constructor(private readonly tracksService: TracksService) {}

  @Get()
  @ApiOperation({ summary: 'Get all tracks' })
  findAll(@CurrentUser('id') userId: string) {
    return this.tracksService.findAllTracks(userId);
  }

  @Post()
  @ApiOperation({ summary: 'Start a new track recording' })
  create(@CurrentUser('id') userId: string, @Body() data: any) {
    return this.tracksService.createTrack(userId, data);
  }

  @Post(':id/stop')
  @ApiOperation({ summary: 'Stop track recording' })
  stop(@Param('id') id: string, @CurrentUser('id') userId: string) {
    return this.tracksService.stopTrack(id, userId);
  }

  @Post(':id/points')
  @ApiOperation({ summary: 'Add point to track' })
  addPoint(
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
    @Body() data: any,
  ) {
    return this.tracksService.addTrackPoint(id, userId, data);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete track' })
  remove(@Param('id') id: string, @CurrentUser('id') userId: string) {
    return this.tracksService.deleteTrack(id, userId);
  }
}

// Waypoints sub-controller
@ApiTags('waypoints')
@Controller('waypoints')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class WaypointsController {
  constructor(private readonly tracksService: TracksService) {}

  @Get()
  @ApiOperation({ summary: 'Get all waypoints' })
  findAll(@CurrentUser('id') userId: string) {
    return this.tracksService.findAllWaypoints(userId);
  }

  @Post()
  @ApiOperation({ summary: 'Create waypoint' })
  create(@CurrentUser('id') userId: string, @Body() data: any) {
    return this.tracksService.createWaypoint(userId, data);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete waypoint' })
  remove(@Param('id') id: string, @CurrentUser('id') userId: string) {
    return this.tracksService.deleteWaypoint(id, userId);
  }
}
