import 'package:flutter/material.dart';
import 'package:meldinheiro/data/daos/transaction_dao.dart';
import 'package:meldinheiro/models/transaction.dart';
import 'package:meldinheiro/viewmodels/account_viewmodel.dart';


class TransactionViewModel extends ChangeNotifier {
  final _dao = TransactionDao();
  final AccountViewModel accountViewModel;

  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  Map<String, dynamic> _currentFilters = {};
  Map<String, dynamic> get currentFilters => _currentFilters;

  void applyFilters(Map<String, dynamic> filters) {
    _currentFilters = filters;
    notifyListeners();
  }

  List<Transaction> get filteredTransactions {
    return _transactions.where((transaction) {
      // Filtra por período
      bool matchesPeriod = false;
      switch (_selectedPeriod) {
        case "Dia":
          matchesPeriod = _isSameDay(transaction.date, _selectedDate);
          break;
        case "Semana":
          matchesPeriod = _isSameWeek(transaction.date, _selectedDate);
          break;
        case "Mês":
          matchesPeriod = transaction.date.year == _selectedDate.year && transaction.date.month == _selectedDate.month;
          break;
        case "Ano":
          matchesPeriod = transaction.date.year == _selectedDate.year;
          break;
        default:
          matchesPeriod = true;
      }

      // Filtros adicionais
      final type = _currentFilters['tipo'];
      final account = _currentFilters['conta'];
      final category = _currentFilters['categoria'];
      final subCategory = _currentFilters['subcategoria'];

      bool matchesTipo = type == null || transaction.type == type;
      bool matchesConta = account == null || transaction.accountId == account;
      bool matchesCategoria = category == null || transaction.categoryId == category;
      bool matchesSubcategoria = subCategory == null || transaction.subCategoryId == subCategory;

      return matchesPeriod && matchesTipo && matchesConta && matchesCategoria && matchesSubcategoria;
    }).toList();
  }


  List<Transaction> get filteredTransactions1 {
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

  DateTime _selectedDate = DateTime.now();
  String _selectedPeriod = "Mês";

  DateTime get selectedDate => _selectedDate;
  String get selectedPeriod => _selectedPeriod;

  void setFilter(DateTime newDate, String period) {
    _selectedDate = newDate;
    _selectedPeriod = period;
    notifyListeners();
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

  // Cálculos com base nas transações filtradas
  double get totalIncome => filteredTransactions
      .where((t) => t.type == 'Receita')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => filteredTransactions
      .where((t) => t.type == 'Despesa')
      .fold(0.0, (sum, t) => sum + t.amount);


  TransactionViewModel({required this.accountViewModel}) {
    loadTransactions();
    //  Carrega os dados ao iniciar o Provider
  }


  Future<void> loadTransactions() async {
    _transactions = await _dao.findAll();
    accountViewModel.updateBalancesWithTransactions(_transactions);
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
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _dao.updateTransaction(transaction);//DatabaseHelper.instance.updateTransaction(transaction);
    await loadTransactions();
    _calculateTotals();
    notifyListeners();
// Recarrega os dados após a atualização
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _dao.insertTransaction(transaction); //DatabaseHelper.instance.insertTransaction(transaction);
    _transactions.add(transaction);
    await loadTransactions();
    _calculateTotals();
    notifyListeners();
  }


  Future<void> deleteTransaction(int id) async {
    await _dao.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    await loadTransactions();
    _calculateTotals();

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


}



