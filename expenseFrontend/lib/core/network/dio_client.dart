import 'package:app_expenses/core/app_constant.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();

  late final Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();

          final token = prefs.getString(AppConstants.tokenKey);

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          debugPrint(
            'REQUEST: ${options.method} ${options.uri}',
          );

          handler.next(options);
        },

        onResponse: (response, handler) {
          debugPrint(
            'RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
          );

          handler.next(response);
        },

        onError: (DioException error, handler) {
          debugPrint(
            'DIO ERROR: ${error.requestOptions.uri}',
          );

          handler.next(error);
        },
      ),
    );
  }

  static String extractMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final message = data['message'];

        if (message != null) {
          return message.toString();
        }

        final errors = data['errors'];

        if (errors is String) {
          return errors;
        }
      }

      if (error.type == DioExceptionType.connectionTimeout) {
        return 'Le serveur met trop de temps à répondre.';
      }

      if (error.type == DioExceptionType.receiveTimeout) {
        return 'Le serveur met trop de temps à envoyer la réponse.';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Impossible de contacter le serveur.';
      }

      return 'Une erreur est survenue.';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}