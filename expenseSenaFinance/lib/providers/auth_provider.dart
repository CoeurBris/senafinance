import 'package:app_expenses/models/user_model.dart';
import 'package:app_expenses/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';


class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({
    AuthRepository? repository,
  }) : _repository = repository ?? AuthRepository();

  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  User? get user => _user;

  bool get isLoading => _isLoading;

  bool get isAuthenticated => _isAuthenticated;

  String? get error => _error;

  /// Connexion
  Future<bool> login(
    String email,
    String motDePasse,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      _user = await _repository.login(
        email,
        motDePasse,
      );

      _isAuthenticated = true;

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      _isAuthenticated = false;

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Inscription
  Future<bool> register(
    String nom,
    String email,
    String motDePasse,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      _user = await _repository.register(
        nom,
        email,
        motDePasse,
      );

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Vérifier la session au démarrage
  Future<void> checkAuthentication() async {
    _setLoading(true);
    _error = null;

    try {
      _isAuthenticated =
          await _repository.isAuthenticated();
    } catch (e) {
      _isAuthenticated = false;

      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );
    } finally {
      _setLoading(false);
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.logout();

      _user = null;
      _isAuthenticated = false;
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );
    } finally {
      _setLoading(false);
    }
  }

  /// Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}