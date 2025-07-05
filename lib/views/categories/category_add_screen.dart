import 'package:flutter/material.dart';
import 'package:meldinheiro/viewmodels/subcategory_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../models/category.dart';
import '../../models/subcategory.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _categoryName;
  String? _type;
  List<String> _subcategories = [''];

  void _addSubcategoryField() {
    setState(() {
      _subcategories.add('');
    });
  }

  void _removeSubcategoryField(int index) {
    setState(() {
      _subcategories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Categoria')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Tipo', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              Row(
                children: ['Receita', 'Despesa'].map((type) {
                  final isSelected = _type == type;
                  final isReceita = type == 'Receita';
                  final color = isReceita ? Colors.green : Colors.red;
                  final icon = isReceita ? Icons.arrow_upward : Icons.arrow_downward;
                  final backgroundColor = isReceita ? Colors.green : Colors.red;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _type = type;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.3)
                              : Theme.of(context).cardColor,
                          border: Border.all(color: color, width: isSelected ? 2 : 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundColor: backgroundColor,
                              child: Icon(icon, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type,
                              style: TextStyle(
                                fontSize: 16,
                                color: color,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text('Categoria', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nome da Categoria',
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe um nome para a categoria' : null,
                onSaved: (value) => _categoryName = value,
              ),

              const SizedBox(height: 24),
              Text('Subcategorias', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),

              ..._subcategories.asMap().entries.map((entry) {
                int index = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _subcategories[index],
                        onChanged: (value) => _subcategories[index] = value,
                        decoration: InputDecoration(
                          labelText: 'Nome da Subcategoria',
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Adicione pelo menos uma subcategoria' : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: _subcategories.length > 1
                          ? () => _removeSubcategoryField(index)
                          : null,
                    ),
                  ],
                );
              }),

              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _addSubcategoryField,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Subcategoria'),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _type != null) {
                    _formKey.currentState!.save();

                    final categoryVM = Provider.of<CategoryViewModel>(context, listen: false);
                    final subCategoryVM = Provider.of<SubCategoryViewModel>(context, listen: false);

                    // Cria e adiciona a categoria
                    final newCategory = Category(name: _categoryName!, type: _type!);
                    await categoryVM.InsertCategory(newCategory);

                    // Obtem a categoria salva com o ID (recarregado do banco após inserção)
                    final savedCategory = categoryVM.categories.lastWhere((c) => c.name == _categoryName! && c.type == _type!);

                    // Adiciona cada subcategoria relacionada
                    for (final subcategory in _subcategories) {
                      if (subcategory.trim().isEmpty) continue;
                      final newSubCategory = SubCategory(
                        name: subcategory.trim(),
                        categoryId: savedCategory.id!,
                      );
                      await subCategoryVM.insertSubCategory(newSubCategory);
                    }
                    Navigator.of(context).pop(true);

                    // Fecha a tela
                  } else if (_type == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selecione o tipo da categoria')),
                    );
                  }
                },
                child: const Text('Salvar Categoria'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
