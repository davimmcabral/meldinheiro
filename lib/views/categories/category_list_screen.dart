import 'package:flutter/material.dart';
import 'package:meldinheiro/viewmodels/subcategory_viewmodel.dart';
import 'package:meldinheiro/views/categories/category_add_screen.dart';
import 'package:meldinheiro/views/categories/category_edit_screen.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/category_viewmodel.dart';


class CategoryListScreen extends StatefulWidget {
  final Function(int categoryId, int subcategoryId) onSelect;
  final String type;

  const CategoryListScreen({
    required this.onSelect,
    required this.type,
    Key? key,
  }) : super(key: key);

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late CategoryViewModel categoryVM;
  late SubCategoryViewModel subCategoryVM;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      categoryVM = Provider.of<CategoryViewModel>(context, listen: false);
      subCategoryVM = Provider.of<SubCategoryViewModel>(context, listen: false);
      categoryVM.loadCategories();
      subCategoryVM.loadSubCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categorias e Subcategorias"),
          actions: [
      PopupMenuButton<String>(
      onSelected: (value) async {
    if (value == 'editar') {
    await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const EditCategoryScreen()),
    );
    await categoryVM.loadCategories();
    await subCategoryVM.loadSubCategories();
    setState(() {});
    } else if (value == 'adicionar') {
    final result = await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => AddCategoryScreen()),
    );
    if (result == true) {
    await categoryVM.loadCategories();
    await subCategoryVM.loadSubCategories();
    setState(() {});
    }
    }
    },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'editar',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Editar Categorias'),
          ),
        ),
        const PopupMenuItem(
          value: 'adicionar',
          child: ListTile(
            leading: Icon(Icons.add),
            title: Text('Nova Categoria'),
          ),
        ),
      ],
      ),
          ],
        /*actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar Categorias',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditCategoryScreen()),
              );
              // Recarrega após voltar da tela de edição
              await categoryProvider.loadCategories();
              await categoryProvider.loadSubCategories();
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddCategoryScreen()),
              );

              if (result == true) {
                await categoryProvider.loadCategories();
                await categoryProvider.loadSubCategories();
                setState(() {});
              }
            },
          )
        ],*/
      ),
      body: Consumer2<CategoryViewModel, SubCategoryViewModel>(
        builder: (context, categoryVM,subCategoryVM, _) {
          final categories = categoryVM.categories.where((category) => category.type == widget.type).toList();
          final subcategories = subCategoryVM.subCategories;

          return ListView(
            children: categories.map((category) {
              final categorySubcategories = subcategories
                  .where((s) => s.categoryId == category.id)
                  .toList();

              return ExpansionTile(
                title: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: categorySubcategories.map((subcategory) {
                  return ListTile(
                    title: Text(subcategory.name),
                    onTap: () {
                      widget.onSelect(category.id!, subcategory.id!);
                    },
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
