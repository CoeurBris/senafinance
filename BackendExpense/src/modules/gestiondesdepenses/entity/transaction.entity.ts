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

export enum TransactionType {
  DEPENSE = 'Dépense',
  REVENU = 'Revenu',
}

export enum PaymentMethod {
  CARTE = 'Carte',
  ESPECES = 'Espèces',
}

@Entity('transactions')
export class Transaction {
  @PrimaryGeneratedColumn()
  id!: string;

  @Column({ nullable: true })
  userId?: string;

  @Column({ nullable: true })
  categoryId?: string;

  @Column()
  title!: string;

  @Column('decimal', { precision: 12, scale: 2 })
  amount!: number;

  @Column({
    type: 'enum',
    enum: TransactionType,
    default: TransactionType.DEPENSE,
  })
  type!: TransactionType;

  @Column({ type: 'date' })
  date!: string;

  @Column({
    type: 'enum',
    enum: PaymentMethod,
    nullable: true,
  })
  paymentMethod?: PaymentMethod;

  @Column({ nullable: true, type: 'text' })
  note?: string;

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt?: Date;

  // Relation unidirectionnelle : pas besoin de modifier Category.entity.ts
  // (pas de champ `transactions` requis côté Category).
  @ManyToOne(() => Category, {
    nullable: true,
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'categoryId' })
  category?: Category;
}