import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { Category } from './category.entity';
import { Notification } from './notification.entity';

@Entity('expenses')
export class Expense {
  @PrimaryGeneratedColumn()
  id!: string;

  @Column({ nullable: true })
  userId?: string;

  @Column({ nullable: true })
  categoryId?: string;

  @Column('decimal', { precision: 12, scale: 2 })
  amount!: number;

  @Column({ type: 'date' })
  date!: string;

  @Column({ nullable: true })
  title?: string;

  @Column({ nullable: true, type: 'text' })
  description?: string;

  @Column({ nullable: true })
  receiptUrl?: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata?: Record<string, any>;

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt?: Date;

  @ManyToOne(() => Category, (category) => category.expenses, {
    nullable: true,
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'categoryId' })
  category?: Category;

  @OneToMany(() => Notification, (notification) => notification.relatedExpense)
  notifications?: Notification[];
}