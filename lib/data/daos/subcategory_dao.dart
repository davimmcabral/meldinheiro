import 'package:meldinheiro/data/db/database.dart';
import 'package:meldinheiro/models/subcategory.dart';

class SubCategoryDao {

  Future<List<SubCategory>> getAllSubCategories() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('subcategories');
    return result.map((s) => SubCategory.fromMap(s)).toList();
  }

  Future<void> insertSubCategory(SubCategory subCategory) async {
    final db = await DatabaseHelper().database;
    await db.insert('subcategories', subCategory.toMap());
  }

  Future<void> updateSubCategory(SubCategory subCategory) async {
    final db = await DatabaseHelper().database;
    await db.update(
      'subcategories',
      subCategory.toMap(),
      where: 'id = ?',
      whereArgs: [subCategory.id],
    );
  }

  Future<void> deleteSubCategory(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete(
      'subcategories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteByCategoryId(int categoryId) async {
    final db = await DatabaseHelper().database;
    await db.delete(
      'subcategories',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }



 /* Future<List<Map<String, dynamic>>> getSubCategories(int categoryId) async {
    final db = await DatabaseHelper().database;
    return await db.query(
        'subcategories', where: 'category_id = ?', whereArgs: [categoryId]);
  }

  Future<int> insertSubCategory(int categoryId, String name) async {
    final db = await DatabaseHelper().database;
    return await db.insert(
        'subcategories', {'category_id': categoryId, 'name': name});
  }

  Future<int> updateSubCategory(int id, int categoryId, String name) async {
    final db = await DatabaseHelper().database;
    return await db.update(
        'subcategories', {'category_id': categoryId, 'name': name},
        where: 'id = ?', whereArgs: [id]);
  }*/
/*
  Future<int> deleteSubCategory(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('subcategories', where: 'id = ?', whereArgs: [id]);
  }*/

}