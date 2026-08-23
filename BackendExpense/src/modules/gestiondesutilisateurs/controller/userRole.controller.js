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
exports.deleteUserRole = exports.createUserRole = void 0;
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const class_validator_1 = require("class-validator");
const UserRole_entity_1 = require("../entity/UserRole.entity");
const createUserRole = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    if (!req.body.roles && req.body.roles.length < 0) {
        return (0, response_1.generateServerErrorCode)(res, 400, "Aucune liste de roles", "Aucune liste de roles");
    }
    yield data_source_1.myDataSource.manager.transaction((transactionalEntityManager) => __awaiter(void 0, void 0, void 0, function* () {
        //Le front doit envoyer ce modele
        /**
         * objet : {
         * roles:number[],
         * userId:number
         * }
         */
        const roles = req.body.roles;
        const userId = req.body.userId;
        console.log('roles', roles);
        console.log('userId', userId);
        let userRoles = [];
        if (roles && userId) {
            for (let index = 0; index < roles.length; index++) {
                const userRole = new UserRole_entity_1.UserRole();
                userRole.userId = userId;
                userRole.roleId = roles[index];
                userRole.dateAffectation = new Date();
                userRoles.push(userRole);
            }
            yield transactionalEntityManager.save(userRoles);
            console.log('userRoles', userRoles);
        }
    })).then(userRoles => {
        const message = `Le rôle a été mis à jour avec succès`;
        return (0, response_1.success)(res, 200, userRoles, message);
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
exports.createUserRole = createUserRole;
/* export const getUserRole = async (req: Request, res: Response) => {
     await myDataSource.getRepository(UserRole).findOneBy({id: parseInt(req.params.id)})
     .then(role => {
         if(role === null) {
           const message = `Le role demandé n'existe pas. Réessayez avec un autre identifiant.`
           return generateServerErrorCode(res,400,"L'id n'existe pas",message)
         }
         const message = 'Le role a bien été trouvé.'
         return success(res,200, role,message);
     })
     .catch(error => {
         const message = `Le role n'a pas pu être récupéré. Réessayez dans quelques instants.`
         return generateServerErrorCode(res,500,error,message)
     })
 }; */
const deleteUserRole = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    //const resultat = await checkRelationsOneToMany('Role', parseInt(req.params.id));
    yield data_source_1.myDataSource.getRepository(UserRole_entity_1.UserRole).findOneBy({ id: parseInt(req.params.id) }).then(userRole => {
        if (userRole === null) {
            const message = `Le role de l'utilisateur demandé n'existe pas. Réessayez avec un autre identifiant.`;
            return (0, response_1.generateServerErrorCode)(res, 400, "L'id n'existe pas", message);
        }
        data_source_1.myDataSource.getRepository(UserRole_entity_1.UserRole).softRemove(userRole)
            .then(_ => {
            const message = `Le rôle de l'utilisateur avec l'identifiant n°${userRole.id} a bien été supprimé.`;
            return (0, response_1.success)(res, 200, userRole, message);
        });
    })
        .catch(error => {
        const message = `Le rôle n'a pas pu être supprimé. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.deleteUserRole = deleteUserRole;
