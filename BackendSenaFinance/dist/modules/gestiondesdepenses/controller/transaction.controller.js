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
exports.deleteTransaction = exports.updateTransaction = exports.getTransactionById = exports.getTransactionsPaginated = exports.getAllTransactions = exports.createTransaction = void 0;
const class_validator_1 = require("class-validator");
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const checkRelationsOneToManyBeforDelete_1 = require("../../../configs/checkRelationsOneToManyBeforDelete");
const paginationAndRechercheInit_1 = require("../../../configs/paginationAndRechercheInit");
const category_entity_1 = require("../entity/category.entity");
const transaction_entity_1 = require("../entity/transaction.entity");
/**
 * Le TransactionModel Flutter envoie `category` comme un NOM de catégorie
 * (string), pas un `categoryId`. Cette fonction résout le nom en id avant
 * la création/mise à jour, tout en restant compatible si `categoryId` est
 * envoyé directement (ex: depuis un futur client web).
 *
 * ⚠️ Suppose que la colonne du nom dans `categories` s'appelle `name`.
 * Ajuste si besoin.
 */
const resolveCategoryId = (body) => __awaiter(void 0, void 0, void 0, function* () {
    if (body.categoryId)
        return body.categoryId;
    if (!body.category)
        return undefined;
    const category = yield data_source_1.myDataSource
        .getRepository(category_entity_1.Category)
        .findOne({ where: { name: body.category } });
    return category === null || category === void 0 ? void 0 : category.id;
});
// ====================== CREATE ======================
const createTransaction = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const transactionRepository = data_source_1.myDataSource.getRepository(transaction_entity_1.Transaction);
        const categoryId = yield resolveCategoryId(req.body);
        const transaction = transactionRepository.create(Object.assign(Object.assign({}, req.body), { categoryId }));
        const savedTransaction = (yield transactionRepository.save(transaction));
        const message = `La transaction a bien été enregistrée.`;
        return (0, response_1.success)(res, 201, savedTransaction, message);
    }
    catch (error) {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Les données de la transaction sont invalides.');
        }
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La transaction n'a pas pu être ajoutée. Réessayez dans quelques instants.");
    }
});
exports.createTransaction = createTransaction;
// ====================== GET ALL ======================
const getAllTransactions = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const transactions = yield data_source_1.myDataSource.getRepository(transaction_entity_1.Transaction).find({
            relations: ['category'],
            order: { date: 'DESC' }
        });
        const message = 'La liste des transactions a bien été récupérée.';
        return (0, response_1.success)(res, 200, transactions, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La liste des transactions n'a pas pu être récupérée. Réessayez dans quelques instants.");
    }
});
exports.getAllTransactions = getAllTransactions;
// ====================== PAGINATED ======================
const getTransactionsPaginated = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { limit, searchTerm, startIndex } = (0, paginationAndRechercheInit_1.paginationAndRechercheInit)(req, transaction_entity_1.Transaction);
        let query = data_source_1.myDataSource
            .getRepository(transaction_entity_1.Transaction)
            .createQueryBuilder('t')
            .leftJoinAndSelect('t.category', 'category');
        if (searchTerm) {
            query = query.where('( t.title ILIKE :keyword OR t.note ILIKE :keyword OR category.name ILIKE :keyword )', { keyword: `%${searchTerm}%` });
        }
        // Filtre optionnel par type: /transactions/paginated?type=Dépense
        if (req.query.type) {
            query = query.andWhere('t.type = :type', { type: req.query.type });
        }
        const [data, totalElements] = yield query
            .orderBy('t.date', 'DESC')
            .skip(startIndex)
            .take(limit)
            .getManyAndCount();
        const totalPages = Math.ceil(totalElements / limit);
        const message = 'La liste des transactions a bien été récupérée.';
        return (0, response_1.success)(res, 200, { data, totalPages, totalElements, limit }, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, 'Erreur lors de la récupération des transactions.');
    }
});
exports.getTransactionsPaginated = getTransactionsPaginated;
// ====================== GET BY ID ======================
const getTransactionById = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const transaction = yield data_source_1.myDataSource.getRepository(transaction_entity_1.Transaction).findOne({
            where: { id: id },
            relations: ['category']
        });
        if (!transaction) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "La transaction demandée n'existe pas.");
        }
        const message = 'La transaction a bien été trouvée.';
        return (0, response_1.success)(res, 200, transaction, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La transaction n'a pas pu être récupérée. Réessayez dans quelques instants.");
    }
});
exports.getTransactionById = getTransactionById;
// ====================== UPDATE ======================
const updateTransaction = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const transactionRepository = data_source_1.myDataSource.getRepository(transaction_entity_1.Transaction);
        const transaction = yield transactionRepository.findOne({
            where: { id: id }
        });
        if (!transaction) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "Cette transaction n'existe pas.");
        }
        const categoryId = yield resolveCategoryId(req.body);
        transactionRepository.merge(transaction, Object.assign(Object.assign({}, req.body), (categoryId ? { categoryId } : {})));
        const updatedTransaction = yield transactionRepository.save(transaction);
        const message = `La transaction a bien été modifiée.`;
        return (0, response_1.success)(res, 200, updatedTransaction, message);
    }
    catch (error) {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Les données sont invalides.');
        }
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La transaction n'a pas pu être modifiée. Réessayez dans quelques instants.");
    }
});
exports.updateTransaction = updateTransaction;
// ====================== DELETE ======================
const deleteTransaction = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const transactionRepository = data_source_1.myDataSource.getRepository(transaction_entity_1.Transaction);
        const transaction = yield transactionRepository.findOne({
            where: { id: id }
        });
        if (!transaction) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "La transaction demandée n'existe pas.");
        }
        const hasRelations = yield (0, checkRelationsOneToManyBeforDelete_1.checkRelationsOneToMany)('Transaction', id);
        if (hasRelations) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'Relations existantes', "Cette transaction est liée à d'autres enregistrements et ne peut pas être supprimée.");
        }
        yield transactionRepository.remove(transaction);
        const message = `La transaction a bien été supprimée.`;
        return (0, response_1.success)(res, 200, transaction, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La transaction n'a pas pu être supprimée. Réessayez dans quelques instants.");
    }
});
exports.deleteTransaction = deleteTransaction;
