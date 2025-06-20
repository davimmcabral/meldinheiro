
import 'package:meldinheiro/data/db/database.dart';
import 'package:meldinheiro/models/category.dart';

class CategoryDao {

  Future<List<Category>> getAllCategories() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> result = await db.query('categories');
    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getCategories(String type) async {
    final db = await DatabaseHelper().database;
    return await db.query('categories', where: 'type = ?', whereArgs: [type]);
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
    return result.map((e) => Category.fromMap(e)).toList();
  }

  Future<int> insertCategory(Category category) async {
    final db = await DatabaseHelper().database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final db = await DatabaseHelper().database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}