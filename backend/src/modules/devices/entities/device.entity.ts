import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn, Index,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('devices')
export class Device {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  userId: string;

  @Column({ type: 'varchar', length: 100, unique: true })
  deviceId: string;

  @Column({ type: 'varchar', length: 100 })
  deviceName: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  deviceModel: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  osVersion: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  appVersion: string;

  @Column({ type: 'varchar', length: 20, default: 'active' })
  status: string;

  @Column({ type: 'float', nullable: true })
  lastLatitude: number;

  @Column({ type: 'float', nullable: true })
  lastLongitude: number;

  @Column({ type: 'float', nullable: true })
  lastAltitude: number;

  @Column({ type: 'float', nullable: true })
  lastSpeed: number;

  @Column({ type: 'float', nullable: true })
  lastHeading: number;

  @Column({ type: 'float', nullable: true })
  lastAccuracy: number;

  @Column({ type: 'timestamp', nullable: true })
  lastLocationTime: Date;

  @Column({ type: 'int', nullable: true })
  batteryLevel: number;

  @Column({ type: 'boolean', default: false })
  isCharging: boolean;

  @Column({ type: 'boolean', default: false })
  isTracking: boolean;

  @Column({ type: 'jsonb', nullable: true })
  gpsInfo: Record<string, any>;

  @Column({ type: 'jsonb', nullable: true })
  settings: Record<string, any>;

  @Column({ type: 'boolean', default: true })
  isOnline: boolean;

  @Column({ type: 'timestamp', nullable: true })
  lastSeenAt: Date;

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
