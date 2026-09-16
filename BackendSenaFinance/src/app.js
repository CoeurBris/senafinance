"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cookie_parser_1 = __importDefault(require("cookie-parser"));
const cors_1 = __importDefault(require("cors"));
require("dotenv/config");
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const data_source_1 = require("./configs/data-source");
// Routes
const auth_route_1 = require("./modules/gestiondesutilisateurs/route/auth.route");
const role_route_1 = require("./modules/gestiondesutilisateurs/route/role.route");
const permission_route_1 = require("./modules/gestiondesutilisateurs/route/permission.route");
const journal_route_1 = require("./modules/gestiondesutilisateurs/route/journal.route");
const userrole_route_1 = require("./modules/gestiondesutilisateurs/route/userrole.route");
const user_route_1 = require("./modules/gestiondesutilisateurs/route/user.route");
const category_route_1 = require("./modules/gestiondesdepenses/route/category.route");
const expense_route_1 = require("./modules/gestiondesdepenses/route/expense.route");
const notification_route_1 = require("./modules/gestiondesdepenses/route/notification.route");
const budget_route_1 = require("./modules/gestiondesdepenses/route/budget.route");
const objectif_route_1 = require("./modules/gestiondesdepenses/route/objectif.route");
const dashboard_route_1 = require("./modules/gestiondesdepenses/route/dashboard.route");
const transaction_route_1 = require("./modules/gestiondesdepenses/route/transaction.route");
// =====================================================
// Initialisation de la base de données
// =====================================================
data_source_1.myDataSource
    .initialize()
    .then(() => {
    console.log("Base de données connectée avec succès.");
})
    .catch((error) => {
    console.error("Erreur lors de l'initialisation de la base de données :", error);
});
// =====================================================
// Création de l'application Express
// =====================================================
const app = (0, express_1.default)();
// =====================================================
// Middlewares généraux & CORS
// =====================================================
app.use((0, cors_1.default)({
    origin: (origin, callback) => {
        // Autorise les requêtes sans origine (comme les apps mobiles/Postman)
        if (!origin)
            return callback(null, true);
        const allowedOrigins = [
            "http://localhost:3008",
            "http://192.168.8.59:3003",
            "http://localhost",
            "http://localhost:3005",
            "http://192.168.8.60:3005",
        ];
        // Accepte toutes les origines localhost avec n'importe quel port (ex: Flutter Web)
        if (allowedOrigins.includes(origin) || /^http:\/\/localhost:\d+$/.test(origin)) {
            callback(null, true);
        }
        else {
            callback(null, true); // Ou callback(new Error("CORS non autorisé")) en prod
        }
    },
    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Origin", "Content-Type", "Accept", "Authorization"],
}));
app.use(express_1.default.json({ limit: "5mb" }));
app.use(express_1.default.urlencoded({ limit: "5mb", extended: true }));
app.use((0, cookie_parser_1.default)());
// Rendre le dossier uploads accessible publiquement (pour que Flutter
//  puisse charger les images via une simple URL http)
app.use('/uploads', express_1.default.static(path_1.default.join(__dirname, '../uploads')));
// =====================================================
// Routes
// =====================================================
(0, auth_route_1.authentication)(app);
(0, budget_route_1.budgetRoutes)(app);
(0, role_route_1.rolesRoutes)(app);
(0, user_route_1.userRoutes)(app);
(0, permission_route_1.permissionsRoutes)(app);
(0, journal_route_1.journalRoutes)(app);
(0, userrole_route_1.userRolesRoutes)(app);
(0, category_route_1.categoryRoutes)(app);
(0, expense_route_1.expenseRoutes)(app);
(0, notification_route_1.notificationRoutes)(app);
(0, objectif_route_1.objectifRoutes)(app);
(0, dashboard_route_1.dashboardRoutes)(app);
(0, transaction_route_1.transactionRoutes)(app);
// =====================================================
// Création des dossiers nécessaires
// =====================================================
const requiredDirs = [
    "uploads/Personnels",
    "uploads/Demandes",
    "uploads/Justificatifs",
    "uploads/avatars",
];
requiredDirs.forEach((dir) => {
    const fullPath = path_1.default.join(__dirname, "..", dir);
    if (!fs_1.default.existsSync(fullPath)) {
        fs_1.default.mkdirSync(fullPath, { recursive: true });
        console.log(`Dossier créé : ${fullPath}`);
    }
});
// =====================================================
// Gestion des routes inexistantes - Erreur 404
// =====================================================
app.use((req, res) => {
    return res.status(404).json({
        message: "Le projet a bien démarré mais impossible de trouver la ressource demandée ! Vous pouvez essayer une autre URL.",
    });
});
// =====================================================
// Démarrage du serveur
// =====================================================
const PORT = Number(process.env.PORT_SERVER || process.env.PORT || 3000);
app.listen(PORT, "0.0.0.0", () => {
    console.log(`Serveur démarré sur le port ${PORT}`);
});
// const PORT = process.env.PORT_SERVER || process.env.PORT || 3000;
// app.listen(PORT, () => {
//     console.log(`Serveur démarré sur le port ${PORT}`);
// });
