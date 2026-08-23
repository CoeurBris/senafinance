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
exports.deleteBudget = exports.updateBudget = exports.getBudgetById = exports.getBudgetsPaginated = exports.getAllBudgets = exports.createBudget = void 0;
const class_validator_1 = require("class-validator");
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const checkRelationsOneToManyBeforDelete_1 = require("../../../configs/checkRelationsOneToManyBeforDelete");
const paginationAndRechercheInit_1 = require("../../../configs/paginationAndRechercheInit");
const budget_entity_1 = require("../entity/budget.entity");
// ====================== CREATE ======================
const createBudget = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const budgetRepository = data_source_1.myDataSource.getRepository(budget_entity_1.Budget);
        const budget = budgetRepository.create(req.body);
        const savedBudget = (yield budgetRepository.save(budget));
        const message = `Le budget a bien été créé.`;
        return (0, response_1.success)(res, 201, savedBudget, message);
    }
    catch (error) {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Les données du budget sont invalides.');
        }
        return (0, response_1.generateServerErrorCode)(res, 500, error, "Le budget n'a pas pu être ajouté. Réessayez dans quelques instants.");
    }
});
exports.createBudget = createBudget;
// ====================== GET ALL ======================
const getAllBudgets = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const budgets = yield data_source_1.myDataSource.getRepository(budget_entity_1.Budget).find({
            relations: ['category'],
            order: { id: 'DESC' },
        });
        const message = 'La liste des budgets a bien été récupérée.';
        return (0, response_1.success)(res, 200, budgets, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La liste des budgets n'a pas pu être récupérée. Réessayez dans quelques instants.");
    }
});
exports.getAllBudgets = getAllBudgets;
// ====================== PAGINATED ======================
const getBudgetsPaginated = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { limit, searchTerm, startIndex } = (0, paginationAndRechercheInit_1.paginationAndRechercheInit)(req, budget_entity_1.Budget);
        let query = data_source_1.myDataSource
            .getRepository(budget_entity_1.Budget)
            .createQueryBuilder('b')
            .leftJoinAndSelect('b.category', 'category');
        if (searchTerm) {
            query = query.where('( category.name ILIKE :keyword OR b.description ILIKE :keyword )', { keyword: `%${searchTerm}%` });
        }
        const [data, totalElements] = yield query
            .orderBy('b.id', 'DESC')
            .skip(startIndex)
            .take(limit)
            .getManyAndCount();
        const totalPages = Math.ceil(totalElements / limit);
        const message = 'La liste des budgets a bien été récupérée.';
        return (0, response_1.success)(res, 200, { data, totalPages, totalElements, limit }, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "Erreur lors de la récupération paginée des budgets.");
    }
});
exports.getBudgetsPaginated = getBudgetsPaginated;
// ====================== GET BY ID ======================
const getBudgetById = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const budget = yield data_source_1.myDataSource.getRepository(budget_entity_1.Budget).findOne({
            where: { id: id },
            relations: ['category'],
        });
        if (!budget) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "Le budget demandé n'existe pas.");
        }
        const message = 'Le budget a bien été trouvé.';
        return (0, response_1.success)(res, 200, budget, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "Le budget n'a pas pu être récupéré. Réessayez dans quelques instants.");
    }
});
exports.getBudgetById = getBudgetById;
// ====================== UPDATE ======================
const updateBudget = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const budgetRepository = data_source_1.myDataSource.getRepository(budget_entity_1.Budget);
        const budget = yield budgetRepository.findOne({
            where: { id: id },
        });
        if (!budget) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "Ce budget n'existe pas.");
        }
        budgetRepository.merge(budget, req.body);
        const updatedBudget = yield budgetRepository.save(budget);
        const message = `Le budget a bien été modifié.`;
        return (0, response_1.success)(res, 200, updatedBudget, message);
    }
    catch (error) {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Les données du budget sont invalides.');
        }
        return (0, response_1.generateServerErrorCode)(res, 500, error, "Le budget n'a pas pu être modifié. Réessayez dans quelques instants.");
    }
});
exports.updateBudget = updateBudget;
// ====================== DELETE ======================
const deleteBudget = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const budgetRepository = data_source_1.myDataSource.getRepository(budget_entity_1.Budget);
        const budget = yield budgetRepository.findOne({
            where: { id: id },
        });
        if (!budget) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "Le budget demandé n'existe pas.");
        }
        const hasRelations = yield (0, checkRelationsOneToManyBeforDelete_1.checkRelationsOneToMany)('Budget', id);
        if (hasRelations) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'Relations existantes', 'Ce budget est lié à d\'autres enregistrements et ne peut pas être supprimé.');
        }
        yield budgetRepository.remove(budget);
        const message = `Le budget a bien été supprimé.`;
        return (0, response_1.success)(res, 200, budget, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "Le budget n'a pas pu être supprimé. Réessayez dans quelques instants.");
    }
});
exports.deleteBudget = deleteBudget;
