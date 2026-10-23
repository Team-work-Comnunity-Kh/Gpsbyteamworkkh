import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Parcel } from './entities/parcel.entity';
import { CreateParcelDto } from './dto/create-parcel.dto';
import { UpdateParcelDto } from './dto/update-parcel.dto';
import * as turf from '@turf/turf';

@Injectable()
export class ParcelsService {
  constructor(
    @InjectRepository(Parcel)
    private parcelRepository: Repository<Parcel>,
  ) {}

  async create(userId: string, createParcelDto: CreateParcelDto) {
    const { coordinates, ...rest } = createParcelDto;

    const geoJsonCoords: number[][][] = (coordinates as any[]).map((ring: any[]) => {
      if (!Array.isArray(ring)) throw new BadRequestException('Invalid polygon ring');
      const points = ring.map((point: any) => {
        const pair = Array.isArray(point)
          ? [Number(point[0]), Number(point[1])]
          : [Number(point?.longitude), Number(point?.latitude)];
        if (
          !Number.isFinite(pair[0]) || !Number.isFinite(pair[1]) ||
          Math.abs(pair[0]) > 180 || Math.abs(pair[1]) > 90
        ) {
          throw new BadRequestException('Polygon points must be valid [longitude, latitude] coordinates');
        }
        return pair;
      });
      if (points.length < 3) {
        throw new BadRequestException('A parcel polygon must have at least three points');
      }
      const first = points[0];
      const last = points[points.length - 1];
      if (first[0] !== last[0] || first[1] !== last[1]) {
        points.push([...first]);
      }
      return points;
    });
    if (geoJsonCoords.length === 0) {
      throw new BadRequestException('Parcel coordinates are required');
    }

    const polygon = turf.polygon(geoJsonCoords);
    const areaSquareMeters = turf.area(polygon);
    const areaHectares = areaSquareMeters / 10000;

    const khmerHectares = Math.floor(areaSquareMeters / 10000);
    const remainingAfterHectares = areaSquareMeters % 10000;
    const khmerAa = Math.floor(remainingAfterHectares / 100);
    const khmerSangTeeAa = Math.floor(remainingAfterHectares / 400);

    const lineCoords = [...geoJsonCoords[0]];
    const perimeterMeters = turf.length(turf.lineString(lineCoords), { units: 'meters' });

    const center = turf.centroid(polygon);
    const [centerLon, centerLat] = center.geometry.coordinates;

    const parcel = this.parcelRepository.create({
      ...rest,
      userId,
      coordinates: geoJsonCoords,
      areaSquareMeters,
      areaHectares,
      areaKhmer: { hectares: khmerHectares, aa: khmerAa, sangTeeAa: khmerSangTeeAa },
      perimeterMeters,
      centerLatitude: centerLat,
      centerLongitude: centerLon,
    } as any);

    return this.parcelRepository.save(parcel);
  }

  async findAll(userId: string) {
    return this.parcelRepository.find({
      where: { userId, deletedAt: IsNull() },
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string, userId: string) {
    const parcel = await this.parcelRepository.findOne({
      where: { id, userId, deletedAt: IsNull() },
    });

    if (!parcel) throw new NotFoundException('Parcel not found');
    return parcel;
  }

  async update(id: string, userId: string, updateParcelDto: UpdateParcelDto) {
    const parcel = await this.findOne(id, userId);
    Object.assign(parcel, updateParcelDto);
    return this.parcelRepository.save(parcel);
  }

  async remove(id: string, userId: string) {
    const parcel = await this.findOne(id, userId);
    parcel.deletedAt = new Date();
    await this.parcelRepository.save(parcel);
    return { message: 'Parcel deleted successfully' };
  }

  async toggleFavorite(id: string, userId: string) {
    const parcel = await this.findOne(id, userId);
    parcel.isFavorite = !parcel.isFavorite;
    return this.parcelRepository.save(parcel);
  }
}
