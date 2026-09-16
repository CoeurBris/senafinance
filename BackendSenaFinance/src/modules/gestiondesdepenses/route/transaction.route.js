"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.transactionRoutes = void 0;
const transaction_controller_1 = require("../controller/transaction.controller");
const transactionRoutes = (router) => {
    // Collection & Création
    router.post('/api/transactions', transaction_controller_1.createTransaction);
    router.get('/api/transactions/all', transaction_controller_1.getAllTransactions);
    router.get('/api/transactions', transaction_controller_1.getTransactionsPaginated);
    // Éléments individuels
    router.get('/api/transactions/:id', transaction_controller_1.getTransactionById);
    router.put('/api/transactions/:id', transaction_controller_1.updateTransaction);
    router.delete('/api/transactions/:id', transaction_controller_1.deleteTransaction);
};
exports.transactionRoutes = transactionRoutes;
