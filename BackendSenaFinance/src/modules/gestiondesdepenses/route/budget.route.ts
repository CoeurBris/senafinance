import { Router } from 'express';
import {
  createBudget,
  deleteBudget,
  getAllBudgets,
  getBudgetById,
  getBudgetsPaginated,
  updateBudget,
} from '../controller/budget.controller';

export const budgetRoutes = (router: Router) => {
  // Collection & Création
  router.post('/api/budgets', createBudget);
  router.get('/api/budgets/all', getAllBudgets);
  router.get('/api/budgets', getBudgetsPaginated);

  // Éléments individuels
  router.get('/api/budgets/:id', getBudgetById);
  router.put('/api/budgets/:id', updateBudget);
  router.delete('/api/budgets/:id', deleteBudget);
};