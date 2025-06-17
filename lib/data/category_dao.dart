
import 'package:meldinheiro/data/db/database.dart';

class CategoryDao {

Future<List<Map<String, dynamic>>> getCategories(String type) async {
  final db = await await DatabaseHelper().database;;
  return await db.query('categories', where: 'type = ?', whereArgs: [type]);
}

Future<int> insertCategory(String name, String type) async {
  final db = await DatabaseHelper().database;
  return await db.insert('categories', {'name': name, 'type': type});
}

Future<int> updateCategory(int id, String name, String type) async {
  final db = await await DatabaseHelper().database;
  return await db.update('categories', {'name': name, 'type': type},
      where: 'id = ?', whereArgs: [id]);
}

Future<int> deleteCategory(int id) async {
  final db = await await DatabaseHelper().database;
  return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
}

}