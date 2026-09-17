"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkPermission = exports.isAuthenticatedOne = exports.isAuthenticated = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const data_source_1 = require("../configs/data-source");
const config_1 = require("../configs/config");
const response_1 = require("../configs/response");
const permission_entity_1 = require("../modules/gestiondesutilisateurs/entity/permission.entity");
/**
 * Extraction et validation sécurisée du jeton Bearer
 */
const extractBearerToken = (req) => {
    const authHeader = req.headers.authorization || req.header('Authorization');
    if (!authHeader)
        return null;
    const parts = authHeader.split(' ');
    if (parts.length === 2 && parts[0] === 'Bearer') {
        return parts[1];
    }
    return null;
};
/**
 * Middleware d'authentification principal
 */
const isAuthenticated = (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    const token = extractBearerToken(req);
    if (!token) {
        return (0, response_1.generateServerErrorCode)(res, 401, 'token non renseigné', "Vous n'avez pas fourni de jeton d'authentification dans l'en-tête.");
    }
    jsonwebtoken_1.default.verify(token, config_1.config.jwt.accessToken, (err, decodedToken) => {
        if (err) {
            if (err.name === 'TokenExpiredError') {
                return (0, response_1.generateServerErrorCode)(res, 401, 'token expiré', 'Votre session a expiré, veuillez vous reconnecter.');
            }
            return (0, response_1.generateServerErrorCode)(res, 403, "Le jeton n'est pas valide", "Échec d'authentification.");
        }
        req.user = Object.assign({ id: decodedToken.userId }, decodedToken);
        next();
    });
});
exports.isAuthenticated = isAuthenticated;
/**
 * Middleware d'authentification étendu (Gestion du point de vente)
 */
const isAuthenticatedOne = (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    const token = extractBearerToken(req);
    if (!token) {
        return (0, response_1.generateServerErrorCode)(res, 401, 'token non renseigné', "Vous n'avez pas fourni de jeton d'authentification.");
    }
    jsonwebtoken_1.default.verify(token, config_1.config.jwt.accessToken, (err, decodedToken) => {
        if (err) {
            if (err.name === 'TokenExpiredError') {
                return (0, response_1.generateServerErrorCode)(res, 401, 'token expiré', 'Votre session a expiré, veuillez vous reconnecter.');
            }
            return (0, response_1.generateServerErrorCode)(res, 401, 'token invalide', "L'utilisateur n'est pas autorisé à accéder à cette ressource.");
        }
        const userId = decodedToken.userId;
        req.user = Object.assign({ id: userId }, decodedToken);
        if (req.body) {
            req.body.userCreation = userId;
        }
        // Gestion du point de vente par défaut et de ses permissions
        const pointventesArray = decodedToken.pointventes
            ? decodedToken.pointventes.split(',')
            : [];
        const pointventeParDefaut = (decodedToken === null || decodedToken === void 0 ? void 0 : decodedToken.pointvente) || '';
        if (req.method === 'GET') {
            if (!req.query.pointvente || req.query.pointvente === '') {
                req.query.pointvente = pointventeParDefaut;
            }
        }
        else {
            if (!req.body.pointvente || req.body.pointvente === '') {
                req.body.pointvente = pointventeParDefaut;
            }
        }
        const currentPv = req.method === 'GET' ? req.query.pointvente : req.body.pointvente;
        if (pointventesArray.length > 0 && currentPv) {
            if (!pointventesArray.includes(currentPv.toString())) {
                return (0, response_1.generateServerErrorCode)(res, 403, 'Accès refusé', "L'utilisateur n'est pas autorisé à accéder à ce point de vente.");
            }
        }
        next();
    });
});
exports.isAuthenticatedOne = isAuthenticatedOne;
/**
 * Middleware de vérification des privilèges
 */
const checkPermission = (resource) => {
    return (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
        var _a;
        try {
            const userId = ((_a = req.user) === null || _a === void 0 ? void 0 : _a.id) || req.user;
            if (!userId) {
                return (0, response_1.generateServerErrorCode)(res, 401, "Non authentifié", "Vous devez être connecté pour accéder à cette fonctionnalité.");
            }
            const permissions = yield data_source_1.myDataSource
                .getRepository(permission_entity_1.Permission)
                .createQueryBuilder('permission')
                .leftJoin('permission.rolePermissions', 'rolePermission')
                .leftJoin('rolePermission.role', 'role')
                .leftJoin('role.userRoles', 'userRoles')
                .leftJoin('userRoles.user', 'user')
                .where('user.id = :ident', { ident: userId })
                .andWhere('permission.nom = :resou', { resou: resource })
                .getMany();
            if (permissions.length > 0) {
                return next();
            }
            return (0, response_1.generateServerErrorCode)(res, 403, "Privilège insuffisant", "Vous n'avez pas les droits nécessaires pour effectuer cette action.");
        }
        catch (error) {
            console.error('[checkPermission] Erreur SQL / Serveur:', error);
            return (0, response_1.generateServerErrorCode)(res, 500, "Erreur serveur", "Erreur lors de la vérification des droits d'accès.");
        }
    });
};
exports.checkPermission = checkPermission;
