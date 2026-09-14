import { Router } from 'express';
import {
  createTransaction,
  deleteTransaction,
  getAllTransactions,
  getTransactionById,
  getTransactionsPaginated,
  updateTransaction,
} from '../controller/transaction.controller';

export const transactionRoutes = (router: Router) => {
  // Collection & Création
  router.post('/api/transactions', createTransaction);
  router.get('/api/transactions/all', getAllTransactions);
  router.get('/api/transactions', getTransactionsPaginated);

  // Éléments individuels
  router.get('/api/transactions/:id', getTransactionById);
  router.put('/api/transactions/:id', updateTransaction);
  router.delete('/api/transactions/:id', deleteTransaction);
};