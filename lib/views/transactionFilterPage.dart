import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/category_viewmodel.dart';
import '../models/transactionProvider.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/account.dart';

class TransactionFilterPage extends StatefulWidget {
  final Map<String, dynamic> currentFilters;

  const TransactionFilterPage({super.key, required this.currentFilters});

  @override
  State<TransactionFilterPage> createState() => _TransactionFilterPageState();
}

class _TransactionFilterPageState extends State<TransactionFilterPage> {
  String? _tipo;
  String _periodo = "Mês";
  int? _contaId;
  int? _categoriaId;
  int? _subCategoriaId;

  @override
  void initState() {
    super.initState();
    _tipo = widget.currentFilters['tipo'];
    _periodo = widget.currentFilters['periodo'] ?? "Mês";
    _contaId = widget.currentFilters['conta'];
    _categoriaId = widget.currentFilters['categoria'];
    _subCategoriaId = widget.currentFilters['subcategoria'];
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryViewModel>(context);
    final transactionProvider = Provider.of<TransactionViewModel>(context);
    final categoriasFiltradas = categoryProvider.categories
        .where((cat) => cat.type == _tipo)
        .toList();
    final subCategoriasFiltradas = categoryProvider.subCategories
        .where((sub) => sub.categoryId == _categoriaId)
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
              value: _tipo,
              items: [null, 'Receita', 'Despesa'].map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo ?? 'Todos os Tipos'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipo = value;
                  _categoriaId = null;
                  _subCategoriaId = null;
                });
              },
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            DropdownButtonFormField<int>(
              value: _contaId,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todas as Contas'),
                ),
                ...transactionProvider.account.map((conta) => DropdownMenuItem(
                  value: conta.id,
                  child: Text(conta.name),
                ))
              ],
              onChanged: (value) => setState(() => _contaId = value),
              decoration: const InputDecoration(labelText: 'Conta'),
            ),
            DropdownButtonFormField<String>(
              value: _periodo,
              items: ['Dia', 'Semana', 'Mês', 'Ano'].map((periodo) {
                return DropdownMenuItem(
                  value: periodo,
                  child: Text(periodo),
                );
              }).toList(),
              onChanged: (value) => setState(() => _periodo = value!),
              decoration: const InputDecoration(labelText: 'Período'),
            ),
            if (_tipo != null)
              DropdownButtonFormField<int>(
                value: _categoriaId,
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
                  _categoriaId = value;
                  _subCategoriaId = null;
                }),
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
            if (_categoriaId != null)
              DropdownButtonFormField<int>(
                value: _subCategoriaId,
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
                onChanged: (value) => setState(() => _subCategoriaId = value),
                decoration: const InputDecoration(labelText: 'Subcategoria'),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Aplicar Filtros'),
              onPressed: () {
                Navigator.pop(context, {
                  'tipo': _tipo,
                  'periodo': _periodo,
                  'conta': _contaId,
                  'categoria': _categoriaId,
                  'subcategoria': _subCategoriaId,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
