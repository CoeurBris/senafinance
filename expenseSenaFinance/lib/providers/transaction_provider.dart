// lib/providers/transaction_provider.dart


import 'package:flutter/foundation.dart';
import 'package:senafinance/models/transaction_model.dart';
import 'package:senafinance/repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;

  TransactionProvider({TransactionRepository? repository})
      : _repository = repository ?? TransactionRepository();

  List<TransactionModel> _transactions = [];

  bool _isLoading = false;

  String? _error;

  TransactionModel? _selectedTransaction;

  List<TransactionModel> get transactions =>
      List.unmodifiable(_transactions);

  bool get isLoading => _isLoading;

  String? get error => _error;

  TransactionModel? get selectedTransaction => _selectedTransaction;

  /// Total des revenus
  double get totalIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0, (total, t) => total + t.amount);
  }

  /// Total des dépenses
  double get totalExpense {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0, (total, t) => total + t.amount);
  }

  /// Solde disponible (revenus - dépenses)
  double get balance => totalIncome - totalExpense;

  /// Nombre de transactions
  int get transactionCount => _transactions.length;

  /// Charger toutes les transactions
  Future<void> loadTransactions() async {
    _setLoading(true);
    _error = null;

    try {
      _transactions = await _repository.getTransactions();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Récupérer une transaction
  Future<TransactionModel?> loadTransactionById(int id) async {
    _setLoading(true);
    _error = null;

    try {
      final transaction = await _repository.getTransactionById(id);
      _selectedTransaction = transaction;
      return transaction;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Créer une transaction
  Future<bool> createTransaction(TransactionModel transaction) async {
    _setLoading(true);
    _error = null;

    try {
      final created = await _repository.createTransaction(transaction);
      _transactions.insert(0, created);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Modifier une transaction
  Future<bool> updateTransaction(TransactionModel transaction) async {
    _setLoading(true);
    _error = null;

    try {
      final updated = await _repository.updateTransaction(transaction);

      final index = _transactions.indexWhere((t) => t.id == updated.id);
      if (index != -1) {
        _transactions[index] = updated;
      }

      if (_selectedTransaction?.id == updated.id) {
        _selectedTransaction = updated;
      }

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Supprimer une transaction
  Future<bool> deleteTransaction(int id) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);

      if (_selectedTransaction?.id == id) {
        _selectedTransaction = null;
      }

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sélectionner une transaction
  void selectTransaction(TransactionModel? transaction) {
    _selectedTransaction = transaction;
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