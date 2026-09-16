import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    DeleteDateColumn,
    CreateDateColumn,
    UpdateDateColumn,
    ManyToOne,
    JoinColumn,
    Unique,
} from "typeorm";
import { Role } from "./Role.entity";
import { User } from "./user.entity";

@Entity()
@Unique(["userId", "roleId"])
export class UserRole {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column({ type: "timestamp", default: () => "CURRENT_TIMESTAMP" })
    dateAffectation!: Date;

    @Column()
    userId!: number;

    @Column()
    roleId!: number;

    @ManyToOne(() => Role, (role) => role.userRoles, { onDelete: "CASCADE" })
    @JoinColumn({ name: "roleId" })
    role!: Role;

    @ManyToOne(() => User, { onDelete: "CASCADE" })
    @JoinColumn({ name: "userId" })
    user!: User;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;

    @DeleteDateColumn()
    deletedAt!: Date;
}