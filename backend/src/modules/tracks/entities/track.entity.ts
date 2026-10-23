import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn, OneToMany,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { TrackPoint } from './track-point.entity';

@Entity('tracks')
export class Track {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  userId: string;

  @Column({ type: 'varchar', length: 200 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'timestamp' })
  startTime: Date;

  @Column({ type: 'timestamp', nullable: true })
  endTime: Date;

  @Column({ type: 'float', default: 0 })
  totalDistanceMeters: number;

  @Column({ type: 'int', default: 0 })
  totalDurationSeconds: number;

  @Column({ type: 'float', nullable: true })
  maxSpeed: number;

  @Column({ type: 'float', nullable: true })
  avgSpeed: number;

  @Column({ type: 'int', default: 0 })
  pointCount: number;

  @Column({ type: 'varchar', length: 7, default: '#0FA3A3' })
  color: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata: Record<string, any>;

  @Column({ type: 'boolean', default: false })
  isRecording: boolean;

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

  @OneToMany(() => TrackPoint, (point) => point.track)
  points: TrackPoint[];
}
