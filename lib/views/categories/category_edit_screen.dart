/*
import 'package:flutter/material.dart';
import 'package:meldinheiro/models/category_viewmodel.dart';
import 'package:meldinheiro/models/subcategory.dart';
import 'package:meldinheiro/models/transaction_viewmodel.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';

class EditCategoryScreen extends StatelessWidget {
  const EditCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Categorias')),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          final categories = categoryProvider.categories;
          final subcategories = categoryProvider.subCategories;

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
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: Icon(
                    category.type == 'Receita'
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: category.type == 'Receita'
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(
                    '${category.name} (${category.type})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: const Icon(Icons.expand_more),
                  childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // Botões de editar e excluir categoria alinhados à direita
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Editar categoria',
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _showEditCategoryDialog(
                              context, category, categoryProvider),
                        ),
                        IconButton(
                          tooltip: 'Excluir categoria',
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
                            if (transactionProvider.hasTransactionsForCategory(category.id!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Não é possível excluir: categoria com transações vinculadas!'),
                                ),
                              );
                              return;
                            }
                            await categoryProvider.deleteCategory(category.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Categoria excluída.')),
                            );
                          },
                        ),
                      ],
                    ),
                    // Listagem das subcategorias com botões de editar/excluir
                    ...relatedSubs.map((sub) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        leading: const Icon(Icons.subdirectory_arrow_right),
                        title: Text(sub.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar subcategoria',
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => _showEditSubcategoryDialog(
                                  context, sub, categoryProvider),
                            ),
                            IconButton(
                              tooltip: 'Excluir subcategoria',
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
                                if (transactionProvider.hasTransactionsForSubcategory(sub.id!)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Não é possível excluir: subcategoria com transações vinculadas!')),
                                  );
                                  return;
                                }
                                await categoryProvider.deleteSubCategory(sub.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Subcategoria excluída.')),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
      CategoryProvider provider) {
    final _formKey = GlobalKey<FormState>();
    String name = category.name;
    String type = category.type;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
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
                await provider.updateCategory(updated);
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

  void _showEditSubcategoryDialog(BuildContext context, SubCategory sub,
      CategoryProvider provider) {
    final _formKey = GlobalKey<FormState>();
    String name = sub.name;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
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
                    id: sub.id, name: name, categoryId: sub.categoryId);
                await provider.updateSubCategory(updated);
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
*/


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

        /*  Consumer2<CategoryViewModel, SubCategoryViewModel>(
            builder: (context, categoryVM,subCategoryVM, _) {
              final categories = categoryVM.categories;
              final subcategories = subCategoryVM.subCategories;*/

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
                  leading: Icon(
                    category.type == 'Receita'
                        ? Icons.add
                        : Icons.remove,
                    color: category.type == 'Receita'
                        ? Colors.green
                        : Colors.red,
                  ),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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


/*
import 'package:flutter/material.dart';
import 'package:meldinheiro/models/category.dart';
import 'package:meldinheiro/models/subcategory.dart';
import 'package:meldinheiro/models/category_viewmodel.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';

class EditCategoryScreen extends StatelessWidget {
  const EditCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Categorias')),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          final categories = provider.categories;
          final subcategories = provider.subCategories;

          return ListView(
            children: categories.map((category) {
              final relatedSubs = subcategories
                  .where((sub) => sub.categoryId == category.id)
                  .toList();

              return ExpansionTile(
                title: Text('${category.name} (${category.type})'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditCategoryDialog(context, category, provider);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await provider.deleteCategory(category.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Categoria excluída')),
                        );
                      },
                    ),
                  ],
                ),
                children: relatedSubs.map((sub) {
                  return ListTile(
                    title: Text(sub.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditSubcategoryDialog(context, sub, provider);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await provider.deleteSubCategory(sub.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Subcategoria excluída')),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, CategoryModel category, CategoryProvider provider) {
    final _formKey = GlobalKey<FormState>();
    String name = category.name;
    String type = category.type;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Categoria'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Nome da Categoria'),
                validator: (value) => value == null || value.isEmpty ? 'Informe um nome' : null,
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final updated = CategoryModel(id: category.id, name: name, type: type);
                await provider.updateCategory(updated);
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showEditSubcategoryDialog(BuildContext context, SubCategoryModel sub, CategoryProvider provider) {
    final _formKey = GlobalKey<FormState>();
    String name = sub.name;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Subcategoria'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            initialValue: name,
            decoration: const InputDecoration(labelText: 'Nome da Subcategoria'),
            validator: (value) => value == null || value.isEmpty ? 'Informe um nome' : null,
            onChanged: (value) => name = value,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final updated = SubCategoryModel(id: sub.id, name: name, categoryId: sub.categoryId);
                await provider.updateSubCategory(updated);
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

 */
