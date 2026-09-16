import 'package:app_expenses/models/notification_model.dart';
import 'package:app_expenses/services/notification_service.dart';


class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository({
    NotificationService? notificationService,
  }) : _notificationService =
            notificationService ?? NotificationService();

  /// Récupérer toutes les notifications
  Future<List<NotificationModel>> getNotifications() async {
    final data = await _notificationService.getNotifications();

    return data
        .map(
          (json) => NotificationModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  /// Récupérer une notification
  Future<NotificationModel> getNotificationById(String id) async {
    final data = await _notificationService.getNotificationById(id);
    return NotificationModel.fromJson(data);
  }

  /// Marquer une notification comme lue
  Future<NotificationModel> markAsRead(String id) async {
    final data = await _notificationService.markAsRead(id);
    return NotificationModel.fromJson(data);
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String id) async {
    await _notificationService.deleteNotification(id);
  }
}