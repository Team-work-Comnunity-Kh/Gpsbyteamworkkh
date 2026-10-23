import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('parcels')
export class Parcel {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  userId: string;

  @Column({ type: 'varchar', length: 200 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'jsonb' })
  coordinates: number[][][];

  @Column({ type: 'float', default: 0 })
  areaSquareMeters: number;

  @Column({ type: 'float', default: 0 })
  areaHectares: number;

  @Column({ type: 'jsonb', nullable: true })
  areaKhmer: Record<string, any>;

  @Column({ type: 'float', default: 0 })
  perimeterMeters: number;

  @Column({ type: 'float', nullable: true })
  centerLatitude: number;

  @Column({ type: 'float', nullable: true })
  centerLongitude: number;

  @Column({ type: 'varchar', length: 50, nullable: true })
  category: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata: Record<string, any>;

  @Column({ type: 'simple-array', nullable: true })
  photos: string[];

  @Column({ type: 'simple-array', nullable: true })
  tags: string[];

  @Column({ type: 'varchar', length: 7, default: '#0FA3A3' })
  color: string;

  @Column({ type: 'boolean', default: false })
  isFavorite: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  deletedAt: Date;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;
}
