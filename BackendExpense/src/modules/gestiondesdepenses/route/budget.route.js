"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.budgetRoutes = void 0;
const budget_controller_1 = require("../controller/budget.controller");
const budgetRoutes = (router) => {
    // Collection & Création
    router.post('/budgets', budget_controller_1.createBudget);
    router.get('/budgets/all', budget_controller_1.getAllBudgets);
    router.get('/budgets', budget_controller_1.getBudgetsPaginated);
    // Éléments individuels
    router.get('/budgets/:id', budget_controller_1.getBudgetById);
    router.put('/budgets/:id', budget_controller_1.updateBudget);
    router.delete('/budgets/:id', budget_controller_1.deleteBudget);
};
exports.budgetRoutes = budgetRoutes;
