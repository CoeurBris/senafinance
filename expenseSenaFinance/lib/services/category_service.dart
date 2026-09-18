import 'package:dio/dio.dart';
import 'package:senafinance/core/network/dio_client.dart';

class CategoryService {
  final Dio _dio = DioClient().dio;

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _dio.get('/categories/all');
      return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> getCategoryById(String id) async {
    try {
      final response = await _dio.get('/categories/$id');
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/categories', data: data);
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/categories/$id', data: data);
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _dio.delete('/categories/$id');
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }
}