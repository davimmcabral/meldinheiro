import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:meldinheiro/models/transaction.dart' as model;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

Future<Database> _initDatabase() async{
  final String path =  join(await getDatabasesPath(),'meldinheiro.db');
  return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            category TEXT,
            subCategory TEXT,
            description TEXT,
            date TEXT,
            amount REAL
          )
        ''');
        },
  );
}

Future<List<model.Transaction>> getTransactions() async {
    final db = await database;
    final result = await db.query('transactions');
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }


Future<int> insertTransaction(model.Transaction transaction) async {
  final db = await database;
  return await db.insert('transactions', transaction.toMap());
}

Future<List<model.Transaction>> findAll() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('transactions');
  return List.generate(maps.length, (i) {
    return model.Transaction.fromMap(maps[i]);
  });
}

Future<int> deleteTransaction(int id) async {
  final db = await database;
  return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
}

Future<int> updateTransaction(model.Transaction transaction) async {
  final db = await database;
  return await db.update('transactions', transaction.toMap(),
      where: 'id = ?', whereArgs: [transaction.id]);
}
}

