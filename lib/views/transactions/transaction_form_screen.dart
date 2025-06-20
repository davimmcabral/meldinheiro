import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meldinheiro/viewmodels/category_viewmodel.dart';
import 'package:meldinheiro/models/subcategory.dart';
import 'package:meldinheiro/viewmodels/account_viewmodel.dart';
import 'package:meldinheiro/viewmodels/subcategory_viewmodel.dart';
import 'package:meldinheiro/viewmodels/transaction_viewmodel.dart';
import 'package:meldinheiro/views/categories/category_list_screen.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';

class TransactionFormScreen extends StatefulWidget {
  final String? initialType;
  final Function(Transaction) onSave;

  TransactionFormScreen({this.initialType, required this.onSave});

  @override
  _TransactionFormScreenState createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {

  final _formKey = GlobalKey<FormState>();
  String? _type;
  int? _categoryId;
  int? _subCategoryId;
  int? _accountId;
  String? _description;
  DateTime _date = DateTime.now();
  double? _amount;
  late MoneyMaskedTextController _amountController;


  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _type = widget.initialType!;
    }
    _amountController = MoneyMaskedTextController(
      initialValue: 0.0,
      leftSymbol: 'R\$ ',
      decimalSeparator: ',',
      thousandSeparator: '.',
    );

  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null && pickedDate != _date) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_type == null || _categoryId == null || _subCategoryId == null ||
        _accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, preencha todos os campos obrigatórios')),
      );
      return;
    }
    _formKey.currentState!.save();
    final transaction = Transaction(
      type: _type!,
      categoryId: _categoryId!,
      subCategoryId: _subCategoryId!,
      description: _description,
      date: _date,
      amount: _amount!,
      accountId: _accountId!,
    );

    Provider.of<TransactionViewModel>(context, listen: false)
        .addTransaction(transaction);
    Navigator.of(context).pop(transaction);
  }


  @override
  Widget build(BuildContext context) {
    //Provider.of<TransactionViewModel>(context, listen: false).loadTransactions();
    Provider.of<CategoryViewModel>(context, listen: false).loadCategories();
    Provider.of<SubCategoryViewModel>(context, listen: false).loadSubCategories();
    Provider.of<AccountViewModel>(context, listen: false).loadAccounts();
    final accountVM = Provider.of<AccountViewModel>(context);
    final accounts = accountVM.accounts;

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
                              ? color.withOpacity(0.1)
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




/*              GestureDetector(
                onTap: () async {
                  if (_type == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Por favor, selecione o tipo primeiro')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryListScreen(
                        type: _type!,
                        onSelect: (categoryId, subcategoryId) {
                          setState(() {
                            _categoryId = categoryId;
                            _subCategoryId = subcategoryId;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(24),
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
                        category = Provider.of<CategoryProvider>(context, listen: false)
                            .categories
                            .firstWhere((c) => c.id == _categoryId);
                      } catch (_) {
                        category = null;
                      }

                      SubCategory? subcategory;
                      try {
                        subcategory = Provider.of<CategoryProvider>(context, listen: false)
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
              ),*/
              const SizedBox(height: 12),
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
                },
                validator: (value) {
                  if (_amountController.numberValue <= 0) {
                    return 'Por favor, insira um valor válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
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

              SizedBox(height: 12.0),
              ElevatedButton.icon(
                onPressed: _saveTransaction,
                icon: const Icon(Icons.save),
                label: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
