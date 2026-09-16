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
exports.deleteCategory = exports.updateCategory = exports.getCategoryById = exports.getCategoriesPaginated = exports.getAllCategories = exports.createCategory = void 0;
const class_validator_1 = require("class-validator");
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const checkRelationsOneToManyBeforDelete_1 = require("../../../configs/checkRelationsOneToManyBeforDelete");
const paginationAndRechercheInit_1 = require("../../../configs/paginationAndRechercheInit");
const category_entity_1 = require("../entity/category.entity");
// ====================== CREATE ======================
const createCategory = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const categoryRepository = data_source_1.myDataSource.getRepository(category_entity_1.Category);
        const category = categoryRepository.create(req.body);
        const savedCategory = (yield categoryRepository.save(category));
        const message = `La catégorie "${savedCategory.name}" a bien été créée.`;
        return (0, response_1.success)(res, 201, savedCategory, message);
    }
    catch (error) {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Les données de la catégorie sont invalides.');
        }
        if (error.code === 'ER_DUP_ENTRY' || error.code === '23505') {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Une catégorie avec ce nom existe déjà.');
        }
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La catégorie n'a pas pu être ajoutée. Réessayez dans quelques instants.");
    }
});
exports.createCategory = createCategory;
// ====================== GET ALL ======================
const getAllCategories = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const categories = yield data_source_1.myDataSource.getRepository(category_entity_1.Category).find({
            order: { name: 'ASC' },
        });
        const message = 'La liste des catégories a bien été récupérée.';
        return (0, response_1.success)(res, 200, categories, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La liste des catégories n'a pas pu être récupérée. Réessayez dans quelques instants.");
    }
});
exports.getAllCategories = getAllCategories;
// ====================== PAGINATED ======================
const getCategoriesPaginated = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { limit, searchTerm, startIndex } = (0, paginationAndRechercheInit_1.paginationAndRechercheInit)(req, category_entity_1.Category);
        let query = data_source_1.myDataSource
            .getRepository(category_entity_1.Category)
            .createQueryBuilder('c');
        if (searchTerm) {
            query = query.where('( c.name ILIKE :keyword OR c.description ILIKE :keyword )', { keyword: `%${searchTerm}%` });
        }
        const [data, totalElements] = yield query
            .orderBy('c.id', 'DESC')
            .skip(startIndex)
            .take(limit)
            .getManyAndCount();
        const totalPages = Math.ceil(totalElements / limit);
        const message = 'La liste des catégories a bien été récupérée.';
        return (0, response_1.success)(res, 200, { data, totalPages, totalElements, limit }, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "Erreur lors de la récupération paginée des catégories.");
    }
});
exports.getCategoriesPaginated = getCategoriesPaginated;
// ====================== GET BY ID ======================
const getCategoryById = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const category = yield data_source_1.myDataSource.getRepository(category_entity_1.Category).findOne({
            where: { id: id },
        });
        if (!category) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "La catégorie demandée n'existe pas.");
        }
        const message = 'La catégorie a bien été trouvée.';
        return (0, response_1.success)(res, 200, category, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La catégorie n'a pas pu être récupérée. Réessayez dans quelques instants.");
    }
});
exports.getCategoryById = getCategoryById;
// ====================== UPDATE ======================
const updateCategory = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const categoryRepository = data_source_1.myDataSource.getRepository(category_entity_1.Category);
        const category = yield categoryRepository.findOne({
            where: { id: id },
        });
        if (!category) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "Cette catégorie n'existe pas.");
        }
        categoryRepository.merge(category, req.body);
        const updatedCategory = yield categoryRepository.save(category);
        const message = `La catégorie "${updatedCategory.name}" a bien été modifiée.`;
        return (0, response_1.success)(res, 200, updatedCategory, message);
    }
    catch (error) {
        if (error instanceof class_validator_1.ValidationError ||
            error.code === 'ER_DUP_ENTRY' ||
            error.code === '23505') {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Une catégorie avec ce nom existe déjà.');
        }
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La catégorie n'a pas pu être modifiée. Réessayez dans quelques instants.");
    }
});
exports.updateCategory = updateCategory;
// ====================== DELETE ======================
const deleteCategory = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const id = req.params.id;
        const categoryRepository = data_source_1.myDataSource.getRepository(category_entity_1.Category);
        const category = yield categoryRepository.findOne({
            where: { id: id },
        });
        if (!category) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "La catégorie demandée n'existe pas.");
        }
        const hasRelations = yield (0, checkRelationsOneToManyBeforDelete_1.checkRelationsOneToMany)('Category', id);
        if (hasRelations) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'Relations existantes', 'La catégorie est liée à des dépenses et ne peut pas être supprimée.');
        }
        yield categoryRepository.remove(category);
        const message = `La catégorie "${category.name}" a bien été supprimée.`;
        return (0, response_1.success)(res, 200, category, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La catégorie n'a pas pu être supprimée. Réessayez dans quelques instants.");
    }
});
exports.deleteCategory = deleteCategory;
