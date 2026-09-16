import 'package:app_expenses/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class ExpenseService {
  final Dio _dio = DioClient().dio;

  Future<List<Map<String, dynamic>>> getExpenses() async {
    try {
      final response = await _dio.get('/expenses/all');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> getExpenseById(String id) async {
    try {
      final response = await _dio.get('/expenses/$id');
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/expenses', data: data);
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> updateExpense(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/expenses/$id', data: data);
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _dio.delete('/expenses/$id');
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }
}