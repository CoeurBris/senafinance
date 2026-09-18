import 'package:dio/dio.dart';
import 'package:senafinance/core/network/dio_client.dart';

class BudgetService {
  final Dio _dio = DioClient().dio;

  Future<List<Map<String, dynamic>>> getBudgets() async {
    try {
      final response = await _dio.get('/budgets/all');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> getBudgetById(String id) async {
    try {
      final response = await _dio.get('/budgets/$id');
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> createBudget(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/budgets', data: data);
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> updateBudget(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/budgets/$id', data: data);
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _dio.delete('/budgets/$id');
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }
}
