"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteNotification = exports.updateNotification = exports.getNotificationById = exports.getNotificationsPaginated = exports.markAllNotificationsAsRead = exports.markNotificationAsRead = exports.getAllNotifications = exports.createNotification = void 0;
const class_validator_1 = require("class-validator");
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const checkRelationsOneToManyBeforDelete_1 = require("../../../configs/checkRelationsOneToManyBeforDelete");
const paginationAndRechercheInit_1 = require("../../../configs/paginationAndRechercheInit");
const notification_entity_1 = require("../entity/notification.entity");
// ====================== CREATE ======================
const createNotification = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const notificationRepo = data_source_1.myDataSource.getRepository(notification_entity_1.Notification);
        const notification = notificationRepo.create(req.body);
        const savedNotification = (yield notificationRepo.save(notification));
        const message = `La notification "${savedNotification.title || 'nouvelle'}" a bien été créée.`;
        return (0, response_1.success)(res, 201, savedNotification, message);
    }
    catch (error) {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Les données de la notification sont invalides.');
        }
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La notification n'a pas pu être ajoutée. Réessayez dans quelques instants.");
    }
});
exports.createNotification = createNotification;
// ====================== GET ALL ======================
// GET ALL — filtré par utilisateur connecté
const getAllNotifications = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id; // adapte selon ton middleware d'auth
        const notifications = yield data_source_1.myDataSource.getRepository(notification_entity_1.Notification).find({
            where: { userId },
            relations: ['relatedExpense'],
            order: { createdAt: 'DESC' },
        });
        return (0, response_1.success)(res, 200, notifications, 'La liste des notifications a bien été récupérée.');
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La liste des notifications n'a pas pu être récupérée.");
    }
});
exports.getAllNotifications = getAllNotifications;
// PATCH /:id/read
const markNotificationAsRead = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const notificationRepo = data_source_1.myDataSource.getRepository(notification_entity_1.Notification);
        const notification = yield notificationRepo.findOne({ where: { id: id } });
        if (!notification) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "Cette notification n'existe pas.");
        }
        notification.isRead = true;
        const updated = yield notificationRepo.save(notification);
        return (0, response_1.success)(res, 200, updated, 'Notification marquée comme lue.');
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "Erreur lors de la mise à jour.");
    }
});
exports.markNotificationAsRead = markNotificationAsRead;
// PATCH /read-all
const markAllNotificationsAsRead = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
        yield data_source_1.myDataSource.getRepository(notification_entity_1.Notification).update({ userId }, { isRead: true });
        return (0, response_1.success)(res, 200, null, 'Toutes les notifications ont été marquées comme lues.');
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "Erreur lors de la mise à jour.");
    }
});
exports.markAllNotificationsAsRead = markAllNotificationsAsRead;
// ====================== PAGINATED ======================
const getNotificationsPaginated = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { limit, searchTerm, startIndex } = (0, paginationAndRechercheInit_1.paginationAndRechercheInit)(req, notification_entity_1.Notification);
        let query = data_source_1.myDataSource
            .getRepository(notification_entity_1.Notification)
            .createQueryBuilder('n')
            .leftJoinAndSelect('n.relatedExpense', 'expense');
        if (searchTerm) {
            query = query.where('( n.title ILIKE :keyword OR n.body ILIKE :keyword )', { keyword: `%${searchTerm}%` });
        }
        const [data, totalElements] = yield query
            .orderBy('n.createdAt', 'DESC')
            .skip(startIndex)
            .take(limit)
            .getManyAndCount();
        const totalPages = Math.ceil(totalElements / limit);
        const message = 'La liste des notifications a bien été récupérée.';
        return (0, response_1.success)(res, 200, { data, totalPages, totalElements, limit }, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "Erreur lors de la récupération des notifications.");
    }
});
exports.getNotificationsPaginated = getNotificationsPaginated;
// ====================== GET BY ID ======================
const getNotificationById = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const notification = yield data_source_1.myDataSource.getRepository(notification_entity_1.Notification).findOne({
            where: { id: id },
            relations: ['relatedExpense'],
        });
        if (!notification) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "La notification demandée n'existe pas.");
        }
        const message = 'La notification a bien été trouvée.';
        return (0, response_1.success)(res, 200, notification, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La notification n'a pas pu être récupérée. Réessayez dans quelques instants.");
    }
});
exports.getNotificationById = getNotificationById;
// ====================== UPDATE ======================
const updateNotification = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const notificationRepo = data_source_1.myDataSource.getRepository(notification_entity_1.Notification);
        const notification = yield notificationRepo.findOne({
            where: { id: id },
        });
        if (!notification) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "Cette notification n'existe pas.");
        }
        notificationRepo.merge(notification, req.body);
        const updated = yield notificationRepo.save(notification);
        const message = 'La notification a bien été modifiée.';
        return (0, response_1.success)(res, 200, updated, message);
    }
    catch (error) {
        if (error instanceof class_validator_1.ValidationError) {
            return (0, response_1.generateServerErrorCode)(res, 400, error, 'Les données fournies sont invalides.');
        }
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La notification n'a pas pu être modifiée. Réessayez dans quelques instants.");
    }
});
exports.updateNotification = updateNotification;
// ====================== DELETE ======================
const deleteNotification = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const notificationRepo = data_source_1.myDataSource.getRepository(notification_entity_1.Notification);
        const notification = yield notificationRepo.findOne({
            where: { id: id },
        });
        if (!notification) {
            return (0, response_1.generateServerErrorCode)(res, 404, "L'ID n'existe pas", "La notification demandée n'existe pas.");
        }
        const hasRelations = yield (0, checkRelationsOneToManyBeforDelete_1.checkRelationsOneToMany)('Notification', id);
        if (hasRelations) {
            return (0, response_1.generateServerErrorCode)(res, 400, 'Relations existantes', 'Cette notification est liée à d\'autres enregistrements et ne peut pas être supprimée.');
        }
        yield notificationRepo.remove(notification);
        const message = 'La notification a bien été supprimée.';
        return (0, response_1.success)(res, 200, notification, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "La notification n'a pas pu être supprimée. Réessayez dans quelques instants.");
    }
});
exports.deleteNotification = deleteNotification;
