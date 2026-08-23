"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.categoryRoutes = void 0;
const category_controller_1 = require("../controller/category.controller");
const categoryRoutes = (router) => {
    // Collection & Création
    router.post('/categories', category_controller_1.createCategory);
    router.get('/categories/all', category_controller_1.getAllCategories);
    router.get('/categories', category_controller_1.getCategoriesPaginated);
    // Éléments individuels
    router.get('/categories/:id', category_controller_1.getCategoryById);
    router.put('/categories/:id', category_controller_1.updateCategory);
    router.delete('/categories/:id', category_controller_1.deleteCategory);
};
exports.categoryRoutes = categoryRoutes;
