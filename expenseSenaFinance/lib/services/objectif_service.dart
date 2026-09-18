import 'package:dio/dio.dart';
import 'package:senafinance/core/network/dio_client.dart';

class ObjectifService {
  final Dio _dio = DioClient().dio;

  Future<List<Map<String, dynamic>>> getObjectifs() async {
    try {
      final response = await _dio.get('/objectifs/all');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> createObjectif(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/objectifs', data: data);
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> updateObjectif(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/objectifs/$id', data: data);
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  /// Endpoint dédié : ajoute un montant au fonds sans toucher au reste de l'objectif
  Future<Map<String, dynamic>> addMontant(String id, double amount) async {
    try {
      final response = await _dio.patch(
        '/objectifs/$id/montant',
        data: {'amount': amount},
      );
      return Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<List<Map<String, dynamic>>> getVersements(String objectifId) async {
    try {
      final response = await _dio.get('/objectifs/$objectifId/versements');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }

  Future<void> deleteObjectif(String id) async {
    try {
      await _dio.delete('/objectifs/$id');
    } on DioException catch (e) {
      throw Exception(DioClient.extractMessage(e));
    }
  }
}
