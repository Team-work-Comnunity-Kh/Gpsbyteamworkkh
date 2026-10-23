import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Track } from './entities/track.entity';
import { TrackPoint } from './entities/track-point.entity';
import { Waypoint } from './entities/waypoint.entity';
import { TracksController, WaypointsController } from './tracks.controller';
import { TracksService } from './tracks.service';

@Module({
  imports: [TypeOrmModule.forFeature([Track, TrackPoint, Waypoint])],
  controllers: [TracksController, WaypointsController],
  providers: [TracksService],
  exports: [TracksService],
})
export class TracksModule {}
