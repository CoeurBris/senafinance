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
exports.updatePhoto = exports.deleteUser = exports.ChangerPasswordAdmin = exports.updatePassword = exports.updateUser = exports.getUser = exports.getAllAllUsers = exports.getAllUsers = exports.createUser = void 0;
const user_entity_1 = require("../entity/user.entity");
const bcryptjs = __importStar(require("bcryptjs"));
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const class_validator_1 = require("class-validator");
const paginationAndRechercheInit_1 = require("../../../configs/paginationAndRechercheInit");
const typeorm_1 = require("typeorm");
const UserRole_entity_1 = require("../entity/UserRole.entity");
const createUser = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const _a = req.body, { password, roles } = _a, userDataBody = __rest(_a, ["password", "roles"]);
        if (userDataBody.telephone) {
            userDataBody.telephone = userDataBody.telephone.replace(/\s/g, '');
        }
        // Hachage du mot de passe s'il est fourni dans la requête
        const hashedPassword = password ? yield bcryptjs.hash(password, 12) : undefined;
        const userRepository = data_source_1.myDataSource.getRepository(user_entity_1.User);
        const userData = userRepository.create(Object.assign(Object.assign({}, userDataBody), (hashedPassword && { password: hashedPassword })));
        const errors = yield (0, class_validator_1.validate)(userData);
        if (errors.length > 0) {
            return (0, response_1.generateServerErrorCode)(res, 400, errors, (0, response_1.validateMessage)(errors));
        }
        yield data_source_1.myDataSource.manager.transaction((transactionalEntityManager) => __awaiter(void 0, void 0, void 0, function* () {
            const userSaved = yield transactionalEntityManager.getRepository(user_entity_1.User).save(userData);
            // Extraction explicite de l'objet utilisateur (même si un tableau est retourné)
            const user = Array.isArray(userSaved) ? userSaved[0] : userSaved;
            if (roles) {
                const userRole = new UserRole_entity_1.UserRole();
                userRole.userId = user.id;
                userRole.roleId = roles;
                userRole.dateAffectation = new Date();
                yield transactionalEntityManager.getRepository(UserRole_entity_1.UserRole).save(userRole);
            }
            // Extraction de password depuis l'instance 'user' (et non 'userData' ou 'userSaved')
            const { password: pwd } = user, userWithoutPassword = __rest(user, ["password"]);
            return (0, response_1.success)(res, 201, userWithoutPassword, `L'utilisateur a bien été créé.`);
        }));
    }
    catch (error) {
        const message = error.code === "ER_DUP_ENTRY" || error.code === "23505"
            ? "Cet utilisateur existe déjà (email ou numéro de téléphone en doublon)."
            : "L'utilisateur n'a pas pu être ajouté.";
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    }
});
exports.createUser = createUser;
const getAllUsers = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { limit, searchTerm, startIndex, searchQueries } = (0, paginationAndRechercheInit_1.paginationAndRechercheInit)(req, user_entity_1.User);
    try {
        const [data, totalElements] = yield data_source_1.myDataSource.getRepository(user_entity_1.User)
            .createQueryBuilder('user')
            .where("user.deletedAt IS NULL")
            .andWhere(searchQueries.length > 0 ? new typeorm_1.Brackets(qb => {
            qb.where(searchQueries.join(' OR '), { keyword: `%${searchTerm}%` });
        }) : '1=1')
            .orderBy('user.createdAt', 'DESC')
            .skip(startIndex)
            .take(limit)
            .getManyAndCount();
        const sanitizedData = data.map((_a) => {
            var { password } = _a, user = __rest(_a, ["password"]);
            return user;
        });
        const totalPages = Math.ceil(totalElements / limit) || 1;
        return (0, response_1.success)(res, 200, { data: sanitizedData, totalPages, totalElements, limit }, 'La liste des utilisateurs a bien été récupérée.');
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, `La liste des utilisateurs n'a pas pu être récupérée.`);
    }
});
exports.getAllUsers = getAllUsers;
const getAllAllUsers = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const data = yield data_source_1.myDataSource.getRepository(user_entity_1.User)
            .createQueryBuilder('user')
            .where("user.deletedAt IS NULL")
            .orderBy('user.createdAt', 'DESC')
            .getMany();
        const sanitizedData = data.map((_a) => {
            var { password } = _a, user = __rest(_a, ["password"]);
            return user;
        });
        return (0, response_1.success)(res, 200, sanitizedData, 'La liste de tous les utilisateurs a bien été récupérée.');
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, `La liste des utilisateurs n'a pas pu être récupérée.`);
    }
});
exports.getAllAllUsers = getAllAllUsers;
const getUser = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const userId = parseInt(req.params.id, 10);
        if (isNaN(userId)) {
            return (0, response_1.generateServerErrorCode)(res, 400, "ID invalide", "L'identifiant fourni est invalide.");
        }
        const user = yield data_source_1.myDataSource.getRepository(user_entity_1.User).findOne({
            where: { id: userId }
        });
        if (!user) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'id n'existe pas", `L'utilisateur demandé n'existe pas.`);
        }
        const { password } = user, userWithoutPassword = __rest(user, ["password"]);
        return (0, response_1.success)(res, 200, userWithoutPassword, "L'utilisateur a bien été trouvé.");
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, `L'utilisateur n'a pas pu être récupéré.`);
    }
});
exports.getUser = getUser;
const updateUser = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const userId = parseInt(req.params.id, 10);
        if (isNaN(userId)) {
            return (0, response_1.generateServerErrorCode)(res, 400, "ID invalide", "L'identifiant fourni est invalide.");
        }
        const userRepository = data_source_1.myDataSource.getRepository(user_entity_1.User);
        let user = yield userRepository.findOne({ where: { id: userId } });
        if (!user) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'id n'existe pas", "L'utilisateur demandé n'existe pas.");
        }
        const _a = req.body, { password } = _a, updateData = __rest(_a, ["password"]);
        userRepository.merge(user, updateData);
        const errors = yield (0, class_validator_1.validate)(user);
        if (errors.length > 0) {
            return (0, response_1.generateServerErrorCode)(res, 400, errors, (0, response_1.validateMessage)(errors));
        }
        const updatedUser = yield userRepository.save(user);
        const { password: pwd } = updatedUser, userWithoutPassword = __rest(updatedUser, ["password"]);
        return (0, response_1.success)(res, 200, userWithoutPassword, `L'utilisateur ${updatedUser.nom || ''} a bien été modifié.`);
    }
    catch (error) {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Erreur de validation.');
        }
        if (error.code === "ER_DUP_ENTRY" || error.code === "23505") {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Cet utilisateur existe déjà.');
        }
        return (0, response_1.generateServerErrorCode)(res, 500, error, `L'utilisateur n'a pas pu être modifié.`);
    }
});
exports.updateUser = updateUser;
const updatePassword = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const userId = parseInt(req.params.id, 10);
        const { password, newPassword } = req.body;
        if (!password || !newPassword) {
            return (0, response_1.generateServerErrorCode)(res, 400, '', "L'ancien et le nouveau mot de passe sont requis.");
        }
        const userRepository = data_source_1.myDataSource.getRepository(user_entity_1.User);
        const utilisateur = yield userRepository.findOne({ where: { id: userId } });
        if (!utilisateur) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'id n'existe pas", "L'utilisateur demandé n'existe pas.");
        }
        if (!utilisateur.password) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'Invalid Credentials', "Aucun mot de passe n'est configuré pour ce compte.");
        }
        const isMatch = yield bcryptjs.compare(password, utilisateur.password);
        if (!isMatch) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'Invalid Credentials', "L'ancien mot de passe est incorrect.");
        }
        const hashedNewPassword = yield bcryptjs.hash(newPassword, 12);
        yield userRepository.update(userId, { password: hashedNewPassword });
        return (0, response_1.success)(res, 200, null, `La modification du mot de passe s'est bien passée.`);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, `Le mot de passe n'a pas pu être modifié.`);
    }
});
exports.updatePassword = updatePassword;
const ChangerPasswordAdmin = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const userId = parseInt(req.params.id, 10);
        const { newPassword } = req.body;
        if (!newPassword) {
            return (0, response_1.generateServerErrorCode)(res, 400, '', "Le nouveau mot de passe est requis.");
        }
        const userRepository = data_source_1.myDataSource.getRepository(user_entity_1.User);
        const user = yield userRepository.findOne({ where: { id: userId } });
        if (!user) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'id n'existe pas", "L'utilisateur demandé n'existe pas.");
        }
        const hashedNewPassword = yield bcryptjs.hash(newPassword, 12);
        yield userRepository.update(userId, { password: hashedNewPassword });
        return (0, response_1.success)(res, 200, null, `La réinitialisation du mot de passe par l'administrateur s'est bien passée.`);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, `Le mot de passe n'a pas pu être modifié.`);
    }
});
exports.ChangerPasswordAdmin = ChangerPasswordAdmin;
const deleteUser = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const userId = parseInt(req.params.id, 10);
        if (isNaN(userId)) {
            return (0, response_1.generateServerErrorCode)(res, 400, "ID invalide", "L'identifiant fourni est invalide.");
        }
        const userRepository = data_source_1.myDataSource.getRepository(user_entity_1.User);
        const user = yield userRepository.findOneBy({ id: userId });
        if (!user) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'id n'existe pas", `L'utilisateur demandé n'existe pas.`);
        }
        yield userRepository.softRemove(user);
        const { password } = user, userWithoutPassword = __rest(user, ["password"]);
        return (0, response_1.success)(res, 200, userWithoutPassword, `L'utilisateur n°${user.id} a bien été supprimé.`);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, `L'utilisateur n'a pas pu être supprimé.`);
    }
});
exports.deleteUser = deleteUser;
const updatePhoto = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        if (!req.user) {
            return (0, response_1.generateServerErrorCode)(res, 401, 'Utilisateur non authentifié', 'Vous devez être connecté pour modifier votre photo de profil.');
        }
        if (!req.file) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'Aucune image', 'Veuillez sélectionner une image.');
        }
        const userRepository = data_source_1.myDataSource.getRepository(user_entity_1.User);
        const user = yield userRepository.findOne({
            where: {
                id: req.user.id,
            },
        });
        if (!user) {
            return (0, response_1.generateServerErrorCode)(res, 404, 'Utilisateur introuvable', "L'utilisateur connecté n'existe pas.");
        }
        // URL enregistrée en base
        user.photoUrl =
            `/uploads/avatars/${req.file.filename}`;
        const updatedUser = yield userRepository.save(user);
        const { password } = updatedUser, userWithoutPassword = __rest(updatedUser, ["password"]);
        return (0, response_1.success)(res, 200, userWithoutPassword, 'La photo de profil a bien été mise à jour.');
    }
    catch (error) {
        console.error('Erreur updatePhoto:', error);
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La photo de profil n'a pas pu être mise à jour.");
    }
});
exports.updatePhoto = updatePhoto;
