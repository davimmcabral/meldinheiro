import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database.dart';
import 'category.dart';
import 'transaction.dart'; // Certifique-se de importar suas classes

class TransactionForm extends StatefulWidget {
  final Function(Transaction) onSave;

  TransactionForm({required this.onSave});

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  String? _type;
  String? _category;
  String? _subCategory;
  String? _description;
  DateTime _date = DateTime.now();
  double? _amount;

  List<String> getCategories(String type) {
    return CategoryModel.categories
        .where((category) => category.type == type)
        .map((category) => category.category)
        .toList();
  }

  List<String> getSubCategories(String category) {
    return CategoryModel.categories
        .firstWhere((cat) => cat.category == category)
        .subCategories;
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2999),
    );
    if (pickedDate != null && pickedDate != _date) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final transaction = Transaction(
        type: _type!,
        category: _category!,
        subCategory: _subCategory!,
        description: _description,
        date: _date,
        amount: _amount!,
      );
      // Salva no banco de dados usando DatabaseHelper
      await DatabaseHelper.instance.insertTransaction(transaction);
      // Chama a função de callback para atualizar a tela anterior
      widget.onSave(transaction);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Transação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(labelText: 'Tipo'),
                items: ['Receita', 'Despesa']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value;
                    _category = null;
                    _subCategory = null;
                  });
                },
                validator: (value) =>
                value == null ? 'Por favor, selecione o tipo' : null,
              ),
              if (_type != null)
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(labelText: 'Categoria'),
                  items: getCategories(_type!).map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _category = value;
                      _subCategory = null;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Por favor, selecione a categoria' : null,
                ),
              if (_category != null)
                DropdownButtonFormField<String>(
                  value: _subCategory,
                  decoration: InputDecoration(labelText: 'Subcategoria'),
                  items: getSubCategories(_category!).map((subCategory) {
                    return DropdownMenuItem(
                      value: subCategory,
                      child: Text(subCategory),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _subCategory = value;
                    });
                  },
                  validator: (value) => value == null
                      ? 'Por favor, selecione a subcategoria'
                      : null,
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Descrição'),
                onSaved: (value) {
                  _description = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _amount = double.tryParse(value!);
                },
                validator: (value) =>
                value == null || double.tryParse(value) == null
                    ? 'Por favor, insira um valor válido'
                    : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Data: ${DateFormat('dd/MM/yyyy').format(_date)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _selectDate,
                    child: Text('Selecionar Data'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveTransaction,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
