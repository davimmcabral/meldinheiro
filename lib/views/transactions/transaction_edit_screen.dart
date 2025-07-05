import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meldinheiro/models/subcategory.dart';
import 'package:meldinheiro/models/transaction.dart';
import 'package:meldinheiro/viewmodels/account_viewmodel.dart';
import 'package:meldinheiro/viewmodels/subcategory_viewmodel.dart';
import 'package:meldinheiro/viewmodels/transaction_viewmodel.dart';
import 'package:provider/provider.dart';
import '../categories/category_list_screen.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../models/category.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  EditTransactionScreen({required this.transaction});

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late int? _categoryId;
  late int? _subCategoryId;
  late int? _accountId;
  late String? _description;
  late DateTime _date;
  late double? _amount;
  late MoneyMaskedTextController _amountController;


  @override
  void initState() {
    super.initState();
    _type = widget.transaction.type;
    _categoryId = widget.transaction.categoryId;
    _subCategoryId = widget.transaction.subCategoryId;
    _accountId = widget.transaction.accountId;
    _description = widget.transaction.description;
    _date = widget.transaction.date;
    _amount = widget.transaction.amount;
    _amountController = MoneyMaskedTextController(
      initialValue: _amount,
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
        categoryId: _categoryId!,
        subCategoryId: _subCategoryId!,
        description: _description,
        date: _date,
        amount: _amount!,
        accountId: _accountId!,
      );
      Provider.of<TransactionViewModel>(context, listen: false)
          .updateTransaction(updatedTransaction);
      Navigator.of(context).pop(updatedTransaction);
    }
  }

  void _deleteTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Provider.of<TransactionViewModel>(context, listen: false)
          .deleteTransaction(widget.transaction.id!);
      Navigator.of(context).pop('delete'); // fecha a tela após exclusão
    }
  }

  /*void _deleteTransaction() async {
    Provider.of<TransactionViewModel>(context, listen: false)
        .deleteTransaction(widget.transaction.id!);
    Navigator.of(context).pop('delete');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final accountVM = Provider.of<AccountViewModel>(context);
    final accounts = accountVM.accounts;

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
              Text('Tipo', style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: 12),
              Row(
                children: ['Receita', 'Despesa'].map((type) {
                  final isSelected = _type == type;
                  final isReceita = type == 'Receita';
                  final color = isReceita ? Colors.green : Colors.red;
                  final icon = isReceita ? Icons.add : Icons.remove;
                  final backgroundColor = isReceita ? Colors.green : Colors.red;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _type = type;
                          _categoryId = null;
                          _subCategoryId = null;
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
              SizedBox(height: 12),
              FormField<bool>(
                validator: (value) {
                  if (_categoryId == null || _subCategoryId == null) {
                    return 'Por favor, selecione uma categoria e subcategoria';
                  }
                  return null;
                },
                builder: (state) {
                  return GestureDetector(
                    onTap: () async {
                      if (_type == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Selecione o tipo antes de escolher a categoria.')),
                        );
                        return;
                      }

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryListScreen(
                            type: _type!,
                            onSelect: (categoryId, subcategoryId) {
                              setState(() {
                                _categoryId = categoryId;
                                _subCategoryId = subcategoryId;
                              });
                              state.didChange(true); // Atualiza o erro visual
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(12),
                        labelText: 'Categoria e Subcategoria',
                        prefixIcon: const Icon(Icons.category),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: state.errorText,

                      ),
                      child: Builder(
                        builder: (context) {
                          Category? category;
                          try {
                            category = Provider.of<CategoryViewModel>(context, listen: false)
                                .categories
                                .firstWhere((c) => c.id == _categoryId);
                          } catch (_) {
                            category = null;
                          }

                          SubCategory? subcategory;
                          try {
                            subcategory = Provider.of<SubCategoryViewModel>(context, listen: false)
                                .subCategories
                                .firstWhere((s) => s.id == _subCategoryId);
                          } catch (_) {
                            subcategory = null;
                          }
                          if (category != null && subcategory != null && category.name.isNotEmpty && subcategory.name.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subcategory.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return const Text(
                              'Selecionar Categoria e Subcategoria',
                              style: TextStyle(color: Colors.grey),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12),

              DropdownButtonFormField<int>(
                isExpanded: true,
                value: _accountId,
                decoration: InputDecoration(
                  labelText: 'Conta',
                  prefixIcon: const Icon(Icons.account_balance),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: accounts
                    .map((account) => DropdownMenuItem(
                  value: account.id,
                  child: Text(
                    account.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _accountId = value!;
                  });
                },
                validator: (value) =>
                value == null ? 'Por favor, selecione uma conta' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: const Icon(Icons.description),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onSaved: (value) {
                  _description = value;
                },
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Valor',
                  prefixIcon: const Icon(Icons.attach_money),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _amount = _amountController.numberValue;
                  //_amount = double.tryParse(value!);
                },
                validator: (value) {
                  final value = _amountController.numberValue;
                  return value <= 0 ? 'Informe um valor válido' : null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                onTap: _selectDate,
                controller: TextEditingController(
                  text: DateFormat('dd/MM/yyyy').format(_date),
                ),
                decoration: InputDecoration(
                  labelText: 'Data',
                  prefixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _saveTransaction,
                label: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
