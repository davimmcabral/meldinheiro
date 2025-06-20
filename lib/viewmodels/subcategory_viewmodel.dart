import 'package:flutter/material.dart';
import 'package:meldinheiro/data/daos/subcategory_dao.dart';
import '../models/subcategory.dart';


class SubCategoryViewModel with ChangeNotifier {
  final _dao = SubCategoryDao();
  List<SubCategory> _subCategories = [];

  List<SubCategory> get subCategories => _subCategories;

  Future<void> loadSubCategories() async {
    _subCategories = await _dao.getAllSubCategories();
    notifyListeners();
  }

  SubCategoryViewModelViewModel() {
    loadSubCategories();
    //  Carrega os dados ao iniciar o Provider
  }

  Future<void> addSubCategory(SubCategory subCategory) async {
    await _dao.insertSubCategory(subCategory);
    await loadSubCategories();
  }

  Future<void> updateSubCategory(SubCategory subCategory) async {
    await _dao.updateSubCategory(subCategory);
    await loadSubCategories();
  }

  Future<void> deleteSubCategory(int id) async {
    await _dao.deleteSubCategory(id);
    await loadSubCategories();
  }

  Future<void> deleteByCategoryId(int categoryId) async {
    await _dao.deleteByCategoryId(categoryId);
    await loadSubCategories();
  }
}
