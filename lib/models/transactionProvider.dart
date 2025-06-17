import 'package:flutter/material.dart';
import 'package:meldinheiro/models/transaction.dart' as model;
import 'package:meldinheiro/models/transaction.dart';
import 'package:meldinheiro/views/budgetPage.dart';
import '../data/db/database.dart';
import 'account.dart';

class TransactionViewModel extends ChangeNotifier {
  List<model.Transaction> _transactions = [];
  List<Account> _accounts = [];

  DateTime _selectedDate = DateTime.now();
  String _selectedPeriod = "Mês";

  DateTime get selectedDate => _selectedDate;
  String get selectedPeriod => _selectedPeriod;

  void setFilter(DateTime newDate, String period) {
    _selectedDate = newDate;
    _selectedPeriod = period;
    notifyListeners();
  }

  List<Transaction> get filteredTransactions {
    switch (_selectedPeriod) {
      case "Dia":
        return _transactions.where((t) => _isSameDay(t.date, _selectedDate)).toList();
      case "Semana":
        return _transactions.where((t) => _isSameWeek(t.date, _selectedDate)).toList();
      case "Mês":
        return _transactions.where((t) =>
        t.date.year == _selectedDate.year && t.date.month == _selectedDate.month).toList();
      case "Ano":
        return _transactions.where((t) => t.date.year == _selectedDate.year).toList();
      default:
        return _transactions;
    }
  }
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool _isSameWeek(DateTime date, DateTime reference) {
    final start = reference.subtract(Duration(days: reference.weekday - 1));
    final end = start.add(Duration(days: 6));
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }

  double _income = 0.0;
  double _expense = 0.0;
  double _balance = 0.0;

  List<model.Transaction> get transactions => _transactions;
  List<Account> get account => _accounts;
  
  double get income1 => _income;

  double get expense1 => _expense;

  double get balance1 => _balance;

  // Cálculos com base nas transações filtradas
  double get income => filteredTransactions
      .where((t) => t.type == 'Receita')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get expense => filteredTransactions
      .where((t) => t.type == 'Despesa')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => _accounts.fold(0.0, (sum, accounts) => sum + accounts.balance);

  TransactionViewModel() {
    loadAccounts();
   // loadTransactions();
    //  Carrega os dados ao iniciar o Provider
  }



/*  Future<void> loadTransactions() async {
    _transactions = await DatabaseHelper.instance.getTransactions();
    _updateAccountBalances();
    _calculateTotals();
    notifyListeners(); // Atualiza todas as telas que usam esse Provider
  }*/

  void _updateAccountBalances() {
    for (var account in _accounts) {
      double totalIncome = _transactions
          .where((t) => t.accountId == account.id && t.type == 'Receita')
          .fold(0, (sum, t) => sum + t.amount);

      double totalExpense = _transactions
          .where((t) => t.accountId == account.id && t.type == 'Despesa')
          .fold(0, (sum, t) => sum + t.amount);

      account.balance = account.initialBalance + totalIncome - totalExpense;
      notifyListeners();
    }
  }

  void _calculateTotals() {
    _income = _transactions
        .where((transaction) => transaction.type == 'Receita')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    _expense = _transactions
        .where((transaction) => transaction.type == 'Despesa')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    _balance = _income - _expense;
    notifyListeners();
  }

  /*Future<void> updateTransaction(model.Transaction transaction) async {
    await DatabaseHelper.instance.updateTransaction(transaction);
    await loadTransactions();
    _calculateTotals();
    notifyListeners();
// Recarrega os dados após a atualização
  }

  Future<void> addTransaction(model.Transaction transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    _transactions.add(transaction);
    _calculateTotals();
    _updateAccountBalances();
    notifyListeners();
  }


  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    _calculateTotals();
    _updateAccountBalances();
    notifyListeners();
  }*/




  Future<void> getTransactionsByPeriod(String period) async {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'Hoje':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Semana':
        startDate = now.subtract(Duration(days: now.weekday -1));
        break;
      case 'Mês':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Ano':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    DateTime endDate = now;

    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    _transactions = result.map((map) => model.Transaction.fromMap(map)).toList();
    notifyListeners();
  }


  void addBudget(Budget budget) {}

  Future<void> loadAccounts() async {
    _accounts = await DatabaseHelper.instance.getAccounts();
    _updateAccountBalances();
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    final accountNameExists = await DatabaseHelper.instance.accountNameExists(account.name);
    if (accountNameExists){
      throw Exception('Já existe uma conta com esse nome.');
    } else {
      final id = await DatabaseHelper.instance.insertAccount(account);
      account.id = id;
      _accounts.add(account);
      _updateAccountBalances();
      notifyListeners();
    }
  }

  Future<void> updateAccount(Account updatedAccount) async {
    final accountNameExists = await DatabaseHelper.instance.accountNameExists(updatedAccount.name);
    if (accountNameExists && updatedAccount.id != updatedAccount.id){
      throw Exception('Já existe uma conta com esse nome.');
    }
    await DatabaseHelper.instance.updateAccount(updatedAccount);
    await loadAccounts();
    notifyListeners();
  }

  bool hasTransactionsForAccount(int accountId) {
    return _transactions.any((transaction) => transaction.accountId == accountId);
  }
  bool hasTransactionsForCategory(int categoryId) {
    return _transactions.any((transaction) => transaction.categoryId == categoryId);
  }
  bool hasTransactionsForSubcategory(int subcategoryId) {
    return _transactions.any((transaction) => transaction.subCategoryId == subcategoryId);
  }

  Future<void> deleteAccount(int accountId) async {
    await DatabaseHelper.instance.deleteAccount(accountId);
    _accounts.removeWhere((acc) => acc.id == accountId);
    notifyListeners();
  }

}



