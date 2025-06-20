import 'package:meldinheiro/data/db/database.dart';
import 'package:meldinheiro/models/account.dart';

class AccountDao {
  Future<List<Account>> getAccounts() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('accounts');
    return result.map((map) => Account.fromMap(map)).toList();
  }
  Future<int> insertAccount(Account account) async {
    final db = await DatabaseHelper().database;
    return await db.insert('accounts', account.toMap());
  }

  Future<bool> accountNameExists(String name) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'accounts',
      where: 'name = ?',
      whereArgs: [name],
    );
    return result.isNotEmpty;
  }

  Future<int> updateAccount(Account account) async {
    final db = await DatabaseHelper().database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }
}