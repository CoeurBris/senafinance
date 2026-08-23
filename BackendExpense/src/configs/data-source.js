"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.myDataSource = void 0;
const typeorm_1 = require("typeorm");
const dotenv_1 = __importDefault(require("dotenv"));
// Entités Dépenses
const category_entity_1 = require("../modules/gestiondesdepenses/entity/category.entity");
const expense_entity_1 = require("../modules/gestiondesdepenses/entity/expense.entity");
const budget_entity_1 = require("../modules/gestiondesdepenses/entity/budget.entity");
const notification_entity_1 = require("../modules/gestiondesdepenses/entity/notification.entity");
// Entités Utilisateurs
const user_entity_1 = require("../modules/gestiondesutilisateurs/entity/user.entity");
const permission_entity_1 = require("../modules/gestiondesutilisateurs/entity/permission.entity");
const Role_entity_1 = require("../modules/gestiondesutilisateurs/entity/Role.entity");
const RolePermission_entity_1 = require("../modules/gestiondesutilisateurs/entity/RolePermission.entity");
const UserRole_entity_1 = require("../modules/gestiondesutilisateurs/entity/UserRole.entity"); // 👈 Ajout de l'import
const journalConnexion_1 = require("../modules/gestiondesutilisateurs/entity/journalConnexion");
dotenv_1.default.config();
// console.log("DB_PASSWORD lu:", process.env.DB_PASSWORD);
exports.myDataSource = new typeorm_1.DataSource({
    type: "postgres",
    host: process.env.DB_HOST || "localhost",
    port: parseInt(process.env.DB_PORT || "5432", 10),
    username: process.env.DB_USER || "postgres",
    password: process.env.DB_PASSWORD || "Admin123",
    database: process.env.DB_NAME || "expense_db",
    entities: [
        user_entity_1.User,
        Role_entity_1.Role,
        RolePermission_entity_1.RolePermission,
        UserRole_entity_1.UserRole, // 👈 Ajout indispensable ici
        journalConnexion_1.JournalConnexion,
        permission_entity_1.Permission,
        category_entity_1.Category,
        expense_entity_1.Expense,
        budget_entity_1.Budget,
        notification_entity_1.Notification
    ],
    migrations: ["src/migrations/*.ts"],
    migrationsTableName: "migrations",
    logging: true,
    synchronize: true,
});
