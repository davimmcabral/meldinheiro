import 'package:meldinheiro/models/transaction.dart';


import 'package:meldinheiro/data/db/database.dart';

class TransactionDao {
  Future<List<Transaction>> findAll() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('transactions');
    return result.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<int> insertTransaction(Transaction transaction) async {
    final db = await DatabaseHelper().database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<int> deleteTransaction(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await DatabaseHelper().database;
    return await db.update('transactions', transaction.toMap(),
        where: 'id = ?', whereArgs: [transaction.id]);
  }
}