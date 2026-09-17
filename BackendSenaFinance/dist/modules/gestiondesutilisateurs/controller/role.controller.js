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
exports.deleteRolePermission = exports.deleteRole = exports.updateRole = exports.getRolesNotIn = exports.getRole = exports.getSimpleRole = exports.getAllRole = exports.getAllRoles = exports.createRolePermission = exports.createRole = void 0;
const Role_entity_1 = require("../entity/Role.entity");
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const class_validator_1 = require("class-validator");
const RolePermission_entity_1 = require("../entity/RolePermission.entity");
const config_1 = require("../../../configs/config");
const paginationAndRechercheInit_1 = require("../../../configs/paginationAndRechercheInit");
const checkRelationsOneToManyBeforDelete_1 = require("../../../configs/checkRelationsOneToManyBeforDelete");
const createRole = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const role = data_source_1.myDataSource.getRepository(Role_entity_1.Role).create(req.body);
    const errors = yield (0, class_validator_1.validate)(role);
    if (errors.length > 0) {
        const message = (0, response_1.validateMessage)(errors);
        return (0, response_1.generateServerErrorCode)(res, 400, errors, message);
    }
    yield data_source_1.myDataSource.manager.transaction((transactionalEntityManager) => __awaiter(void 0, void 0, void 0, function* () {
        const resulRo = yield transactionalEntityManager.save(role);
        var roleId;
        if ((0, class_validator_1.isArray)(resulRo)) {
            roleId = resulRo[0].id;
        }
        else {
            const resultrol = resulRo;
            roleId = resultrol.id;
        }
        const permission = req.body.privileges;
        let rolePermissions = [];
        if (permission && roleId) {
            for (let index = 0; index < permission.length; index++) {
                const element = new RolePermission_entity_1.RolePermission();
                element.permissionId = parseInt(permission[index]);
                element.roleId = roleId;
                rolePermissions.push(element);
            }
            yield transactionalEntityManager.save(rolePermissions);
        }
    })).then(role => {
        const message = `Le rôle et ses privilèges ont bien été créés.`;
        return (0, response_1.success)(res, 201, role, message);
    }).catch(error => {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Ce role existe déjà');
        }
        if (error.code == "ER_DUP_ENTRY") {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Ce role existe déjà');
        }
        const message = `Le rôle n'a pas pu être ajouté. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.createRole = createRole;
const createRolePermission = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    if (req.body.privileges.length < 1) {
        return (0, response_1.generateServerErrorCode)(res, 400, "Aucune liste de privilège", "Aucune liste de privilège");
    }
    yield data_source_1.myDataSource.manager.transaction((transactionalEntityManager) => __awaiter(void 0, void 0, void 0, function* () {
        const permission = req.body.privileges;
        let rolePermissions = [];
        if (permission && req.body.idRole) {
            for (let index = 0; index < permission.length; index++) {
                const element = new RolePermission_entity_1.RolePermission();
                element.permissionId = parseInt(permission[index]);
                element.roleId = req.body.idRole;
                rolePermissions.push(element);
            }
            yield transactionalEntityManager.save(rolePermissions);
        }
    })).then(role => {
        const message = `Le rôle a été mis à jour avec succès`;
        return (0, response_1.success)(res, 200, role, message);
    }).catch(error => {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Ce role existe déjà');
        }
        if (error.code == "ER_DUP_ENTRY") {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Ce role existe déjà');
        }
        const message = `Le rôle n'a pas pu être ajouté. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.createRolePermission = createRolePermission;
const getAllRoles = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { page, limit, searchTerm, startIndex, searchQueries } = (0, paginationAndRechercheInit_1.paginationAndRechercheInit)(req, Role_entity_1.Role);
    yield data_source_1.myDataSource.getRepository(Role_entity_1.Role)
        .find({
        select: { id: true, nom: true, description: true, rolePermissions: { permissionId: true, permission: { nom: true, description: true } } },
        relations: { rolePermissions: { permission: true } }
    })
        .then(roles => {
        const message = 'La liste des roles a bien été récupéré.';
        return (0, response_1.success)(res, 200, roles, message);
    }).catch(error => {
        const message = `La liste des roles n'a pas pu être récupéré. Réessayez dans quelques instants.`;
        ////res.status(500).json({ message, data: error })
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.getAllRoles = getAllRoles;
const getAllRole = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { page, limit, searchTerm, startIndex, searchQueries } = (0, paginationAndRechercheInit_1.paginationAndRechercheInit)(req, Role_entity_1.Role);
    try {
        const data = yield data_source_1.myDataSource.getRepository(Role_entity_1.Role)
            .createQueryBuilder('role')
            //.leftJoinAndSelect('user.userRoles', 'userRole')
            //.leftJoinAndSelect('userRole.role', 'role')
            //.where("role.deletedAt IS NULL")
            .where("role.IsChecked = 1 ")
            .getMany();
        const message = 'La liste des utilisateurs a bien été récupérée.';
        return (0, response_1.success)(res, 200, data, message);
    }
    catch (error) {
        const message = `La liste des utilisateurs n'a pas pu être récupérée. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    }
});
exports.getAllRole = getAllRole;
/* export const getAllRole = async (req: Request, res: Response) => {
     const { page, limit, searchTerm, startIndex, searchQueries } = paginationAndRechercheInit(req, Role);
     await myDataSource.getRepository(Role)
         .find({
             select:{id:true, nom:true, description:true, rolePermissions:{ permissionId:true, permission:{ nom:true, description:true }}},
             relations: { rolePermissions: { permission: true}}
         })
     .then(roles => {
         const message = 'La liste des roles a bien été récupéré.';
         return success(res,200,roles, message);
     }).catch(error => {
         const message = `La liste des roles n'a pas pu être récupéré. Réessayez dans quelques instants.`
         ////res.status(500).json({ message, data: error })
         return generateServerErrorCode(res,500,error,message)
     })
 };
*/
const getSimpleRole = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    console.log(req.params.id, "aaaaaaaaaaaaaaaaaaaaaaaaaaa");
    yield data_source_1.myDataSource.getRepository(Role_entity_1.Role).findOneBy({ id: parseInt(req.params.id) })
        .then(role => {
        if (role === null) {
            const message = `Le rôle demandé n'existe pas. Réessayez avec un autre identifiant.`;
            return (0, response_1.generateServerErrorCode)(res, 400, "L'id n'existe pas", message);
        }
        const message = 'Un rôle a bien été trouvé.';
        return (0, response_1.success)(res, 200, role, message);
    })
        .catch(error => {
        const message = `Le rôle n'a pas pu être récupéré. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.getSimpleRole = getSimpleRole;
const getRole = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield data_source_1.myDataSource.getRepository(Role_entity_1.Role).findOne({
        where: { id: parseInt(req.params.id) },
        select: { id: true, nom: true, description: true, createdAt: true },
        relations: {
            rolePermissions: { permission: true },
        }
    }).then(role => {
        if (role === null) {
            const message = `Le rôle demandé n'existe pas. Réessayez avec un autre identifiant.`;
            return (0, response_1.generateServerErrorCode)(res, 400, "L'id n'existe pas", message);
        }
        const message = 'Un rôle a bien été trouvé.';
        return (0, response_1.success)(res, 200, role, message);
    }).catch(error => {
        const message = `Le rôle n'a pas pu être récupéré. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.getRole = getRole;
const getRolesNotIn = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const userId = req.params.userId;
        // Récupérer les rôles que l'utilisateur possède
        const userRoles = yield data_source_1.myDataSource.getRepository(Role_entity_1.Role)
            .createQueryBuilder("role")
            .select("role.id")
            .leftJoinAndSelect("role.userRoles", "userRole")
            .leftJoinAndSelect("userRole.user", "user")
            .where("user.id = :id", { id: userId })
            .getMany();
        // Récupérer les rôles que l'utilisateur n'a pas
        const rolesNotIn = yield data_source_1.myDataSource.getRepository(Role_entity_1.Role)
            .createQueryBuilder("role")
            .where(`role.id NOT IN (:...ids)`, { ids: userRoles.map(role => role.id) })
            .getMany();
        const message = 'Les rôles non attribués ont été récupérés avec succès.';
        return (0, response_1.success)(res, 200, rolesNotIn, message);
    }
    catch (error) {
        const message = `Les rôles non attribués n'ont pas pu être récupérés. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    }
});
exports.getRolesNotIn = getRolesNotIn;
const updateRole = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const role = yield data_source_1.myDataSource.getRepository(Role_entity_1.Role).findOneBy({ id: parseInt(req.params.id), });
    if (!role) {
        return (0, response_1.generateServerErrorCode)(res, 400, "L'id n'existe pas", 'Ce rôle existe déjà');
    }
    const rolemerge = data_source_1.myDataSource.getRepository(Role_entity_1.Role).merge(role, req.body);
    const errors = yield (0, class_validator_1.validate)(role);
    if (errors.length > 0) {
        const message = (0, response_1.validateMessage)(errors);
        return (0, response_1.generateServerErrorCode)(res, 400, errors, message);
    }
    let privileges = [];
    yield data_source_1.myDataSource.manager.getRepository(RolePermission_entity_1.RolePermission).find({
        where: { roleId: parseInt(req.params.id) },
        select: { permissionId: true }
    }).then(rolePermission => {
        rolePermission.forEach(element => {
            privileges.push(element.permissionId.toString());
        });
        // console.log(privileges,'privileges ancien');
    });
    let intersection = req.body.privileges.filter(x => !privileges.includes(x));
    yield data_source_1.myDataSource.manager.transaction((transactionalEntityManager) => __awaiter(void 0, void 0, void 0, function* () {
        const resulRo = yield transactionalEntityManager.save(rolemerge);
        var roleId;
        //req.params.id;
        if ((0, class_validator_1.isArray)(resulRo)) {
            roleId = resulRo[0].id;
        }
        else {
            const resultrol = resulRo;
            roleId = resultrol.id;
        }
        const permission = req.body.privileges;
        let rolePermissions = [];
        if (permission && roleId) {
            for (let index = 0; index < permission.length; index++) {
                if (!privileges.includes(permission[index])) {
                    const element = new RolePermission_entity_1.RolePermission();
                    element.permissionId = parseInt(permission[index]);
                    element.roleId = parseInt(roleId);
                    rolePermissions.push(element);
                }
            }
            if (rolePermissions.length > 0) {
                yield transactionalEntityManager.save(rolePermissions);
            }
        }
        const diff = (0, config_1.diffToTwoArray)(permission, privileges);
        // console.log(diff,'diff');
        if (diff.length > 0) {
            transactionalEntityManager.getRepository(RolePermission_entity_1.RolePermission).createQueryBuilder()
                .softDelete()
                .where("permissionId in (:permissionIds )", { permissionIds: diff.join(',') })
                .andWhere("roleId in (:roleId )", { roleId: req.params.id })
                .execute();
        }
    })).then(role => {
        const message = `Le rôle ${req.body.nom} et ses privilèges sont bien été modifié.`;
        return (0, response_1.success)(res, 200, role, message);
    }).catch(error => {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Ce role existe déjà');
        }
        if (error.code == "ER_DUP_ENTRY") {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Ce role existe déjà');
        }
        const message = `Le rôle n'a pas pu être ajouté. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.updateRole = updateRole;
const deleteRole = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const resultat = yield (0, checkRelationsOneToManyBeforDelete_1.checkRelationsOneToMany)('Role', parseInt(req.params.id));
    yield data_source_1.myDataSource.getRepository(Role_entity_1.Role).findOneBy({ id: parseInt(req.params.id) }).then(role => {
        if (role === null) {
            const message = `Le rôle demandé n'existe pas. Réessayez avec un autre identifiant.`;
            return (0, response_1.generateServerErrorCode)(res, 400, "L'id n'existe pas", message);
        }
        if (resultat) {
            const message = `Ce rôle est lié à d'autres enregistrements. Vous ne pouvez pas le supprimer.`;
            return (0, response_1.generateServerErrorCode)(res, 400, "Ce rôle est lié à d'autres enregistrements. Vous ne pouvez pas le supprimer.", message);
        }
        else {
            data_source_1.myDataSource.getRepository(Role_entity_1.Role).softRemove(role)
                .then(_ => {
                const message = `Le rôle avec l'identifiant n°${role.id} a bien été supprimé.`;
                return (0, response_1.success)(res, 200, role, message);
            });
        }
    })
        .catch(error => {
        const message = `Le rôle n'a pas pu être supprimé. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.deleteRole = deleteRole;
const deleteRolePermission = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    //const resultat = await checkRelationsOneToMany('Role', parseInt(req.params.id));
    yield data_source_1.myDataSource.getRepository(RolePermission_entity_1.RolePermission).findOneBy({ id: parseInt(req.params.id) }).then(role => {
        if (role === null) {
            const message = `Le rôle demandé n'existe pas. Réessayez avec un autre identifiant.`;
            return (0, response_1.generateServerErrorCode)(res, 400, "L'id n'existe pas", message);
        }
        data_source_1.myDataSource.getRepository(RolePermission_entity_1.RolePermission).softRemove(role)
            .then(_ => {
            const message = `Le rôle avec l'identifiant n°${role.id} a bien été supprimé.`;
            return (0, response_1.success)(res, 200, role, message);
        });
    })
        .catch(error => {
        const message = `Le rôle n'a pas pu être supprimé. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.deleteRolePermission = deleteRolePermission;
