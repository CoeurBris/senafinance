"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.expenseRoutes = void 0;
const expense_controller_1 = require("../controller/expense.controller");
const expenseRoutes = (router) => {
    // Collection & Création
    router.post('/expenses', expense_controller_1.createExpense);
    router.get('/expenses/all', expense_controller_1.getAllExpenses);
    router.get('/expenses', expense_controller_1.getExpensesPaginated);
    // Éléments individuels
    router.get('/expenses/:id', expense_controller_1.getExpenseById);
    router.put('/expenses/:id', expense_controller_1.updateExpense);
    router.delete('/expenses/:id', expense_controller_1.deleteExpense);
};
exports.expenseRoutes = expenseRoutes;
