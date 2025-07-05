import 'package:flutter/material.dart';
import 'package:meldinheiro/data/daos/category_dao.dart';
import '../data/db/database.dart';
import '../models/category.dart';

class CategoryViewModel with ChangeNotifier {
  final _dao = CategoryDao();
  List<Category> _categories = [];

  List<Category> get categories => _categories;


  Future<void> loadCategories() async {
    _categories = await _dao.getAllCategories();
    notifyListeners();
    
  }

  CategoryViewModel() {
    loadCategories();
    //  Carrega os dados ao iniciar o Provider
  }
  Future<void> loadCategories1() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('categories');
    _categories = result.map((c) => Category.fromMap(c)).toList();
    notifyListeners();
  }

  Future<void> loadCategoriesByType(String type) async {
    _categories = await _dao.getCategoriesByType(type);
    notifyListeners();
  }

  Future<void> InsertCategory(Category category) async {
    await _dao.insertCategory(category);
    await loadCategories();
  }


  Future<void> deleteCategory(int id) async {
    await _dao.deleteCategory(id);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _dao.updateCategory(category);
    await loadCategories();
    notifyListeners();
  }
}
