
import 'package:flutter/foundation.dart';
import 'package:senafinance/models/notification_model.dart';
import 'package:senafinance/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationProvider({
    NotificationRepository? repository,
  }) : _repository =
            repository ?? NotificationRepository();

  List<NotificationModel> _notifications = [];

  bool _isLoading = false;

  String? _error;

  NotificationModel? _selectedNotification;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  bool get isLoading => _isLoading;

  String? get error => _error;

  NotificationModel? get selectedNotification =>
      _selectedNotification;

  /// Nombre total de notifications
  int get notificationCount =>
      _notifications.length;

  /// Nombre de notifications non lues
  int get unreadCount {
    return _notifications
        .where((notification) => !notification.isRead)
        .length;
  }

  /// Charger toutes les notifications
  Future<void> loadNotifications() async {
    _setLoading(true);
    _error = null;

    try {
      _notifications =
          await _repository.getNotifications();
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );
    } finally {
      _setLoading(false);
    }
  }

   /// Récupérer une notification
  Future<NotificationModel?> loadNotificationById(
    String id,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final notification =
          await _repository.getNotificationById(id);

      _selectedNotification = notification;

      return notification;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }

   /// Marquer une notification comme lue
  Future<bool> markAsRead(
    String id,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedNotification =
          await _repository.markAsRead(id);

      final index = _notifications.indexWhere(
        (notification) => notification.id == id,
      );

      if (index != -1) {
        _notifications[index] = updatedNotification;
      }

      if (_selectedNotification?.id == id) {
        _selectedNotification = updatedNotification;
      }

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.markAllAsRead();

      _notifications = _notifications
          .map(
            (notification) =>
                notification.copyWith(isRead: true),
          )
          .toList();

      if (_selectedNotification != null) {
        _selectedNotification =
            _selectedNotification!.copyWith(
          isRead: true,
        );
      }

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      return false;
    } finally {
      _setLoading(false);
    }
  }

   /// Supprimer une notification
  Future<bool> deleteNotification(
    String id,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.deleteNotification(id);

      _notifications.removeWhere(
        (notification) => notification.id == id,
      );

      if (_selectedNotification?.id == id) {
        _selectedNotification = null;
      }

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sélectionner une notification
  void selectNotification(
    NotificationModel? notification,
  ) {
    _selectedNotification = notification;
    notifyListeners();
  }

  /// Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}