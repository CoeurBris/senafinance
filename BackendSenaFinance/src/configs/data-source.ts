import { DataSource } from "typeorm";
import dotenv from "dotenv";

// Entités Dépenses
import { Category } from "../modules/gestiondesdepenses/entity/category.entity";
import { Expense } from "../modules/gestiondesdepenses/entity/expense.entity";
import { Budget } from "../modules/gestiondesdepenses/entity/budget.entity";
import { Notification as NotificationEntity } from "../modules/gestiondesdepenses/entity/notification.entity";
import { Transaction } from "../modules/gestiondesdepenses/entity/transaction.entity";
import { Objectif } from "../modules/gestiondesdepenses/entity/objectif.entity";
import { Versement } from "../modules/gestiondesdepenses/entity/versement.entity";

// Entités Utilisateurs
import { User } from "../modules/gestiondesutilisateurs/entity/user.entity";
import { Permission } from "../modules/gestiondesutilisateurs/entity/permission.entity";
import { Role } from "../modules/gestiondesutilisateurs/entity/Role.entity";
import { RolePermission } from "../modules/gestiondesutilisateurs/entity/RolePermission.entity";
import { UserRole } from "../modules/gestiondesutilisateurs/entity/UserRole.entity";
import { JournalConnexion } from "../modules/gestiondesutilisateurs/entity/journalConnexion";

dotenv.config();

const isProduction = process.env.NODE_ENV === "production";

export const myDataSource = new DataSource({
  type: "postgres",
  host: process.env.DB_HOST || "localhost",
  port: parseInt(process.env.DB_PORT || "5432", 10),
  username: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD, // plus de fallback en clair
  database: process.env.DB_NAME || "expense_db",
  ssl: isProduction ? { rejectUnauthorized: false } : false,
  entities: [
    User,
    Role,
    RolePermission,
    UserRole,
    JournalConnexion,
    Permission,
    Category,
    Expense,
    Budget,
    NotificationEntity,
    Objectif,
    Versement,
    Transaction,
  ],
  migrations: [
    isProduction ? "dist/migrations/*.js" : "src/migrations/*.ts",
  ],
  migrationsTableName: "migrations",
  logging: !isProduction, // désactivez les logs SQL verbeux en prod
  synchronize: false,
});