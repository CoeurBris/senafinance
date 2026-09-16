import {
    Entity,
    Column,
    PrimaryGeneratedColumn,
    CreateDateColumn,
    UpdateDateColumn,
    DeleteDateColumn,
    BeforeInsert,
    BeforeUpdate,
} from "typeorm";
import * as bcryptjs from "bcryptjs";
import { IsEmail, IsNotEmpty, IsOptional } from "class-validator";

@Entity()
export class User {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column()
    @IsNotEmpty({ message: 'Le nom est une propriété requise.' })
    nom!: string;

    @Column()
    @IsNotEmpty({ message: 'Le prénom est une propriété requise.' })
    prenom!: string;

    @Column({ unique: true })
    @IsNotEmpty({ message: 'Le téléphone est une propriété requise.' })
    telephone!: string;

    @Column({ nullable: true })
    @IsOptional()
    sexe?: string;

    @Column({ nullable: true, unique: true })
    @IsOptional()
    @IsEmail({}, { message: "L'adresse email est invalide." })
    email?: string;

    // @Column({ default: true })
    // etat!: boolean;

    @Column({ nullable: true })
    photoUrl?: string;

    @Column({ nullable: true })
    fcmToken?: string;

    @Column({ nullable: true })
    firstConnectDate?: Date;

    @Column({ nullable: true })
    @IsOptional()
    password?: string;

    // @Column({ default: 'utilisateur' })
    // typeCompte!: string;

    // @Column({ nullable: true })
    // nomPointVente?: string;

    // @Column({ nullable: true })
    // adressePointVente?: string;

    // @Column({ nullable: true })
    // numeroAgrement?: string;

    // @Column({ nullable: true })
    // marqueId?: string;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;

    @DeleteDateColumn()
    deletedAt!: Date;

    @BeforeInsert()
    @BeforeUpdate()
    async hashPassword() {
        if (this.password && !this.password.startsWith('$2a$') && !this.password.startsWith('$2b$')) {
            this.password = await bcryptjs.hash(this.password, 12);
        }
    }
}