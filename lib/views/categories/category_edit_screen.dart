import 'package:flutter/material.dart';
import 'package:meldinheiro/viewmodels/category_viewmodel.dart';
import 'package:meldinheiro/models/subcategory.dart';
import 'package:meldinheiro/viewmodels/subcategory_viewmodel.dart';
import 'package:meldinheiro/viewmodels/transaction_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';

class EditCategoryScreen extends StatelessWidget {
  const EditCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Categorias')),
      body: Consumer3<CategoryViewModel, SubCategoryViewModel, TransactionViewModel>(
        builder: (context, categoryVM, subCategoryVM, transactionVM, _) {
          final categories = categoryVM.categories;
          final subcategories = subCategoryVM.subCategories;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final relatedSubs = subcategories
                  .where((sub) => sub.categoryId == category.id)
                  .toList();

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Text('${category.name} (${category.type})'),
                  childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  trailing: const Icon(Icons.arrow_drop_down),
                  leading: CircleAvatar(
                    backgroundColor:
                    category.type == 'Receita' ? Colors.green : Colors.red,
                    child: Icon(
                      category.type == 'Receita' ? Icons.add : Icons.remove,
                      color: Colors.white,
                    ),
                  ),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'Adicionar Subcategoria',
                          onPressed: () => _showAddSubcategoryDialog(
                              context, category.id!, subCategoryVM),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditCategoryDialog(
                              context, category, categoryVM),
                        ),
                        IconButton(
                          icon:
                          const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            final transactionVM = context.read<TransactionViewModel>();
                            if (transactionVM.hasTransactionsForCategory(category.id!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Não é possível excluir: categoria com transações vinculadas!')),
                              );
                              return;
                            }
                            await categoryVM.deleteCategory(category.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Categoria excluída.')),
                            );
                          },
                        ),
                      ],
                    ),
                    ...relatedSubs.map((subcategory) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        leading: const Icon(Icons.subdirectory_arrow_right),
                        title: Text(subcategory.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditSubcategoryDialog(
                                  context, subcategory, subCategoryVM),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final transactionVM = context.read<TransactionViewModel>();
                                if (transactionVM.hasTransactionsForSubcategory(subcategory.id!)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Não é possível excluir: subcategoria com transações vinculadas!')),
                                  );
                                  return;
                                }
                                await subCategoryVM.deleteSubCategory(subcategory.id!);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Subcategoria excluída.'),
                                ));
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category,
      CategoryViewModel categoryVM) {
    final _formKey = GlobalKey<FormState>();
    String name = category.name;
    String type = category.type;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Editar Categoria'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration:
                  const InputDecoration(labelText: 'Nome da Categoria'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe um nome' : null,
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  items: ['Receita', 'Despesa'].map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (value) => type = value!,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton.icon(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final updated =
                Category(id: category.id, name: name, type: type);
                await categoryVM.updateCategory(updated);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showAddSubcategoryDialog(
      BuildContext context, int categoryId, SubCategoryViewModel subCategoryVM) {
    final _formKey = GlobalKey<FormState>();
    String name = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.add, color: Colors.blue),
            SizedBox(width: 8),
            Text('Nova Subcategoria'),
          ],
        ),
        content: Form(
          key: _formKey,
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'Nome da Subcategoria'),
            validator: (value) =>
            value == null || value.isEmpty ? 'Informe um nome' : null,
            onChanged: (value) => name = value,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final newSub = SubCategory(name: name, categoryId: categoryId);
                await subCategoryVM.insertSubCategory(newSub);
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }


  void _showEditSubcategoryDialog(BuildContext context, SubCategory subCategory,
      SubCategoryViewModel subCategoryVM) {
    final _formKey = GlobalKey<FormState>();
    String name = subCategory.name;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Editar Subcategoria'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: TextFormField(
              initialValue: name,
              decoration:
              const InputDecoration(labelText: 'Nome da Subcategoria'),
              validator: (value) =>
              value == null || value.isEmpty ? 'Informe um nome' : null,
              onChanged: (value) => name = value,
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final updated = SubCategory(
                    id: subCategory.id, name: name, categoryId: subCategory.categoryId);
                await subCategoryVM.updateSubCategory(updated);
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}