import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Category } from './category.entity';
import { User } from '../../gestiondesutilisateurs/entity/user.entity';

@Entity('budgets')
export class Budget {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ type: 'varchar', length: 255, nullable: true })
  name?: string;

  @Column({ type: 'int', nullable: true })
  userId?: number;

  @Column({ type: 'int', nullable: true })
  categoryId?: number;

  @Column('decimal', { precision: 12, scale: 2 })
  amountLimit!: number;

  @Column({ nullable: true, type: 'text' })
  description?: string;

  @Column({ type: 'date', nullable: true })
  startDate?: string;

  @Column({ type: 'date', nullable: true })
  endDate?: string;

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt?: Date;

  @ManyToOne(() => Category, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'categoryId' })
  category?: Category;

  @ManyToOne(() => User, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'userId' })
  user?: User;
}