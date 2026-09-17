"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.categoryRoutes = void 0;
const category_controller_1 = require("../controller/category.controller");
const categoryRoutes = (router) => {
    // Collection & Création
    router.post('/api/categories', category_controller_1.createCategory);
    router.get('/api/categories/all', category_controller_1.getAllCategories);
    router.get('/api/categories', category_controller_1.getCategoriesPaginated);
    // Éléments individuels
    router.get('/api/categories/:id', category_controller_1.getCategoryById);
    router.put('/api/categories/:id', category_controller_1.updateCategory);
    router.delete('/api/categories/:id', category_controller_1.deleteCategory);
};
exports.categoryRoutes = categoryRoutes;
