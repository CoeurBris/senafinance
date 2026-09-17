"use strict";
// import * as express from 'express';
// import {
//   createUser,
//   deleteUser,
//   getAllAllUsers,
//   getAllUsers,
//   getUser,
//   updatePassword,
//   updateUser,
//   ChangerPasswordAdmin,
//   updatePhoto
// } from '../controller/user.controller';
// import { checkPermission, isAuthenticated } from '../../../middlewares/auth.middleware';
// import { upload } from '../../../configs/multer';
Object.defineProperty(exports, "__esModule", { value: true });
exports.userRoutes = void 0;
const user_controller_1 = require("../controller/user.controller");
const auth_middleware_1 = require("../../../middlewares/auth.middleware");
const multer_1 = require("../../../configs/multer");
const userRoutes = (app) => {
    // Récupérer tous les utilisateurs avec pagination
    app.get('/api/users', auth_middleware_1.isAuthenticated, (0, auth_middleware_1.checkPermission)('ListUser'), user_controller_1.getAllUsers);
    // Récupérer tous les utilisateurs sans pagination
    app.get('/api/all/users', user_controller_1.getAllAllUsers);
    // Récupérer un utilisateur
    app.get('/api/users/:id', user_controller_1.getUser);
    // Créer un utilisateur
    app.post('/api/users', user_controller_1.createUser);
    // Modifier un utilisateur
    app.put('/api/users/:id', user_controller_1.updateUser);
    // Supprimer un utilisateur
    app.delete('/api/users/:id', user_controller_1.deleteUser);
    // Modifier son mot de passe
    app.post('/api/users/password/:id', user_controller_1.updatePassword);
    // Admin change le mot de passe
    app.put('/api/users/password/admin/:id', user_controller_1.ChangerPasswordAdmin);
    // Modifier la photo de profil
    app.post('/api/users/photo', auth_middleware_1.isAuthenticated, multer_1.upload.single('photo'), user_controller_1.updatePhoto);
};
exports.userRoutes = userRoutes;
