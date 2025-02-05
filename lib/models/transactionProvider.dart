import 'package:flutter/material.dart';
import 'package:meldinheiro/models/transaction.dart';

import '../database/database.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];

  double _income = 0.0;
  double _expense = 0.0;
  double _balance = 0.0;

  List<Transaction> get transactions => _transactions;
  double get income => _income;
  double get expense => _expense;
  double get balance => _balance;

  TransactionProvider() {
    loadTransactions(); //  Carrega os dados ao iniciar o Provider
  }


  Future<void> loadTransactions() async {
    _transactions = await DatabaseHelper.instance.getTransactions();
    _calculateTotals();
    notifyListeners(); // Atualiza todas as telas que usam esse Provider
  }
  void _calculateTotals() {
    _income = _transactions
        .where((transaction) => transaction.type == 'Receita')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    _expense = _transactions
        .where((transaction) => transaction.type == 'Despesa')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    _balance = _income - _expense;
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await DatabaseHelper.instance.updateTransaction(transaction);
    await loadTransactions();
    _calculateTotals();
    notifyListeners();
// Recarrega os dados após a atualização
  }

  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    _transactions.add(transaction);
    _calculateTotals();
    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    _calculateTotals();
    notifyListeners();
  }
}

