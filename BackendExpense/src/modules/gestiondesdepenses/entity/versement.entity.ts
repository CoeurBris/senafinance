import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Objectif } from './objectif.entity';

@Entity('versements')
export class Versement {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ type: 'int' })
  objectifId!: number;

  @Column('decimal', { precision: 12, scale: 2 })
  montant!: number;

  @CreateDateColumn()
  createdAt!: Date;

  @ManyToOne(() => Objectif, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'objectifId' })
  objectif?: Objectif;
}