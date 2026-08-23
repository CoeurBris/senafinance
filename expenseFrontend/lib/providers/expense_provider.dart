import 'package:app_expenses/models/expense_model.dart';
import 'package:app_expenses/repositories/expense_repository.dart';
import 'package:flutter/foundation.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;

  ExpenseProvider({
    ExpenseRepository? repository,
  }) : _repository = repository ?? ExpenseRepository();

  List<ExpenseModel> _expenses = [];

  bool _isLoading = false;

  String? _error;

  ExpenseModel? _selectedExpense;

  List<ExpenseModel> get expenses =>
      List.unmodifiable(_expenses);

  bool get isLoading => _isLoading;

  String? get error => _error;

  ExpenseModel? get selectedExpense =>
      _selectedExpense;

  /// Total de toutes les dépenses
  double get totalExpenses {
    return _expenses.fold(
      0,
      (total, expense) => total + expense.montant,
    );
  }

  /// Nombre de dépenses
  int get expenseCount => _expenses.length;

  /// Charger toutes les dépenses
  Future<void> loadExpenses() async {
    _setLoading(true);
    _error = null;

    try {
      _expenses =
          await _repository.getExpenses();
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );
    } finally {
      _setLoading(false);
    }
  }

  /// Récupérer une dépense
  Future<ExpenseModel?> loadExpenseById(
    int id,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final expense =
          await _repository.getExpenseById(id);

      _selectedExpense = expense;

      return expense;
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Créer une dépense
  Future<bool> createExpense(
    ExpenseModel expense,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final createdExpense =
          await _repository.createExpense(
        expense,
      );

      _expenses.add(createdExpense);

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

  /// Modifier une dépense
  Future<bool> updateExpense(
    ExpenseModel expense,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedExpense =
          await _repository.updateExpense(
        expense,
      );

      final index = _expenses.indexWhere(
        (item) => item.id == updatedExpense.id,
      );

      if (index != -1) {
        _expenses[index] = updatedExpense;
      }

      if (_selectedExpense?.id ==
          updatedExpense.id) {
        _selectedExpense = updatedExpense;
      }

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

  /// Supprimer une dépense
  Future<bool> deleteExpense(
    int id,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.deleteExpense(id);

      _expenses.removeWhere(
        (expense) => expense.id == id,
      );

      if (_selectedExpense?.id == id) {
        _selectedExpense = null;
      }

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

  /// Sélectionner une dépense
  void selectExpense(
    ExpenseModel? expense,
  ) {
    _selectedExpense = expense;
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