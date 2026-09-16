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
exports.deleteObjectif = exports.getVersementsByObjectif = exports.addMontantObjectif = exports.updateObjectif = exports.getObjectifById = exports.getObjectifsPaginated = exports.getAllObjectifs = exports.createObjectif = void 0;
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const paginationAndRechercheInit_1 = require("../../../configs/paginationAndRechercheInit");
const objectif_entity_1 = require("../entity/objectif.entity");
const versement_entity_1 = require("../entity/versement.entity");
// ====================== CREATE ======================
const createObjectif = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b, _c;
    try {
        const repo = data_source_1.myDataSource.getRepository(objectif_entity_1.Objectif);
        // Adapte cette ligne à ton middleware d'auth :
        // si le userId vient du token JWT (ex: req.user.id), remplace la ligne
        // ci-dessous par : const userId = (req as any).user?.id;
        const userId = (_a = req.body.userId) !== null && _a !== void 0 ? _a : (_b = req.user) === null || _b === void 0 ? void 0 : _b.id;
        const objectif = repo.create(Object.assign(Object.assign({}, req.body), { userId, currentAmount: (_c = req.body.currentAmount) !== null && _c !== void 0 ? _c : 0 }));
        const saved = yield repo.save(objectif);
        return (0, response_1.success)(res, 201, saved, "L'objectif d'épargne a bien été créé.");
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "L'objectif n'a pas pu être créé. Réessayez dans quelques instants.");
    }
});
exports.createObjectif = createObjectif;
// ====================== GET ALL (de l'utilisateur connecté) ======================
const getAllObjectifs = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _d, _e;
    try {
        const userId = (_e = (_d = req.user) === null || _d === void 0 ? void 0 : _d.id) !== null && _e !== void 0 ? _e : req.query.userId;
        const where = userId ? { userId: userId } : {};
        const objectifs = yield data_source_1.myDataSource.getRepository(objectif_entity_1.Objectif).find({
            where,
            order: { id: 'DESC' },
        });
        return (0, response_1.success)(res, 200, objectifs, 'La liste des objectifs a bien été récupérée.');
    }
    catch (error) {
        console.error('❌ Erreur getAllObjectifs:', error);
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La liste des objectifs n'a pas pu être récupérée.");
    }
});
exports.getAllObjectifs = getAllObjectifs;
// ====================== PAGINATED ======================
const getObjectifsPaginated = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { limit, searchTerm, startIndex } = (0, paginationAndRechercheInit_1.paginationAndRechercheInit)(req, objectif_entity_1.Objectif);
        let query = data_source_1.myDataSource
            .getRepository(objectif_entity_1.Objectif)
            .createQueryBuilder('o');
        if (searchTerm) {
            query = query.where('o.title ILIKE :keyword', { keyword: `%${searchTerm}%` });
        }
        const [data, totalElements] = yield query
            .orderBy('o.id', 'DESC')
            .skip(startIndex)
            .take(limit)
            .getManyAndCount();
        const totalPages = Math.ceil(totalElements / limit);
        return (0, response_1.success)(res, 200, { data, totalPages, totalElements, limit }, 'La liste des objectifs a bien été récupérée.');
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, 'Erreur lors de la récupération paginée des objectifs.');
    }
});
exports.getObjectifsPaginated = getObjectifsPaginated;
// ====================== GET BY ID ======================
const getObjectifById = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const objectif = yield data_source_1.myDataSource
            .getRepository(objectif_entity_1.Objectif)
            .findOne({ where: { id: id } });
        if (!objectif) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "L'objectif demandé n'existe pas.");
        }
        return (0, response_1.success)(res, 200, objectif, "L'objectif a bien été trouvé.");
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "L'objectif n'a pas pu être récupéré.");
    }
});
exports.getObjectifById = getObjectifById;
// ====================== UPDATE (édition complète) ======================
const updateObjectif = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const repo = data_source_1.myDataSource.getRepository(objectif_entity_1.Objectif);
        const objectif = yield repo.findOne({ where: { id: id } });
        if (!objectif) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "Cet objectif n'existe pas.");
        }
        repo.merge(objectif, req.body);
        const updated = yield repo.save(objectif);
        return (0, response_1.success)(res, 200, updated, "L'objectif a bien été modifié.");
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "L'objectif n'a pas pu être modifié.");
    }
});
exports.updateObjectif = updateObjectif;
// ====================== AJOUTER UN MONTANT (endpoint dédié) ======================
const addMontantObjectif = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const { amount } = req.body;
        if (amount === undefined || Number(amount) <= 0) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'Montant invalide', 'Le montant à ajouter doit être un nombre positif.');
        }
        const objectifRepo = data_source_1.myDataSource.getRepository(objectif_entity_1.Objectif);
        const versementRepo = data_source_1.myDataSource.getRepository(versement_entity_1.Versement);
        const objectif = yield objectifRepo.findOne({ where: { id: id } });
        if (!objectif) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "Cet objectif n'existe pas.");
        }
        objectif.currentAmount = Number(objectif.currentAmount) + Number(amount);
        // Transaction: on met à jour l'objectif ET on trace le versement ensemble
        const updated = yield data_source_1.myDataSource.transaction((manager) => __awaiter(void 0, void 0, void 0, function* () {
            const saved = yield manager.save(objectif_entity_1.Objectif, objectif);
            yield manager.save(versement_entity_1.Versement, {
                objectifId: saved.id,
                montant: Number(amount),
            });
            return saved;
        }));
        return (0, response_1.success)(res, 200, updated, 'Le montant a bien été ajouté à votre objectif.');
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "Le montant n'a pas pu être ajouté.");
    }
});
exports.addMontantObjectif = addMontantObjectif;
// ====================== HISTORIQUE DES VERSEMENTS ======================
const getVersementsByObjectif = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const versements = yield data_source_1.myDataSource.getRepository(versement_entity_1.Versement).find({
            where: { objectifId: id },
            order: { createdAt: 'ASC' },
        });
        return (0, response_1.success)(res, 200, versements, "L'historique a bien été récupéré.");
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "L'historique n'a pas pu être récupéré.");
    }
});
exports.getVersementsByObjectif = getVersementsByObjectif;
// // ====================== AJOUTER UN MONTANT (endpoint dédié) ======================
// export const addMontantObjectif = async (req: Request, res: Response) => {
//   try {
//     const { id } = req.params;
//     const { amount } = req.body;
//     if (amount === undefined || Number(amount) <= 0) {
//       return generateServerErrorCode(
//         res,
//         400,
//         'Montant invalide',
//         'Le montant à ajouter doit être un nombre positif.'
//       );
//     }
//     const repo = myDataSource.getRepository(Objectif);
//     const objectif = await repo.findOne({ where: { id: id as any } });
//     if (!objectif) {
//       return generateServerErrorCode(
//         res,
//         404,
//         "L'ID n'existe pas",
//         "Cet objectif n'existe pas."
//       );
//     }
//     objectif.currentAmount = Number(objectif.currentAmount) + Number(amount);
//     const updated = await repo.save(objectif);
//     return success(res, 200, updated, 'Le montant a bien été ajouté à votre objectif.');
//   } catch (error: any) {
//     return generateServerErrorCode(
//       res,
//       500,
//       error,
//       "Le montant n'a pas pu être ajouté."
//     );
//   }
// };
// ====================== DELETE ======================
const deleteObjectif = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const repo = data_source_1.myDataSource.getRepository(objectif_entity_1.Objectif);
        const objectif = yield repo.findOne({ where: { id: id } });
        if (!objectif) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "L'objectif demandé n'existe pas.");
        }
        yield repo.remove(objectif);
        return (0, response_1.success)(res, 200, objectif, "L'objectif a bien été supprimé.");
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "L'objectif n'a pas pu être supprimé.");
    }
});
exports.deleteObjectif = deleteObjectif;
