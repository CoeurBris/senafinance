import { Router } from 'express';
import {
  createExpense,
  deleteExpense,
  getAllExpenses,
  getExpenseById,
  getExpensesPaginated,
  updateExpense,
} from '../controller/expense.controller';

export const expenseRoutes = (router: Router) => {
  // Collection & Création
  router.post('/api/expenses', createExpense);
  router.get('/api/expenses/all', getAllExpenses);
  router.get('/api/expenses', getExpensesPaginated);

  // Éléments individuels
  router.get('/api/expenses/:id', getExpenseById);
  router.put('/api/expenses/:id', updateExpense);
  router.delete('/api/expenses/:id', deleteExpense);
};