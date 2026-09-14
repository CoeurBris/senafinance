import { Router } from 'express';
import { getDashboardData } from '../controller/dashboard.controller';

export const dashboardRoutes = (router: Router) => {
  router.get('/api/dashboard', getDashboardData);
};