
import 'package:senafinance/models/budget_model.dart';
import 'package:senafinance/services/budget_service.dart';

class BudgetRepository {
  final BudgetService _budgetService;

  BudgetRepository({
    BudgetService? budgetService,
  }) : _budgetService = budgetService ?? BudgetService();

  /// Récupérer tous les budgets
  Future<List<BudgetModel>> getBudgets() async {
    final data = await _budgetService.getBudgets();

    return data
        .map(
          (json) => BudgetModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  /// Récupérer un budget
  Future<BudgetModel> getBudgetById(String id) async {
    final data = await _budgetService.getBudgetById(id);

    return BudgetModel.fromJson(data);
  }

  /// Créer un budget
  Future<BudgetModel> createBudget(
    BudgetModel budget,
  ) async {
    final data = await _budgetService.createBudget(
      budget.toJson(),
    );

    return BudgetModel.fromJson(data);
  }

  /// Modifier un budget
  Future<BudgetModel> updateBudget(
    BudgetModel budget,
  ) async {
    if (budget.id == null) {
      throw Exception(
        'Impossible de modifier un budget sans identifiant.',
      );
    }

    final data = await _budgetService.updateBudget(
      budget.id.toString(),
      budget.toJson(),
    );

    return BudgetModel.fromJson(data);
  }

  /// Supprimer un budget
  Future<void> deleteBudget(int id) async {
    await _budgetService.deleteBudget(
      id.toString(),
    );
  }
}