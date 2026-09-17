"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.Logout = exports.Refresh = exports.verifyAuth = exports.SendResetPasswordCode = exports.ResetPasswordUser = exports.LoginMobile = exports.Login = exports.Register = void 0;
const user_entity_1 = require("../entity/user.entity");
const journalConnexion_1 = require("../entity/journalConnexion");
const jsonwebtoken_1 = require("jsonwebtoken");
const bcryptjs = __importStar(require("bcryptjs"));
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const config_1 = require("../../../configs/config");
const class_validator_1 = require("class-validator");
const Register = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { nom, email, password, prenom, telephone } = req.body;
        if (!email || !password || !nom) {
            return (0, response_1.generateServerErrorCode)(res, 400, '', 'Le nom, l\'email et le mot de passe sont requis.');
        }
        const userRepository = data_source_1.myDataSource.getRepository(user_entity_1.User);
        const userExiste = yield userRepository.findOne({ where: { email } });
        if (userExiste) {
            return (0, response_1.generateServerErrorCode)(res, 400, '', 'Cet utilisateur existe déjà');
        }
        if (telephone) {
            const telephoneExiste = yield userRepository.findOne({ where: { telephone } });
            if (telephoneExiste) {
                return (0, response_1.generateServerErrorCode)(res, 400, '', 'Ce numéro de téléphone est déjà utilisé');
            }
        }
        const user = yield userRepository.save({
            nom,
            prenom: prenom || null,
            telephone: telephone || `N/A-${Date.now()}`,
            email,
            password: yield bcryptjs.hash(password, 12),
            typeCompte: 'utilisateur',
        });
        const { password: pwd } = user, data = __rest(user, ["password"]);
        return (0, response_1.success)(res, 201, data, "L'utilisateur a été enregistré avec succès");
    }
    catch (error) {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Erreur de validation');
        }
        if (error.code === "ER_DUP_ENTRY" || error.code === "23505") {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Cet utilisateur existe déjà');
        }
        return (0, response_1.generateServerErrorCode)(res, 500, '', "L'utilisateur n'a pas pu être enregistré. Réessayez plus tard.");
    }
});
exports.Register = Register;
const Login = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'errors', "L'email et le mot de passe sont requis.");
        }
        const user = yield data_source_1.myDataSource.getRepository(user_entity_1.User).findOne({
            where: { email }
        });
        if (!user || !user.password || !(yield bcryptjs.compare(password, user.password))) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'Invalid Credentials', "Les informations d'identification sont invalides");
        }
        const { password: pwd } = user, data = __rest(user, ["password"]);
        const accessToken = (0, jsonwebtoken_1.sign)({ userId: user.id, nom: user.nom, email: user.email }, config_1.config.jwt.accessToken, { expiresIn: '8h' });
        const refreshToken = (0, jsonwebtoken_1.sign)({ userId: user.id }, config_1.config.jwt.refreshToken, { expiresIn: '7d' });
        // Journal de connexion
        const journal = new journalConnexion_1.JournalConnexion();
        journal.entityId = user.id.toString();
        journal.userName = user.nom;
        journal.action = "Connexion";
        yield data_source_1.myDataSource.getRepository(journalConnexion_1.JournalConnexion).save(journal);
        return (0, response_1.success)(res, 200, { user: data, token: accessToken, refreshToken }, "L'authentification a réussi");
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "Réessayez dans quelques instants.");
    }
});
exports.Login = Login;
const LoginMobile = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    return (0, exports.Login)(req, res);
});
exports.LoginMobile = LoginMobile;
const ResetPasswordUser = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { newPassword, token } = req.body;
        if (!newPassword || !token) {
            return (0, response_1.generateServerErrorCode)(res, 400, '', 'Tous les champs obligatoires ne sont pas renseignés');
        }
        let decodedToken;
        try {
            decodedToken = (0, jsonwebtoken_1.verify)(token, config_1.config.jwt.resetPasswordToken);
        }
        catch (error) {
            return (0, response_1.generateServerErrorCode)(res, 401, 'token invalide', "L'utilisateur n'est pas autorisé.");
        }
        const userRepository = data_source_1.myDataSource.getRepository(user_entity_1.User);
        const userExiste = yield userRepository.findOne({ where: { email: decodedToken.username } });
        if (!userExiste) {
            return (0, response_1.generateServerErrorCode)(res, 400, '', "Ce compte n'existe pas");
        }
        userRepository.merge(userExiste, {
            password: yield bcryptjs.hash(newPassword, 12),
            firstConnectDate: new Date(),
        });
        yield userRepository.save(userExiste);
        const { password } = userExiste, userWithoutPassword = __rest(userExiste, ["password"]);
        return (0, response_1.success)(res, 200, userWithoutPassword, "Votre mot de passe a été modifié avec succès");
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, '', "Le mot de passe n'a pas pu être modifié.");
    }
});
exports.ResetPasswordUser = ResetPasswordUser;
const SendResetPasswordCode = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { email } = req.body;
        if (!email) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'errors', "L'email est requis.");
        }
        const user = yield data_source_1.myDataSource.getRepository(user_entity_1.User).findOne({ where: { email } });
        if (!user) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'Invalid Credentials', "Ce compte n'existe pas");
        }
        const resetPasswordToken = (0, jsonwebtoken_1.sign)({ username: user.email }, config_1.config.jwt.resetPasswordToken, { expiresIn: '15m' });
        const { password } = user, data = __rest(user, ["password"]);
        return (0, response_1.success)(res, 200, { user: data, resetPasswordToken }, "Le code de réinitialisation a été généré");
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "Réessayez dans quelques instants.");
    }
});
exports.SendResetPasswordCode = SendResetPasswordCode;
const verifyAuth = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const authHeader = req.headers.authorization;
        const api_token = req.body['api_token'] || (authHeader && authHeader.startsWith('Bearer ') ? authHeader.split(' ')[1] : null);
        if (!api_token) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'session', "Jeton manquant");
        }
        const payload = (0, jsonwebtoken_1.verify)(api_token, config_1.config.jwt.accessToken);
        if (!payload) {
            return res.status(401).send({ message: `Votre session a expiré, veuillez vous reconnecter` });
        }
        return res.status(200).send({ message: `Token valide` });
    }
    catch (err) {
        const message = err.name === 'TokenExpiredError'
            ? 'Votre session a expiré, veuillez vous reconnecter'
            : 'Le jeton est invalide';
        return (0, response_1.generateServerErrorCode)(res, 401, 'session', message);
    }
});
exports.verifyAuth = verifyAuth;
const Refresh = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b;
    try {
        const refreshToken = ((_a = req.cookies) === null || _a === void 0 ? void 0 : _a['refreshToken']) || ((_b = req.body) === null || _b === void 0 ? void 0 : _b.refreshToken);
        if (!refreshToken) {
            return res.status(401).send({ message: 'unauthenticated' });
        }
        const payload = (0, jsonwebtoken_1.verify)(refreshToken, config_1.config.jwt.refreshToken);
        if (!payload) {
            return res.status(401).send({ message: 'unauthenticated' });
        }
        const accessToken = (0, jsonwebtoken_1.sign)({ userId: payload.userId, nom: payload.nom }, config_1.config.jwt.accessToken, { expiresIn: '8h' });
        res.cookie('accessToken', accessToken, {
            httpOnly: true,
            maxAge: 24 * 60 * 60 * 1000,
        });
        return res.status(200).send({ accessToken, message: 'success' });
    }
    catch (e) {
        return res.status(401).send({ message: 'unauthenticated' });
    }
});
exports.Refresh = Refresh;
const Logout = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const journal = new journalConnexion_1.JournalConnexion();
        if (typeof req.query.userId === 'string') {
            journal.entityId = req.query.userId;
        }
        if (typeof req.query.userName === 'string') {
            journal.userName = req.query.userName;
        }
        journal.action = "Déconnexion";
        yield data_source_1.myDataSource.getRepository(journalConnexion_1.JournalConnexion).save(journal);
        res.cookie('accessToken', '', { maxAge: 0 });
        res.cookie('refreshToken', '', { maxAge: 0 });
        return res.status(200).json({ message: "Vous êtes déconnecté" });
    }
    catch (error) {
        return res.status(200).json({ message: "Vous êtes déconnecté" });
    }
});
exports.Logout = Logout;
