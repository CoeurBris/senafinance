import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../gestiondesutilisateurs/entity/user.entity';

@Entity('objectifs')
export class Objectif {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ type: 'int', nullable: true })
  userId?: number;

  @Column({ type: 'varchar', length: 255 })
  title!: string;

  @Column('decimal', { precision: 12, scale: 2 })
  targetAmount!: number;

  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  currentAmount!: number;

  @Column({ type: 'timestamp', nullable: true })
  targetDate?: Date;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt?: Date;

  @ManyToOne(() => User, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user?: User;
}