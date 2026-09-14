import 'package:app_expenses/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class NotificationService {
  final Dio _dio = DioClient().dio;

  /// Récupérer les notifications de l'utilisateur connecté
  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications/all');
      final data = response.data['data'] ?? response.data;
      return List<dynamic>.from(data);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  /// Récupérer une notification par son ID
  Future<Map<String, dynamic>> getNotificationById(String id) async {
    try {
      final response = await _dio.get('/notifications/$id');

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  /// Marquer une notification comme lue
  Future<Map<String, dynamic>> markAsRead(String id) async {
    try {
      final response = await _dio.patch(
        '/notifications/$id/read',
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/notifications/read-all');
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete('/notifications/$id');
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }
}