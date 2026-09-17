"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.budgetRoutes = void 0;
const budget_controller_1 = require("../controller/budget.controller");
const budgetRoutes = (router) => {
    // Collection & Création
    router.post('/api/budgets', budget_controller_1.createBudget);
    router.get('/api/budgets/all', budget_controller_1.getAllBudgets);
    router.get('/api/budgets', budget_controller_1.getBudgetsPaginated);
    // Éléments individuels
    router.get('/api/budgets/:id', budget_controller_1.getBudgetById);
    router.put('/api/budgets/:id', budget_controller_1.updateBudget);
    router.delete('/api/budgets/:id', budget_controller_1.deleteBudget);
};
exports.budgetRoutes = budgetRoutes;
