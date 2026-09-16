import 'dart:convert';
import 'package:app_expenses/core/app_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  /// Ajustement automatique selon la plateforme sans crash sur le Web
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://localhost:3005/api'; // Émulateur Android
    }
    return 'http://localhost:3005/api'; // iOS, Web ou Desktop
  }

  // static const String _tokenKey = 'auth_token';
  static const String _tokenKey = AppConstants.tokenKey;
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey = 'user_id';

  /// Configuration du stockage sécurisé avec support Web
  final storage = const FlutterSecureStorage(
    webOptions: WebOptions(dbName: 'ExpenseApp', publicKey: 'ExpenseAppKey'),
  );

  /// Stocke l'ID, le nom et l'email de l'utilisateur
  Future<void> saveUserData(String? id, String? name, String? email) async {
    if (id != null) await storage.write(key: _userIdKey, value: id.toString());
    if (name != null) await storage.write(key: _userNameKey, value: name);
    if (email != null) await storage.write(key: _userEmailKey, value: email);
  }

  /// Récupérer l'ID utilisateur
  Future<String?> getUserId() async {
    return await storage.read(key: _userIdKey);
  }

  /// Récupère le nom d'affichage
  Future<String?> getUserName() async {
    return await storage.read(key: _userNameKey);
  }

  /// Récupère l'adresse email
  Future<String?> getUserEmail() async {
    return await storage.read(key: _userEmailKey);
  }

  /// Inscription (Register)
  Future<Map<String, dynamic>> register(
    String nom,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nom': nom, 'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final userData = data['data']?['user'] ?? data['user'];
      // final userData = data['data'] ?? data['user'];
      if (userData != null) {
        await saveUserData(
          userData['id']?.toString() ?? userData['_id']?.toString(),
          userData['nom'],
          userData['email'],
        );
      }
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur lors de l\'inscription');
    }
  }

  /// Connexion (Login)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final token =
          data['token'] ?? data['accessToken'] ?? data['data']?['token'];
      if (token != null) {
        await saveToken(token);
      }

      final userData = data['data']?['user'] ?? data['user'];
      // final userData = data['data'] ?? data['user'];
      if (userData != null) {
        await saveUserData(
          userData['id']?.toString() ?? userData['_id']?.toString(),
          userData['nom'],
          userData['email'],
        );
      }
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur de connexion');
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await clearToken();
  }

  /// Vérifie si l'utilisateur est connecté
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Récupère le token stocké
  Future<String?> getToken() async {
    return await storage.read(key: _tokenKey);
  }

  /// Sauvegarde le token
  Future<void> saveToken(String token) async {
    await storage.write(key: _tokenKey, value: token);
  }

  /// Supprime le token et les infos utilisateur
  Future<void> clearToken() async {
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _userNameKey);
    await storage.delete(key: _userEmailKey);
    await storage.delete(key: _userIdKey);
  }
}