"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.notificationRoutes = void 0;
const notification_controller_1 = require("../controller/notification.controller");
const notificationRoutes = (router) => {
    // Collection & Création
    router.post('/api/notifications', notification_controller_1.createNotification);
    router.get('/api/notifications/all', notification_controller_1.getAllNotifications);
    router.get('/api/notifications', notification_controller_1.getNotificationsPaginated);
    // Éléments individuels
    router.get('/api/notifications/:id', notification_controller_1.getNotificationById);
    router.put('/api/notifications/:id', notification_controller_1.updateNotification);
    router.delete('/api/notifications/:id', notification_controller_1.deleteNotification);
    router.patch('/api/notifications/read-all', notification_controller_1.markAllNotificationsAsRead);
    router.patch('/api/notifications/:id/read', notification_controller_1.markNotificationAsRead);
};
exports.notificationRoutes = notificationRoutes;
