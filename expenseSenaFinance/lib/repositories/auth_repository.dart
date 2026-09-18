



import 'package:senafinance/models/user_model.dart';
import 'package:senafinance/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({
    AuthService? authService,
  }) : _authService = authService ?? AuthService();

  /// Connexion
  Future<User> login(
    String email,
    String motDePasse,
  ) async {
    final data = await _authService.login(
      email,
      motDePasse,
    );

    final userData = data['user'] ?? data;

    return User.fromMap(
      Map<String, dynamic>.from(userData),
    );
  }

  /// Inscription
  Future<User> register(
    String nom,
    String email,
    String motDePasse,
  ) async {
    final data = await _authService.register(
      nom,
      email,
      motDePasse,
    );

    final userData = data['user'] ?? data;

    return User.fromMap(
      Map<String, dynamic>.from(userData),
    );
  }

  /// Déconnexion
  Future<void> logout() async {
    await _authService.logout();
  }

  /// Vérifie si l'utilisateur est connecté
  Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }

  /// Récupère le token
  Future<String?> getToken() async {
    return await _authService.getToken();
  }

  /// Supprime le token
  Future<void> clearToken() async {
    await _authService.clearToken();
  }
}