import 'package:dio/dio.dart';
import 'package:senafinance/core/network/dio_client.dart';

class TransactionService {
  final Dio _dio = DioClient().dio;

  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final response = await _dio.get('/transactions/all');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> getTransactionById(String id) async {
    try {
      final response = await _dio.get('/transactions/$id');
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> createTransaction(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post('/transactions', data: data);
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> updateTransaction(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/transactions/$id', data: data);
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _dio.delete('/transactions/$id');
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }
}