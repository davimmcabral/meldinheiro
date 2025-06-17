import 'package:flutter/material.dart';
import 'package:meldinheiro/data/category_dao.dart';
import 'package:meldinheiro/models/subcategory.dart';
import '../data/db/database.dart';
import '../models/category.dart';

class CategoryViewModel with ChangeNotifier {
  final _dao = CategoryDao;
  List<Category> _categories = [];
  List<SubCategory> _subCategories = [];

  List<Category> get categories => _categories;
  List<SubCategory> get subCategories => _subCategories;

 /* void loadDefaultCategories() {
    if (_categories.isNotEmpty) return;

    _categories = [
      CategoryModel(id: 1, name: 'Alimentação', type: 'Despesa'),
      CategoryModel(id: 2, name: 'Transporte', type: 'Despesa'),
      CategoryModel(id: 3, name: 'Salário', type: 'Receita'),
      CategoryModel(id: 4, name: 'Investimentos', type: 'Receita'),
    ];

    _subCategories = [
      SubCategoryModel(id: 1, name: 'Restaurantes', categoryId: 1),
      SubCategoryModel(id: 2, name: 'Supermercado', categoryId: 1),
      SubCategoryModel(id: 3, name: 'Ônibus', categoryId: 2),
      SubCategoryModel(id: 4, name: 'Combustível', categoryId: 2),
      SubCategoryModel(id: 5, name: 'Salário Mensal', categoryId: 3),
      SubCategoryModel(id: 6, name: 'Freelance', categoryId: 3),
      SubCategoryModel(id: 7, name: 'Ações', categoryId: 4),
      SubCategoryModel(id: 8, name: 'Fundos Imobiliários', categoryId: 4),
    ];

    notifyListeners();
  }
  Future<void> loadDefaultCategories() async {
    if (_categories.isEmpty) {
      await loadCategories();
    }
  }*/


  String getCategoryNameById(int categoryId) {
    return _categories.firstWhere((category) => category.id == categoryId, orElse: () => Category(id: categoryId, name: 'Desconhecido', type: 'Despesa')).name;
  }


Future<void> loadCategories() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('categories');
    _categories = result.map((c) => Category.fromMap(c)).toList();
    notifyListeners();
  }

  Future<void> loadSubCategories() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('subcategories');
    _subCategories = result.map((s) => SubCategory.fromMap(s)).toList();
    notifyListeners();
  }

  Future<void> loadDefaultCategories() async {
    await loadCategories();
    await loadSubCategories();
  }

  Future<void> addCategory(Category category) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('categories', category.toMap());
    await loadCategories();
  }

  Future<void> addSubCategory(SubCategory subCategory) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('subcategories', subCategory.toMap());
    await loadSubCategories();
  }


  Future<void> deleteCategory(int id) async {
    final db = await DatabaseHelper.instance.database;
    // Exclui subcategorias relacionadas primeiro
    await db.delete('subcategories', where: 'category_id = ?', whereArgs: [id]);
    // Exclui a categoria
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    await loadCategories();
    await loadSubCategories();
    notifyListeners();
  }

  Future<void> deleteSubCategory(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('subcategories', where: 'id = ?', whereArgs: [id]);
    await loadSubCategories();
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
    await loadCategories();
    notifyListeners();
  }

  Future<void> updateSubCategory(SubCategory subCategory) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'subcategories',
      subCategory.toMap(),
      where: 'id = ?',
      whereArgs: [subCategory.id],
    );
    await loadSubCategories();
    notifyListeners();
  }
}
