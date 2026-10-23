import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, ManyToOne, JoinColumn, Index,
} from 'typeorm';
import { Track } from './track.entity';

@Entity('track_points')
@Index(['trackId', 'timestamp'])
export class TrackPoint {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  trackId: string;

  @Column({ type: 'float' })
  latitude: number;

  @Column({ type: 'float' })
  longitude: number;

  @Column({ type: 'float', nullable: true })
  altitude: number;

  @Column({ type: 'float', nullable: true })
  speed: number;

  @Column({ type: 'float', nullable: true })
  heading: number;

  @Column({ type: 'float', nullable: true })
  accuracy: number;

  @Column({ type: 'timestamp' })
  timestamp: Date;

  @Column({ type: 'int', nullable: true })
  sequence: number;

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => Track, (track) => track.points, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'trackId' })
  track: Track;
}
