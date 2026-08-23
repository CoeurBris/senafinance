import { DataSource } from "typeorm";
import dotenv from "dotenv";

// Entités Dépenses
import { Category } from "../modules/gestiondesdepenses/entity/category.entity";
import { Expense } from "../modules/gestiondesdepenses/entity/expense.entity";
import { Budget } from "../modules/gestiondesdepenses/entity/budget.entity";
import { Notification as NotificationEntity } from "../modules/gestiondesdepenses/entity/notification.entity";

// Entités Utilisateurs
import { User } from "../modules/gestiondesutilisateurs/entity/user.entity";
import { Permission } from "../modules/gestiondesutilisateurs/entity/permission.entity";
import { Role } from "../modules/gestiondesutilisateurs/entity/Role.entity";
import { RolePermission } from "../modules/gestiondesutilisateurs/entity/RolePermission.entity";
import { UserRole } from "../modules/gestiondesutilisateurs/entity/UserRole.entity"; // 👈 Ajout de l'import
import { JournalConnexion } from "../modules/gestiondesutilisateurs/entity/journalConnexion";

dotenv.config();

// console.log("DB_PASSWORD lu:", process.env.DB_PASSWORD);

export const myDataSource = new DataSource({
  type: "postgres",
  host: process.env.DB_HOST || "localhost",
  port: parseInt(process.env.DB_PORT || "5432", 10),
  username: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "Admin123",
  database: process.env.DB_NAME || "expense_db",
  entities: [
    User, 
    Role, 
    RolePermission, 
    UserRole, // 👈 Ajout indispensable ici
    JournalConnexion, 
    Permission, 
    Category, 
    Expense, 
    Budget, 
    NotificationEntity
  ],
  migrations: ["src/migrations/*.ts"],
  migrationsTableName: "migrations",
  logging: true,
  synchronize: true,
});