import 'package:app_expenses/models/budget_model.dart';
import 'package:flutter/foundation.dart';
import 'package:app_expenses/repositories/budget_repository.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _repository;

  BudgetProvider({BudgetRepository? repository})
    : _repository = repository ?? BudgetRepository();

  List<BudgetModel> _budgets = [];

  bool _isLoading = false;

  String? _error;

  BudgetModel? _selectedBudget;

  List<BudgetModel> get budgets => List.unmodifiable(_budgets);

  bool get isLoading => _isLoading;

  String? get error => _error;
  
  BudgetModel? get selectedBudget => _selectedBudget;

  double get totalBudgets {
    return _budgets.fold(0, (total, budget) => total + budget.montant);
  }

  /// Charger tous les budgets
  Future<void> loadBudgets() async {
    _setLoading(true);
    _error = null;

    try {
      _budgets = await _repository.getBudgets();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Récupérer un budget
  Future<BudgetModel?> loadBudgetById(int id) async {
    _setLoading(true);
    _error = null;

    try {
      final budget = await _repository.getBudgetById(id.toString());

      _selectedBudget = budget;

      return budget;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');

      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Créer un budget
  Future<bool> createBudget(BudgetModel budget) async {
    _setLoading(true);
    _error = null;

    try {
      final createdBudget = await _repository.createBudget(budget);

      _budgets.add(createdBudget);

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Modifier un budget
  Future<bool> updateBudget(BudgetModel budget) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedBudget = await _repository.updateBudget(budget);

      final index = _budgets.indexWhere((item) => item.id == updatedBudget.id);

      if (index != -1) {
        _budgets[index] = updatedBudget;
      }

      if (_selectedBudget?.id == updatedBudget.id) {
        _selectedBudget = updatedBudget;
      }

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Supprimer un budget
  Future<bool> deleteBudget(int id) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.deleteBudget(id);

      _budgets.removeWhere((budget) => budget.id == id);

      if (_selectedBudget?.id == id) {
        _selectedBudget = null;
      }

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sélectionner un budget localement
  void selectBudget(BudgetModel? budget) {
    _selectedBudget = budget;
    notifyListeners();
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
