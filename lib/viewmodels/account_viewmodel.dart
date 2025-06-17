import 'package:flutter/material.dart';
import 'package:meldinheiro/data/account_dao.dart';
import 'package:meldinheiro/models/transaction.dart' as model;
import 'package:meldinheiro/models/account.dart';

class AccountViewModel extends ChangeNotifier{
  final _dao = AccountDao();

  List<Account> _accounts = [];

  List<Account> get account => _accounts;

  AccountViewModel() {
    loadAccounts();
    //  Carrega os dados ao iniciar o Provider
  }

  Future<void> loadAccounts() async {
    _accounts = await _dao.getAccounts();
    //_updateAccountBalances();
    notifyListeners();
  }


  void updateBalancesWithTransactions(List<model.Transaction> transactions) {
    for (var account in _accounts) {
      double totalIncome = transactions
          .where((t) => t.accountId == account.id && t.type == 'Receita')
          .fold(0, (sum, t) => sum + t.amount);

      double totalExpense = transactions
          .where((t) => t.accountId == account.id && t.type == 'Despesa')
          .fold(0, (sum, t) => sum + t.amount);

      account.balance = account.initialBalance + totalIncome - totalExpense;
    }
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    final accountNameExists = await _dao.accountNameExists(account.name);
    if (accountNameExists){
      throw Exception('Já existe uma conta com esse nome.');
    } else {
      final id = await _dao.insertAccount(account);
      account.id = id;
      _accounts.add(account);
      notifyListeners();
    }
  }

  Future<void> updateAccount(Account updatedAccount) async {
    final accountNameExists = await _dao.accountNameExists(updatedAccount.name);
    if (accountNameExists && updatedAccount.id != updatedAccount.id){
      throw Exception('Já existe uma conta com esse nome.');
    }
    await _dao.updateAccount(updatedAccount);
    await loadAccounts();
    notifyListeners();
  }

  Future<void> deleteAccount(int accountId) async {
    await _dao.deleteAccount(accountId);
    _accounts.removeWhere((acc) => acc.id == accountId);
    notifyListeners();
  }

  double get balance {
    return _accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

}
