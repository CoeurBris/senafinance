import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    DeleteDateColumn,
    CreateDateColumn,
    UpdateDateColumn,
    OneToMany,
} from "typeorm";
import { IsNotEmpty } from "class-validator";
import { RolePermission } from "./RolePermission.entity";
import { UserRole } from "./UserRole.entity";

@Entity()
export class Role {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column({ nullable: false, unique: true })
    @IsNotEmpty({ message: 'Le nom est une propriété requise.' })
    nom!: string;

    @Column({ default: false })
    isChecked!: boolean;

    @Column({ nullable: false, unique: true })
    @IsNotEmpty({ message: 'La description est une propriété requise.' })
    description!: string;

    @Column({ type: 'simple-array', nullable: false })
    privileges!: string[];

    @OneToMany(() => RolePermission, (rolePermission) => rolePermission.role, { cascade: true })
    rolePermissions!: RolePermission[];

    @OneToMany(() => UserRole, (userRole) => userRole.role)
    userRoles!: UserRole[]; // Correction ici : ajout de []

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;

    @DeleteDateColumn()
    deletedAt!: Date;
}