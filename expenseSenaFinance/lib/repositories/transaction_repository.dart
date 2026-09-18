

import 'package:senafinance/models/transaction_model.dart';
import 'package:senafinance/services/transaction_service.dart';

class TransactionRepository {
  final TransactionService _service;

  TransactionRepository({TransactionService? service})
      : _service = service ?? TransactionService();

  Future<List<TransactionModel>> getTransactions() async {
    final data = await _service.getTransactions();
    return data.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<TransactionModel> getTransactionById(int id) async {
    final data = await _service.getTransactionById(id.toString());
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    final data = await _service.createTransaction(transaction.toJson());
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> updateTransaction(
    TransactionModel transaction,
  ) async {
    final data = await _service.updateTransaction(
      transaction.id.toString(),
      transaction.toJson(),
    );
    return TransactionModel.fromJson(data);
  }

  Future<void> deleteTransaction(int id) async {
    await _service.deleteTransaction(id.toString());
  }
}