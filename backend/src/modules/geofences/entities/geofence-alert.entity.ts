import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, ManyToOne, JoinColumn,
} from 'typeorm';
import { Geofence } from './geofence.entity';
import { User } from '../../auth/entities/user.entity';

@Entity('geofence_alerts')
export class GeofenceAlert {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  userId: string;

  @Column({ type: 'uuid', nullable: true })
  geofenceId: string;

  @Column({ type: 'uuid', nullable: true })
  deviceId: string;

  @Column({ type: 'varchar', length: 50 })
  alertType: string;

  @Column({ type: 'varchar', length: 255 })
  title: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ type: 'float', nullable: true })
  latitude: number;

  @Column({ type: 'float', nullable: true })
  longitude: number;

  @Column({ type: 'jsonb', nullable: true })
  metadata: Record<string, any>;

  @Column({ type: 'boolean', default: false })
  isRead: boolean;

  @Column({ type: 'timestamp', nullable: true })
  readAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @ManyToOne(() => Geofence, (geofence) => geofence.alerts, { onDelete: 'CASCADE', nullable: true })
  @JoinColumn({ name: 'geofenceId' })
  geofence: Geofence;
}
