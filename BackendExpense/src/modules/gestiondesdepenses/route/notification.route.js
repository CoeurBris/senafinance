"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.notificationRoutes = void 0;
const notification_controller_1 = require("../controller/notification.controller");
const notificationRoutes = (router) => {
    // Collection & Création
    router.post('/notifications', notification_controller_1.createNotification);
    router.get('/notifications/all', notification_controller_1.getAllNotifications);
    router.get('/notifications', notification_controller_1.getNotificationsPaginated);
    // Éléments individuels
    router.get('/notifications/:id', notification_controller_1.getNotificationById);
    router.put('/notifications/:id', notification_controller_1.updateNotification);
    router.delete('/notifications/:id', notification_controller_1.deleteNotification);
};
exports.notificationRoutes = notificationRoutes;
