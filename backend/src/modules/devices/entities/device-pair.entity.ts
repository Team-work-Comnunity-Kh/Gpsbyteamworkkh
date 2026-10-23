import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn,
} from 'typeorm';
import { Device } from './device.entity';
import { User } from '../../auth/entities/user.entity';

@Entity('device_pairs')
export class DevicePair {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  sourceDeviceId: string;

  @Column({ type: 'uuid' })
  targetDeviceId: string;

  @Column({ type: 'uuid' })
  sourceUserId: string;

  @Column({ type: 'uuid' })
  targetUserId: string;

  @Column({ type: 'varchar', length: 6, unique: true })
  pairingCode: string;

  @Column({ type: 'varchar', length: 20, default: 'pending' })
  status: string;

  @Column({ type: 'jsonb', default: {} })
  permissions: Record<string, any>;

  @Column({ type: 'varchar', length: 100, nullable: true })
  nickname: string;

  @Column({ type: 'timestamp', nullable: true })
  expiresAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  acceptedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  revokedAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => Device, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'sourceDeviceId' })
  sourceDevice: Device;

  @ManyToOne(() => Device, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'targetDeviceId' })
  targetDevice: Device;
}
