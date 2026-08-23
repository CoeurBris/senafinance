import 'package:app_expenses/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class BudgetService {
  final Dio _dio = DioClient().dio;

  /// Récupérer tous les budgets de l'utilisateur connecté
  Future<List<dynamic>> getBudgets() async {
    try {
      final response = await _dio.get('/budgets');

      return List<dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  /// Récupérer un budget par son ID
  Future<Map<String, dynamic>> getBudgetById(String id) async {
    try {
      final response = await _dio.get('/budgets/$id');

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  /// Créer un nouveau budget
  Future<Map<String, dynamic>> createBudget(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(
        '/budgets',
        data: data,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  /// Modifier un budget
  Future<Map<String, dynamic>> updateBudget(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        '/budgets/$id',
        data: data,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  /// Supprimer un budget
  Future<void> deleteBudget(String id) async {
    try {
      await _dio.delete('/budgets/$id');
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }
}