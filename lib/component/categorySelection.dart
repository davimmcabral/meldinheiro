
import 'package:flutter/material.dart';

import '../data/db/database.dart';

class CategorySelection extends StatefulWidget {
  final String type;
  final Function(String, String) onSelectionChanged;

  CategorySelection({required this.type, required this.onSelectionChanged});

  @override
  _CategorySelectionState createState() => _CategorySelectionState();
}

class _CategorySelectionState extends State<CategorySelection> {
  List<Map<String, dynamic>> _categories = [];
  Map<int, List<String>> _subcategories = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categoriesData = await DatabaseHelper.instance.getCategories(widget.type);
    Map<int, List<String>> subcategoriesMap = {};

    for (var category in categoriesData) {
      final subcategoriesData = await DatabaseHelper.instance.getSubCategories(category['id']);
      subcategoriesMap[category['id']] = subcategoriesData.map((e) => e['name'] as String).toList();
    }

    setState(() {
      _categories = categoriesData;
      _subcategories = subcategoriesMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _categories.map((category) {
        return ExpansionTile(
          title: Text(category['name']),
          children: _subcategories[category['id']]?.map((subcategory) {
            return ListTile(
              title: Text(subcategory),
              onTap: () {
                widget.onSelectionChanged(category['name'], subcategory);
                Navigator.pop(context);
              },
            );
          }).toList() ??
              [],
        );
      }).toList(),
    );
  }
}
