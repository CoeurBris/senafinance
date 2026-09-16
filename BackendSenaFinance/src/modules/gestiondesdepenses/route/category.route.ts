import { Router } from 'express';
import {
  createCategory,
  deleteCategory,
  getAllCategories,
  getCategoriesPaginated,
  getCategoryById,
  updateCategory,
} from '../controller/category.controller';

export const categoryRoutes = (router: Router) => {
  // Collection & Création
  router.post('/api/categories', createCategory);
  router.get('/api/categories/all', getAllCategories);
  router.get('/api/categories', getCategoriesPaginated);

  // Éléments individuels
  router.get('/api/categories/:id', getCategoryById);
  router.put('/api/categories/:id', updateCategory);
  router.delete('/api/categories/:id', deleteCategory);
};