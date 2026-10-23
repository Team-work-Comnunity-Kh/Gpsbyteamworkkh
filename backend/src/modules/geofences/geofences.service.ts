import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Geofence } from './entities/geofence.entity';
import { GeofenceAlert } from './entities/geofence-alert.entity';

@Injectable()
export class GeofencesService {
  constructor(
    @InjectRepository(Geofence)
    private geofenceRepository: Repository<Geofence>,
    @InjectRepository(GeofenceAlert)
    private alertRepository: Repository<GeofenceAlert>,
  ) {}

  async findAll(userId: string) {
    return this.geofenceRepository.find({
      where: { userId, deletedAt: IsNull() },
      order: { createdAt: 'DESC' },
    });
  }

  async create(userId: string, data: any) {
    const geofence = this.geofenceRepository.create({ ...data, userId });
    return this.geofenceRepository.save(geofence);
  }

  async remove(id: string, userId: string) {
    const geofence = await this.geofenceRepository.findOne({ where: { id, userId } });
    if (geofence) {
      geofence.deletedAt = new Date();
      await this.geofenceRepository.save(geofence);
    }
    return { message: 'Geofence deleted' };
  }

  async getAlerts(userId: string) {
    return this.alertRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      take: 50,
    });
  }
}
