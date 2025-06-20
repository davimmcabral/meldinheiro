import 'package:flutter/material.dart';
import 'package:meldinheiro/viewmodels/account_viewmodel.dart';
import 'package:meldinheiro/viewmodels/subcategory_viewmodel.dart';
import 'package:meldinheiro/viewmodels/transaction_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../models/category.dart';
import '../../models/subcategory.dart';
import '../../models/account.dart';

class TransactionFilterPage extends StatefulWidget {
  final Map<String, dynamic> currentFilters;

  const TransactionFilterPage({super.key, required this.currentFilters});

  @override
  State<TransactionFilterPage> createState() => _TransactionFilterPageState();
}

class _TransactionFilterPageState extends State<TransactionFilterPage> {
  String? _type;
  int? _accountId;
  int? _categoryId;
  int? _subCategoryId;

  @override
  void initState() {
    super.initState();
    _type = widget.currentFilters['tipo'];
    _accountId = widget.currentFilters['conta'];
    _categoryId = widget.currentFilters['categoria'];
    _subCategoryId = widget.currentFilters['subcategoria'];
  }

  @override
  Widget build(BuildContext context) {
    final categoryVM = Provider.of<CategoryViewModel>(context);
    final subCategoryVM = Provider.of<SubCategoryViewModel>(context);
    final accountVM = Provider.of<AccountViewModel>(context);

    final filteredCategories = categoryVM.categories
        .where((cat) => cat.type == _type)
        .toList();
    final filteredSubCategories = subCategoryVM.subCategories
        .where((sub) => sub.categoryId == _categoryId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrar Transações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const Text(
                  'Escolha os filtros abaixo:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _type,
                  items: [null, 'Receita', 'Despesa'].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type ?? 'Todos os Tipos'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _type = value;
                      _categoryId = null;
                      _subCategoryId = null;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _accountId,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todas as Contas'),
                    ),
                    ...accountVM.accounts.map((conta) => DropdownMenuItem(
                      value: conta.id,
                      child: Text(conta.name),
                    ))
                  ],
                  onChanged: (value) => setState(() => _accountId = value),
                  decoration: InputDecoration(
                    labelText: 'Conta',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_type != null)
                  DropdownButtonFormField<int>(
                    value: _categoryId,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todas as Categorias'),
                      ),
                      ...filteredCategories.map((cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      ))
                    ],
                    onChanged: (value) {
                      setState(() {
                        _categoryId = value;
                        _subCategoryId = null;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                if (_type != null) const SizedBox(height: 16),
                if (_categoryId != null)
                  DropdownButtonFormField<int>(
                    value: _subCategoryId,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todas as Subcategorias'),
                      ),
                      ...filteredSubCategories.map((sub) => DropdownMenuItem(
                        value: sub.id,
                        child: Text(sub.name),
                      ))
                    ],
                    onChanged: (value) => setState(() => _subCategoryId = value),
                    decoration: InputDecoration(
                      labelText: 'Subcategoria',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.filter_alt),
                        label: const Text('Aplicar Filtros'),
                        onPressed: () {
                          Navigator.pop(context, {
                            'tipo': _type,
                            'conta': _accountId,
                            'categoria': _categoryId,
                            'subcategoria': _subCategoryId,
                          });
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:meldinheiro/viewmodels/account_viewmodel.dart';
import 'package:meldinheiro/viewmodels/subcategory_viewmodel.dart';
import 'package:meldinheiro/viewmodels/transaction_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../models/category.dart';
import '../../models/subcategory.dart';
import '../../models/account.dart';

class TransactionFilterPage extends StatefulWidget {
  final Map<String, dynamic> currentFilters;

  const TransactionFilterPage({super.key, required this.currentFilters});

  @override
  State<TransactionFilterPage> createState() => _TransactionFilterPageState();
}

class _TransactionFilterPageState extends State<TransactionFilterPage> {
  String? _type;
  int? _accountId;
  int? _categoryId;
  int? _subCategoryId;

  @override
  void initState() {
    super.initState();
    _type = widget.currentFilters['tipo'];
    _accountId = widget.currentFilters['conta'];
    _categoryId = widget.currentFilters['categoria'];
    _subCategoryId = widget.currentFilters['subcategoria'];
  }

  @override
  Widget build(BuildContext context) {
    final categoryVM = Provider.of<CategoryViewModel>(context);
    final subCategoryVM = Provider.of<SubCategoryViewModel>(context);
    final accountVM = Provider.of<AccountViewModel>(context);
    final categoriasFiltradas = categoryVM.categories
        .where((cat) => cat.type == _type)
        .toList();
    final subCategoriasFiltradas = subCategoryVM.subCategories
        .where((sub) => sub.categoryId == _categoryId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrar Transações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              items: [null, 'Receita', 'Despesa'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type ?? 'Todos os Tipos'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _type = value;
                  _categoryId = null;
                  _subCategoryId = null;
                });
              },
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            DropdownButtonFormField<int>(
              value: _accountId,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todas as Contas'),
                ),
                ...accountVM.accounts.map((conta) => DropdownMenuItem(
                  value: conta.id,
                  child: Text(conta.name),
                ))
              ],
              onChanged: (value) => setState(() => _accountId = value),
              decoration: const InputDecoration(labelText: 'Conta'),
            ),
            if (_type != null)
              DropdownButtonFormField<int>(
                value: _categoryId,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todas as Categorias'),
                  ),
                  ...categoriasFiltradas.map((cat) => DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name),
                  ))
                ],
                onChanged: (value) => setState(() {
                  _categoryId = value;
                  _subCategoryId = null;
                }),
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
            if (_categoryId != null)
              DropdownButtonFormField<int>(
                value: _subCategoryId,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todas as Subcategorias'),
                  ),
                  ...subCategoriasFiltradas.map((sub) => DropdownMenuItem(
                    value: sub.id,
                    child: Text(sub.name),
                  ))
                ],
                onChanged: (value) => setState(() => _subCategoryId = value),
                decoration: const InputDecoration(labelText: 'Subcategoria'),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Aplicar Filtros'),
              onPressed: () {
                Navigator.pop(context, {
                  'tipo': _type,
                  'conta': _accountId,
                  'categoria': _categoryId,
                  'subcategoria': _subCategoryId,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
*/
