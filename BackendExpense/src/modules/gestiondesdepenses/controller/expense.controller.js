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
exports.deleteExpense = exports.updateExpense = exports.getExpenseById = exports.getExpensesPaginated = exports.getAllExpenses = exports.createExpense = void 0;
const class_validator_1 = require("class-validator");
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const checkRelationsOneToManyBeforDelete_1 = require("../../../configs/checkRelationsOneToManyBeforDelete");
const paginationAndRechercheInit_1 = require("../../../configs/paginationAndRechercheInit");
const expense_entity_1 = require("../entity/expense.entity");
// ====================== CREATE ======================
const createExpense = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const expenseRepository = data_source_1.myDataSource.getRepository(expense_entity_1.Expense);
        const expense = expenseRepository.create(req.body);
        const savedExpense = (yield expenseRepository.save(expense));
        const message = `La dépense a bien été enregistrée.`;
        return (0, response_1.success)(res, 201, savedExpense, message);
    }
    catch (error) {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Les données de la dépense sont invalides.');
        }
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La dépense n'a pas pu être ajoutée. Réessayez dans quelques instants.");
    }
});
exports.createExpense = createExpense;
// ====================== GET ALL ======================
const getAllExpenses = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const expenses = yield data_source_1.myDataSource.getRepository(expense_entity_1.Expense).find({
            relations: ['category'],
            order: { date: 'DESC' }
        });
        const message = 'La liste des dépenses a bien été récupérée.';
        return (0, response_1.success)(res, 200, expenses, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La liste des dépenses n'a pas pu être récupérée. Réessayez dans quelques instants.");
    }
});
exports.getAllExpenses = getAllExpenses;
// ====================== PAGINATED ======================
const getExpensesPaginated = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { limit, searchTerm, startIndex } = (0, paginationAndRechercheInit_1.paginationAndRechercheInit)(req, expense_entity_1.Expense);
        let query = data_source_1.myDataSource
            .getRepository(expense_entity_1.Expense)
            .createQueryBuilder('e')
            .leftJoinAndSelect('e.category', 'category');
        if (searchTerm) {
            query = query.where('( e.title ILIKE :keyword OR e.description ILIKE :keyword OR category.name ILIKE :keyword )', { keyword: `%${searchTerm}%` });
        }
        const [data, totalElements] = yield query
            .orderBy('e.date', 'DESC')
            .skip(startIndex)
            .take(limit)
            .getManyAndCount();
        const totalPages = Math.ceil(totalElements / limit);
        const message = 'La liste des dépenses a bien été récupérée.';
        return (0, response_1.success)(res, 200, { data, totalPages, totalElements, limit }, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, 'Erreur lors de la récupération des dépenses.');
    }
});
exports.getExpensesPaginated = getExpensesPaginated;
// ====================== GET BY ID ======================
const getExpenseById = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const expense = yield data_source_1.myDataSource.getRepository(expense_entity_1.Expense).findOne({
            where: { id: id },
            relations: ['category']
        });
        if (!expense) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "La dépense demandée n'existe pas.");
        }
        const message = 'La dépense a bien été trouvée.';
        return (0, response_1.success)(res, 200, expense, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La dépense n'a pas pu être récupérée. Réessayez dans quelques instants.");
    }
});
exports.getExpenseById = getExpenseById;
// ====================== UPDATE ======================
const updateExpense = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const expenseRepository = data_source_1.myDataSource.getRepository(expense_entity_1.Expense);
        const expense = yield expenseRepository.findOne({
            where: { id: id }
        });
        if (!expense) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "Cette dépense n'existe pas.");
        }
        expenseRepository.merge(expense, req.body);
        const updatedExpense = yield expenseRepository.save(expense);
        const message = `La dépense a bien été modifiée.`;
        return (0, response_1.success)(res, 200, updatedExpense, message);
    }
    catch (error) {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Les données sont invalides.');
        }
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La dépense n'a pas pu être modifiée. Réessayez dans quelques instants.");
    }
});
exports.updateExpense = updateExpense;
// ====================== DELETE ======================
const deleteExpense = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const expenseRepository = data_source_1.myDataSource.getRepository(expense_entity_1.Expense);
        const expense = yield expenseRepository.findOne({
            where: { id: id }
        });
        if (!expense) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "La dépense demandée n'existe pas.");
        }
        const hasRelations = yield (0, checkRelationsOneToManyBeforDelete_1.checkRelationsOneToMany)('Expense', id);
        if (hasRelations) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'Relations existantes', "Cette dépense est liée à d'autres enregistrements et ne peut pas être supprimée.");
        }
        yield expenseRepository.remove(expense);
        const message = `La dépense a bien été supprimée.`;
        return (0, response_1.success)(res, 200, expense, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La dépense n'a pas pu être supprimée. Réessayez dans quelques instants.");
    }
});
exports.deleteExpense = deleteExpense;
