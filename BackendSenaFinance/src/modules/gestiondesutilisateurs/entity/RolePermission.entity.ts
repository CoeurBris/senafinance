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
import { Permission } from "./permission.entity";
import { Role } from "./Role.entity";

@Entity()
@Unique(["roleId", "permissionId"])
export class RolePermission {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column()
    roleId!: number;

    @Column()
    permissionId!: number;

    @ManyToOne(() => Role, (role) => role.rolePermissions, { onDelete: "CASCADE" })
    @JoinColumn({ name: "roleId" })
    role!: Role;

    @ManyToOne(() => Permission, (permission) => permission.rolePermissions, { onDelete: "CASCADE" })
    @JoinColumn({ name: "permissionId" })
    permission!: Permission;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;

    @DeleteDateColumn()
    deletedAt!: Date;
}