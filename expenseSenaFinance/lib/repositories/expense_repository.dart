import 'package:app_expenses/models/expense_model.dart';
import 'package:app_expenses/services/expense_service.dart';

class ExpenseRepository {
  final ExpenseService _expenseService;

  ExpenseRepository({
    ExpenseService? expenseService,
  }) : _expenseService = expenseService ?? ExpenseService();

  /// Récupérer toutes les dépenses
  Future<List<ExpenseModel>> getExpenses() async {
    final data = await _expenseService.getExpenses();

    return data
        .map(
          (json) => ExpenseModel.fromMap(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  /// Récupérer une dépense
  Future<ExpenseModel> getExpenseById(int id) async {
    final data = await _expenseService.getExpenseById(
      id.toString(),
    );

    return ExpenseModel.fromMap(data);
  }

  /// Créer une dépense
  Future<ExpenseModel> createExpense(
    ExpenseModel expense,
  ) async {
    final data = await _expenseService.createExpense(
      expense.toMap(),
    );

    return ExpenseModel.fromMap(data);
  }

  /// Modifier une dépense
  Future<ExpenseModel> updateExpense(
    ExpenseModel expense,
  ) async {
    if (expense.id == null) {
      throw Exception(
        'Impossible de modifier une dépense sans identifiant.',
      );
    }

    final data = await _expenseService.updateExpense(
      expense.id.toString(),
      expense.toMap(),
    );

    return ExpenseModel.fromMap(data);
  }

  /// Supprimer une dépense
  Future<void> deleteExpense(int id) async {
    await _expenseService.deleteExpense(
      id.toString(),
    );
  }
}