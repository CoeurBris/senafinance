import { Router } from 'express';
import {
  createNotification,
  deleteNotification,
  getAllNotifications,
  getNotificationById,
  getNotificationsPaginated,
  markAllNotificationsAsRead,
  markNotificationAsRead,
  updateNotification,
} from '../controller/notification.controller';

export const notificationRoutes = (router: Router) => {
  // Collection & Création
  router.post('/api/notifications', createNotification);
  router.get('/api/notifications/all', getAllNotifications);
  router.get('/api/notifications', getNotificationsPaginated);

  // Éléments individuels
  router.get('/api/notifications/:id', getNotificationById);
  router.put('/api/notifications/:id', updateNotification);
  router.delete('/api/notifications/:id', deleteNotification);

  router.patch('/api/notifications/read-all', markAllNotificationsAsRead);
  router.patch('/api/notifications/:id/read', markNotificationAsRead);
};