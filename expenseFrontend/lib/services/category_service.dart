import 'package:app_expenses/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class CategoryService {
  final Dio _dio = DioClient().dio;

  /// Récupérer toutes les catégories
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _dio.get('/categories');

      return List<dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  /// Récupérer une catégorie par son ID
  Future<Map<String, dynamic>> getCategoryById(String id) async {
    try {
      final response = await _dio.get('/categories/$id');

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  /// Créer une catégorie
  Future<Map<String, dynamic>> createCategory(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(
        '/categories',
        data: data,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  /// Modifier une catégorie
  Future<Map<String, dynamic>> updateCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        '/categories/$id',
        data: data,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  /// Supprimer une catégorie
  Future<void> deleteCategory(String id) async {
    try {
      await _dio.delete('/categories/$id');
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }
}