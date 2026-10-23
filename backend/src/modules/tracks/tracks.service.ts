import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import { Track } from './entities/track.entity';
import { TrackPoint } from './entities/track-point.entity';
import { Waypoint } from './entities/waypoint.entity';

@Injectable()
export class TracksService {
  constructor(
    @InjectRepository(Track)
    private trackRepository: Repository<Track>,
    @InjectRepository(TrackPoint)
    private trackPointRepository: Repository<TrackPoint>,
    @InjectRepository(Waypoint)
    private waypointRepository: Repository<Waypoint>,
  ) {}

  // ---- Tracks ----
  async createTrack(userId: string, data: any) {
    const track = this.trackRepository.create({
      ...data,
      userId,
      startTime: new Date(),
      isRecording: true,
    });
    return this.trackRepository.save(track);
  }

  async findAllTracks(userId: string) {
    return this.trackRepository.find({
      where: { userId, deletedAt: IsNull() },
      order: { startTime: 'DESC' },
    });
  }

  async findOneTrack(id: string, userId: string) {
    const track = await this.trackRepository.findOne({ where: { id, userId } });
    if (!track) throw new NotFoundException('Track not found');
    return track;
  }

  async addTrackPoint(trackId: string, userId: string, pointData: any) {
    const track = await this.findOneTrack(trackId, userId);
    if (!track.isRecording) {
      throw new BadRequestException('Track is not recording');
    }
    const pointCount = await this.trackPointRepository.count({ where: { trackId } });
    const point = this.trackPointRepository.create({
      ...pointData,
      trackId,
      timestamp: new Date(),
      sequence: pointData.sequence ?? pointCount,
    });
    return this.trackPointRepository.save(point);
  }

  async stopTrack(id: string, userId: string) {
    const track = await this.findOneTrack(id, userId);
    track.isRecording = false;
    track.endTime = new Date();
    if (track.startTime) {
      track.totalDurationSeconds = Math.floor(
        (track.endTime.getTime() - track.startTime.getTime()) / 1000,
      );
    }
    return this.trackRepository.save(track);
  }

  async deleteTrack(id: string, userId: string) {
    const track = await this.findOneTrack(id, userId);
    track.deletedAt = new Date();
    await this.trackRepository.save(track);
    return { message: 'Track deleted' };
  }

  // ---- Waypoints ----
  async createWaypoint(userId: string, data: any) {
    const waypoint = this.waypointRepository.create({ ...data, userId });
    return this.waypointRepository.save(waypoint);
  }

  async findAllWaypoints(userId: string) {
    return this.waypointRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async deleteWaypoint(id: string, userId: string) {
    const wp = await this.waypointRepository.findOne({ where: { id, userId } });
    if (wp) {
      wp.deletedAt = new Date();
      await this.waypointRepository.save(wp);
    }
    return { message: 'Waypoint deleted' };
  }
}
