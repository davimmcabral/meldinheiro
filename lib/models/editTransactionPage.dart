import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meldinheiro/models/transaction.dart';
import '../database/database.dart';
import 'category.dart';

class EditTransactionPage extends StatefulWidget {
  final Transaction transaction;

  EditTransactionPage({required this.transaction});

  @override
  _EditTransactionPageState createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late String _category;
  late String _subCategory;
  late String? _description;
  late DateTime _date;
  late double _amount;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction.type;
    _category = widget.transaction.category;
    _subCategory = widget.transaction.subCategory;
    _description = widget.transaction.description;
    _date = widget.transaction.date;
    _amount = widget.transaction.amount;
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

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedTransaction = Transaction(
        id: widget.transaction.id,
        type: _type,
        category: _category,
        subCategory: _subCategory,
        description: _description,
        date: _date,
        amount: _amount,
      );

      await DatabaseHelper.instance.updateTransaction(updatedTransaction);
      Navigator.of(context).pop(updatedTransaction);
    }
  }

  void _deleteTransaction() async {
    await DatabaseHelper.instance.deleteTransaction(widget.transaction.id!);
    Navigator.of(context).pop('delete');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Transação'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteTransaction,
          ),
        ],
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
                    _type = value!;
                  });
                },
                validator: (value) =>
                value == null ? 'Por favor, selecione o tipo' : null,
              ),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(labelText: 'Categoria'),
                items: CategoryModel.categories
                    .map((category) => DropdownMenuItem(
                  value: category.category,
                  child: Text(category.category),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                    _subCategory = '';
                  });
                },
                validator: (value) =>
                value == null ? 'Por favor, selecione a categoria' : null,
              ),
              DropdownButtonFormField<String>(
                value: _subCategory,
                decoration: InputDecoration(labelText: 'Subcategoria'),
                items: CategoryModel.categories
                    .firstWhere((cat) => cat.category == _category)
                    .subCategories
                    .map((subCategory) => DropdownMenuItem(
                  value: subCategory,
                  child: Text(subCategory),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _subCategory = value!;
                  });
                },
                validator: (value) => value == null
                    ? 'Por favor, selecione a subcategoria'
                    : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Descrição'),
                onSaved: (value) {
                  _description = value;
                },
              ),
              TextFormField(
                initialValue: _amount.toString(),
                decoration: InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _amount = double.tryParse(value!) ?? 0.0;
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
                child: Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
