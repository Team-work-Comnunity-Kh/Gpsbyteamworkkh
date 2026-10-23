import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn, OneToMany,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { GeofenceAlert } from './geofence-alert.entity';

@Entity('geofences')
export class Geofence {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  userId: string;

  @Column({ type: 'varchar', length: 200 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'varchar', length: 20, default: 'circle' })
  type: string;

  @Column({ type: 'float', nullable: true })
  centerLatitude: number;

  @Column({ type: 'float', nullable: true })
  centerLongitude: number;

  @Column({ type: 'float', nullable: true })
  radiusMeters: number;

  @Column({ type: 'jsonb', nullable: true })
  coordinates: number[][][];

  @Column({ type: 'boolean', default: true })
  alertOnEnter: boolean;

  @Column({ type: 'boolean', default: true })
  alertOnExit: boolean;

  @Column({ type: 'boolean', default: true })
  isActive: boolean;

  @Column({ type: 'varchar', length: 7, default: '#F97316' })
  color: string;

  @Column({ type: 'jsonb', nullable: true })
  settings: Record<string, any>;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  deletedAt: Date;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @OneToMany(() => GeofenceAlert, (alert) => alert.geofence)
  alerts: GeofenceAlert[];
}
