import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();

  /// Génère les en-têtes HTTP requis avec le token JWT
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();

    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Requête GET sécurisée
  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  /// Requête POST sécurisée
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await _authService.getToken();

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// Requête PUT générique avec insertion automatique du Token JWT
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await _authService.getToken();

    final response = await http.put(
      Uri.parse('${AuthService.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// Upload de la photo de profil
  ///
  /// Endpoint backend :
  /// POST /api/users/photo
  ///
  /// Champ multipart :
  /// photo
  Future<Map<String, dynamic>> uploadAvatar(File file) async {
    try {
      final token = await _authService.getToken();

      final uri = Uri.parse(
        '${AuthService.baseUrl}/api/users/photo',
      );

      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      // Token JWT
      if (token != null) {
        request.headers['Authorization'] =
            'Bearer $token';
      }

      request.headers['Accept'] =
          'application/json';

      // Ajout de l'image
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          file.path,
          filename: file.path
              .split(Platform.pathSeparator)
              .last,
        ),
      );

      final streamedResponse =
          await request.send();

      final response =
          await http.Response.fromStream(
        streamedResponse,
      );

      final data = _decodeResponse(response);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return Map<String, dynamic>.from(data);
      }

      if (response.statusCode == 401) {
        await _authService.logout();

        throw Exception(
          'Session expirée. Veuillez vous reconnecter.',
        );
      }

      throw Exception(
        data['message'] ??
            "La photo n'a pas pu être mise à jour.",
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        "Erreur lors de l'envoi de la photo.",
      );
    }
  }

  /// Récupère les données du Dashboard
  Future<Map<String, dynamic>>
      fetchDashboardData() async {
    try {
      final response = await get('/dashboard');

      return Map<String, dynamic>.from(response);
    } catch (e) {
      // Données de secours uniquement pour permettre
      // à l'interface de rester fonctionnelle.
      //
      // Tu peux supprimer ce fallback lorsque ton
      // endpoint /dashboard sera complètement fonctionnel.
      return {
        'total_budget': 500000.0,
        'total_expenses': 215000.0,
        'remaining_budget': 285000.0,
        'recent_expenses': [
          {
            'title': 'Courses Alimentaires',
            'amount': 25000,
            'category': 'Alimentation',
            'date': '2026-08-18',
          },
          {
            'title': 'Carburant',
            'amount': 15000,
            'category': 'Transport',
            'date': '2026-08-17',
          },
          {
            'title': 'Abonnement Internet',
            'amount': 30000,
            'category': 'Abonnements',
            'date': '2026-08-15',
          },
        ],
        'user': {
          'id': null,
          'name': 'Utilisateur',
          'email': 'inconnu',
          'photo_url': null,
        },
      };
    }
  }

  /// Décode la réponse JSON
  dynamic _decodeResponse(
    http.Response response,
  ) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {
        'message': response.body,
      };
    }
  }

  /// Traitement des réponses HTTP
  dynamic _handleResponse(
    http.Response response,
  ) {
    final data = _decodeResponse(response);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    if (response.statusCode == 401) {
      _authService.logout();

      throw Exception(
        'Session expirée. Veuillez vous reconnecter.',
      );
    }

    if (data is Map &&
        data['message'] != null) {
      throw Exception(
        data['message'].toString(),
      );
    }

    throw Exception(
      'Erreur lors de la requête (${response.statusCode}).',
    );
  }
}