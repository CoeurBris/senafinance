import express, { Request, Response } from "express";
import cookieParser from "cookie-parser";
import cors from "cors";
import "dotenv/config";
import path from "path";
import fs from "fs";

import { myDataSource } from "./configs/data-source";

// Routes
import { authentication } from "./modules/gestiondesutilisateurs/route/auth.route";
import { rolesRoutes } from "./modules/gestiondesutilisateurs/route/role.route";
import { permissionsRoutes } from "./modules/gestiondesutilisateurs/route/permission.route";
import { journalRoutes } from "./modules/gestiondesutilisateurs/route/journal.route";
import { userRolesRoutes } from "./modules/gestiondesutilisateurs/route/userrole.route";
import { userRoutes } from "./modules/gestiondesutilisateurs/route/user.route";

import { categoryRoutes } from "./modules/gestiondesdepenses/route/category.route";
import { expenseRoutes } from "./modules/gestiondesdepenses/route/expense.route";
import { notificationRoutes } from "./modules/gestiondesdepenses/route/notification.route";
import { budgetRoutes } from "./modules/gestiondesdepenses/route/budget.route";
import { objectifRoutes } from "./modules/gestiondesdepenses/route/objectif.route";
import { dashboardRoutes } from "./modules/gestiondesdepenses/route/dashboard.route";
import { transactionRoutes } from "./modules/gestiondesdepenses/route/transaction.route";

// =====================================================
// Initialisation de la base de données
// =====================================================

myDataSource
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

const app = express();

// =====================================================
// Middlewares généraux & CORS
// =====================================================

app.use(
    cors({
        origin: (origin, callback) => {
            // Autorise les requêtes sans origine (comme les apps mobiles/Postman)
            if (!origin) return callback(null, true);

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
            } else {
                callback(null, true); // Ou callback(new Error("CORS non autorisé")) en prod
            }
        },
        credentials: true,
        methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowedHeaders: ["Origin", "Content-Type", "Accept", "Authorization"],
    })
);
app.use(express.json({ limit: "5mb" }));
app.use(express.urlencoded({ limit: "5mb", extended: true }));
app.use(cookieParser());

// Rendre le dossier uploads accessible publiquement (pour que Flutter
//  puisse charger les images via une simple URL http)
app.use(
    '/uploads',
    express.static(
        path.join(__dirname, '../uploads')
    )
);

// =====================================================
// Routes
// =====================================================

authentication(app);
budgetRoutes(app);
rolesRoutes(app);
userRoutes(app);
permissionsRoutes(app);
journalRoutes(app);
userRolesRoutes(app);
categoryRoutes(app);
expenseRoutes(app);
notificationRoutes(app);
objectifRoutes(app);
dashboardRoutes(app);
transactionRoutes(app);

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
    const fullPath = path.join(__dirname, "..", dir);
    if (!fs.existsSync(fullPath)) {
        fs.mkdirSync(fullPath, { recursive: true });
        console.log(`Dossier créé : ${fullPath}`);
    }
});

// =====================================================
// Gestion des routes inexistantes - Erreur 404
// =====================================================

app.use((req: Request, res: Response) => {
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