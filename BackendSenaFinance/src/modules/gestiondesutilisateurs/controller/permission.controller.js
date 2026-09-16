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
Object.defineProperty(exports, "__esModule", { value: true });
exports.deletePermission = exports.updatePermission = exports.getPermissionNotIn = exports.getPermission = exports.getAllPermissions = exports.getPermissions = exports.createPermission = void 0;
const permission_entity_1 = require("../entity/permission.entity");
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const class_validator_1 = require("class-validator");
const paginationAndRechercheInit_1 = require("../../../configs/paginationAndRechercheInit");
const typeorm_1 = require("typeorm");
const checkRelationsOneToManyBeforDelete_1 = require("../../../configs/checkRelationsOneToManyBeforDelete");
const createPermission = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const permission = data_source_1.myDataSource.getRepository(permission_entity_1.Permission).create(req.body);
    const errors = yield (0, class_validator_1.validate)(permission);
    if (errors.length > 0) {
        const message = (0, response_1.validateMessage)(errors);
        return (0, response_1.generateServerErrorCode)(res, 400, errors, message);
    }
    yield data_source_1.myDataSource.getRepository(permission_entity_1.Permission).save(permission)
        .then(permission => {
        const message = `La permission ${req.body.nom} a bien été crée.`;
        return (0, response_1.success)(res, 201, permission, message);
    })
        .catch(error => {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Cette permission existe déjà');
        }
        if (error.code == "ER_DUP_ENTRY") {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Cette permission existe déjà');
        }
        const message = `La permission n'a pas pu être ajouté. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.createPermission = createPermission;
const getPermissions = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    let reque = yield data_source_1.myDataSource.getRepository(permission_entity_1.Permission)
        .find({
        select: { id: true, nom: true, description: true, createdAt: true, rolePermissions: { roleId: true, role: { nom: true, description: true } } },
        relations: { rolePermissions: { role: true } }
    })
        .then(permissions => {
        const message = 'La liste des permissions a bien été récupéré.';
        return (0, response_1.success)(res, 200, permissions, message);
    }).catch(error => {
        const message = `La liste des permissions n'a pas pu être récupéré. Réessayez dans quelques instants.`;
        //res.status(500).json({ message, data: error })
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.getPermissions = getPermissions;
const getAllPermissions = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { page, limit, searchTerm, startIndex, searchQueries } = (0, paginationAndRechercheInit_1.paginationAndRechercheInit)(req, permission_entity_1.Permission);
    let reque = yield data_source_1.myDataSource.getRepository(permission_entity_1.Permission)
        // .find({ 
        //     select:{id:true, nom:true, description:true, createdAt:true, rolePermissions:{ roleId:true, role:{ nom:true, description:true }}},
        //         relations: { rolePermissions: { role: true}} 
        //     })
        .createQueryBuilder('permission')
        .leftJoinAndSelect("permission.rolePermissions", "rolePermissions")
        .leftJoinAndSelect("rolePermissions.role", "role")
        .where("permission.deletedAt IS NULL");
    if (searchQueries.length > 0) {
        reque.andWhere(new typeorm_1.Brackets(qb => {
            qb.where(searchQueries.join(' OR '), { keyword: `%${searchTerm}%` });
        }));
    }
    reque.skip(startIndex)
        .take(limit)
        .getManyAndCount()
        .then(([data, totalElements]) => {
        const message = 'La liste des permissions a bien été récupéré.';
        const totalPages = Math.ceil(totalElements / limit);
        return (0, response_1.success)(res, 200, { data, totalPages, totalElements, limit }, message);
    }).catch(error => {
        const message = `La liste des permissions n'a pas pu être récupéré. Réessayez dans quelques instants.`;
        //res.status(500).json({ message, data: error })
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.getAllPermissions = getAllPermissions;
const getPermission = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield data_source_1.myDataSource.getRepository(permission_entity_1.Permission).findOneBy({ id: parseInt(req.params.id) })
        .then(permission => {
        if (permission === null) {
            const message = `La permission demandé n'existe pas. Réessayez avec un autre identifiant.`;
            return (0, response_1.generateServerErrorCode)(res, 400, "L'id n'existe pas", message);
        }
        const message = 'La permission a bien été trouvé.';
        return (0, response_1.success)(res, 200, permission, message);
    })
        .catch(error => {
        const message = `La permission n'a pas pu être récupéré. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.getPermission = getPermission;
const getPermissionNotIn = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const userId = req.params.userId;
    const sesPermissions = yield data_source_1.myDataSource.getRepository(permission_entity_1.Permission)
        .createQueryBuilder("permission")
        .select("permission.id")
        .leftJoinAndSelect("permission.rolePermissions", "rolePermission")
        .leftJoinAndSelect("rolePermission.role", "role")
        .where("role.id = :id", { id: userId })
        .getMany();
    yield data_source_1.myDataSource.getRepository(permission_entity_1.Permission)
        .createQueryBuilder("per")
        .where(`per.id NOT IN (:...ids)`, { ids: sesPermissions.map(permission => permission.id) })
        .getMany()
        .then(permission => {
        console.log("LES PERMISSION QU'IL N'A PAS SONT LAAAA");
        console.log(permission);
        if (permission === null) {
            const message = `La permission demandé n'existe pas. Réessayez avec un autre identifiant.`;
            return (0, response_1.generateServerErrorCode)(res, 400, "L'id n'existe pas", message);
        }
        const message = 'Les permission ont bien été récupéré.';
        return (0, response_1.success)(res, 200, permission, message);
    })
        .catch(error => {
        const message = `La permission n'a pas pu être récupéré. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.getPermissionNotIn = getPermissionNotIn;
const updatePermission = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const permission = yield data_source_1.myDataSource.getRepository(permission_entity_1.Permission).findOneBy({ id: parseInt(req.params.id), });
    if (!permission) {
        return (0, response_1.generateServerErrorCode)(res, 400, "L'id n'existe pas", 'Cette permission existe déjà');
    }
    data_source_1.myDataSource.getRepository(permission_entity_1.Permission).merge(permission, req.body);
    const errors = yield (0, class_validator_1.validate)(permission);
    if (errors.length > 0) {
        const message = (0, response_1.validateMessage)(errors);
        return (0, response_1.generateServerErrorCode)(res, 400, errors, message);
    }
    yield data_source_1.myDataSource.getRepository(permission_entity_1.Permission).save(permission).then(permission => {
        const message = `La permission ${req.body.id} a bien été modifié.`;
        return (0, response_1.success)(res, 200, permission, message);
    }).catch(error => {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Cette permission existe déjà');
        }
        if (error.code == "ER_DUP_ENTRY") {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Cette permission existe déjà');
        }
        const message = `La permission n'a pas pu être ajouté. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.updatePermission = updatePermission;
const deletePermission = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const resultat = yield (0, checkRelationsOneToManyBeforDelete_1.checkRelationsOneToMany)('Permission', parseInt(req.params.id));
    yield data_source_1.myDataSource.getRepository(permission_entity_1.Permission).findOneBy({ id: parseInt(req.params.id) }).then(permission => {
        if (permission === null) {
            const message = `La permission demandé n'existe pas. Réessayez avec un autre identifiant.`;
            return (0, response_1.generateServerErrorCode)(res, 400, "L'id n'existe pas", message);
        }
        if (resultat) {
            const message = `Cette permission est liée à d'autres enregistrements. Vous ne pouvez pas le supprimer.`;
            return (0, response_1.generateServerErrorCode)(res, 400, "Cette permission est liée à d'autres enregistrements. Vous ne pouvez pas le supprimer.", message);
        }
        else {
            data_source_1.myDataSource.getRepository(permission_entity_1.Permission).softRemove(permission)
                .then(_ => {
                const message = `La permission avec l'identifiant n°${permission.id} a bien été supprimé.`;
                return (0, response_1.success)(res, 200, permission, message);
            });
        }
    }).catch(error => {
        const message = `La permission n'a pas pu être supprimé. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.deletePermission = deletePermission;
