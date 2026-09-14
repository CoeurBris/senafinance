import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Expense } from './expense.entity';

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn()
  id!: string;

  @Column({ nullable: true })
  userId?: string;

  @Column()
  title!: string;

  @Column('text')
  body!: string;

  @Column({ nullable: true })
  type?: string;

  @Column({ default: false })
  isRead!: boolean;

  @Column({ nullable: true })
  relatedExpenseId?: string;

  @Column({ type: 'jsonb', nullable: true })
  data?: Record<string, any>;

  @CreateDateColumn()
  createdAt!: Date;

  @ManyToOne(() => Expense, (expense) => expense.notifications, {
    nullable: true,
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'relatedExpenseId' })
  relatedExpense?: Expense;
}