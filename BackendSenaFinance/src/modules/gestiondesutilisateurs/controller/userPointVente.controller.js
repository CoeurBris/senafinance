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
exports.deleteUserPointVente = exports.createUserPointVente = void 0;
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const class_validator_1 = require("class-validator");
const UserPointVente_entity_1 = require("../entity/UserPointVente.entity");
const createUserPointVente = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    if (!req.body.pointventes || req.body.pointventes.length == 0) {
        return (0, response_1.generateServerErrorCode)(res, 400, "Aucune liste de pointventes", "Aucune liste de pointventes");
    }
    const pointventes = req.body.pointventes;
    const userId = req.params.id;
    console.log('pointventes', pointventes);
    console.log('userId', userId);
    let userPointVentes = [];
    if (pointventes && userId) {
        for (let index = 0; index < pointventes.length; index++) {
            userPointVentes.push({ user: userId, pointvente: pointventes[index] });
        }
    }
    console.log('userPointVentes je suis la', userPointVentes);
    yield data_source_1.myDataSource.getRepository(UserPointVente_entity_1.UserPointVente).save(userPointVentes)
        .then(data => {
        const message = `Le point de vente a été mis à jour avec succès`;
        return (0, response_1.success)(res, 200, data, message);
    }).catch(error => {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Ce point de vente existe déjà');
        }
        if (error.code == "ER_DUP_ENTRY") {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Ce point de vente existe déjà');
        }
        const message = `Le point de vente n'a pas pu être ajouté. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.createUserPointVente = createUserPointVente;
const deleteUserPointVente = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    //const resultat = await checkRelationsOneToMany('Role', parseInt(req.params.id));
    yield data_source_1.myDataSource.getRepository(UserPointVente_entity_1.UserPointVente).findOneBy({ id: parseInt(req.params.id) }).then(userPointVente => {
        if (userPointVente === null) {
            const message = `Le pointvente de l'utilisateur demandé n'existe pas. Réessayez avec un autre identifiant.`;
            return (0, response_1.generateServerErrorCode)(res, 400, "L'id n'existe pas", message);
        }
        data_source_1.myDataSource.getRepository(UserPointVente_entity_1.UserPointVente).softRemove(userPointVente)
            .then(_ => {
            const message = `Le rôle de l'utilisateur avec l'identifiant n°${userPointVente.id} a bien été supprimé.`;
            return (0, response_1.success)(res, 200, userPointVente, message);
        });
    })
        .catch(error => {
        const message = `Le rôle n'a pas pu être supprimé. Réessayez dans quelques instants.`;
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.deleteUserPointVente = deleteUserPointVente;
