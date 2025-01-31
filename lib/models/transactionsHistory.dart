import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meldinheiro/models/transactionForm.dart';

import 'category.dart';


class TransactionsHistory extends StatefulWidget {
  @override
  _TransactionsHistoryState createState() => _TransactionsHistoryState();
}

class _TransactionsHistoryState extends State<TransactionsHistory> {

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
  }
  // Lista de lançamentos simulada (dados internos)
  List<Map<String, dynamic>> transactions = [
    {
      'type': 'Despesa',
      'category': 'Alimentação',
      'subCategory': 'Restaurantes',
      'date': '2025-01-18',
      'amount': -45.90,
    },
    {
      'type': 'Receita',
      'category': 'Salário',
      'subCategory': 'Mensal',
      'date': '2025-01-17',
      'amount': 5000.00,
    },
    {
      'type': 'Despesa',
      'category': 'Transporte',
      'subCategory': 'Combustível',
      'date': '2025-01-17',
      'amount': -120.00,
    },
    {
      'type': 'Despesa',
      'category': 'Saúde',
      'subCategory': 'Medicamentos',
      'date': '2025-01-17',
      'amount': -30.50,
    },
    {
      'type': 'Despesa',
      'category': 'Alimentação',
      'subCategory': 'Supermercado',
      'date': '2025-01-16',
      'amount': -200.75,
    },{
      'type': 'Despesa',
      'category': 'Alimentação',
      'subCategory': 'Restaurantes',
      'date': '2025-01-18',
      'amount': 45.90,
    },

  ];


  //Visualização por mês/ano selecionados
  DateTime selectedDate = DateTime.now();


  void _navigateMonth(int offset) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + offset, 1);
    });
  }


  void navigateToEditTransaction(Map<String, dynamic> transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionPage(transaction: transaction),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          if (result == 'delete') {
            transactions.remove(transaction);
          } else {
            final index = transactions.indexOf(transaction);
            transactions[index] = result;
          }
        });
      }
    });
  }

  List<Map<String, dynamic>> getFilteredTransactions() {
    final selectedYear = selectedDate.year;
    final selectedMonth = selectedDate.month;
    return transactions.where((transaction) =>
        int.parse(transaction['date'].split('-')[0]) == selectedYear &&
        int.parse(transaction['date'].split('-')[1]) == selectedMonth).toList();
  }

  void _addTransaction(Map<String, dynamic> transaction) {
    setState(() {
      if (transaction['type'] == 'Despesa' && transaction['amount'] > 0) {
        transaction['amount'] = -transaction['amount'];
      }
      transactions.add(transaction);
      transactions.sort((a, b) => b['date'].compareTo(a['date'])); // Ordena por data
    });
  }


  List<Map<String, dynamic>> getFilteredTransactionsCategory({
    String? category,
    String? subCategory,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) {
    // ... (código existente)

    return transactions.where((transaction) {
      final transactionDate = DateTime.parse(transaction['date']);
      return (category == null || transaction['category'] == category) &&
          (subCategory == null || transaction['subCategory'] == subCategory) &&
          (minAmount == null || transaction['amount'] >= minAmount) &&
          (maxAmount == null || transaction['amount'] <= maxAmount) &&
          (startDate == null || transactionDate.isAfter(startDate)) &&
          (endDate == null || transactionDate.isBefore(endDate));
    }).toList();
  }
  /*//lista funcionando
  List<Map<String, dynamic>> getFilteredTransactions() {
    String selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
    return transactions
        .where((transaction) => transaction['date'].startsWith(selectedMonth))
        .toList();
  }*/

 /* List<Map<String, dynamic>> getFilteredTransactions() {
    final selectedMonthYear = DateFormat('y-MMMM').format(selectedDate);
    String selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
    return transactions
        .where((transaction){
          final transactionDate = DateTime.parse(transaction['date']);
          final selectedMonthYearDateTime = DateTime.parse(selectedMonthYear);
          return transactionDate.year == selectedMonthYearDateTime.year &&
            transactionDate.month == selectedMonthYearDateTime.month;
        }).toList();
  }*/

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = getFilteredTransactions();

    // Agrupando lançamentos por data
    final Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in filteredTransactions) {
      final date = transaction['date'];
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _navigateMonth(-1),
                  icon: const Icon(Icons.arrow_left),
                ),
                Text(
                  DateFormat('MMMM y', 'pt_BR').format(selectedDate),
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () => _navigateMonth(1),
                ),
              ],
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  return ListView.builder(
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final date = sortedDates[index];
                      final transactionsForDate = groupedTransactions[date]!;
                      final totalForDate = transactionsForDate.fold<double>(
                        0.0,
                            (sum, transaction) => transaction['type'] == 'Receita'
                            ? sum + (transaction['amount'] ?? 0.0)
                            : sum - (transaction['amount'] ?? 0.0),
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(DateTime.parse(date)),
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                Text(
                                  'Total: R\$ ${totalForDate.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: totalForDate >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...transactionsForDate.map((transaction) => Card(
                            margin: EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: transaction['type'] == 'Receita'
                                    ? Colors.green
                                    : Colors.red,
                                child: Icon(
                                  transaction['type'] == 'Receita'
                                      ? Icons.add
                                      : Icons.remove,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                transaction['category'] ?? 'Categoria desconhecida',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${transaction['subCategory'] ?? 'Subcategoria desconhecida'}'
                              ),
                              trailing: Text(
                                '\nR\$ ${transaction['amount']?.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(
                                  color: transaction['amount'] >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              onTap: () => navigateToEditTransaction(transaction),
                            ),
                          ))
                        ],
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionForm(
                onSave: (transaction) {
                  final transactionMap = {
                    'type': transaction.type,
                    'category': transaction.category,
                    'subCategory': transaction.subCategory,
                    'date': transaction.date.toIso8601String().split('T').first,
                    'amount': transaction.amount,
                  };
                  _addTransaction(transactionMap);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class EditTransactionPage extends StatefulWidget {
  final Map<String, dynamic> transaction;

  EditTransactionPage({required this.transaction});

  @override
  _EditTransactionPageState createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  late String selectedType; // Receita ou Despesa
  late String selectedCategory; // Categoria selecionada
  late String selectedSubCategory; // Subcategoria selecionada
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Inicializar os valores com base na transação recebida
    selectedType = widget.transaction['type'];
    selectedCategory = widget.transaction['category'];
    selectedSubCategory = widget.transaction['subCategory'];
    _amountController = TextEditingController(
      text: widget.transaction['amount'].abs().toString(),
    );
    _dateController = TextEditingController(text: widget.transaction['date']);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(widget.transaction['date']),
      firstDate: DateTime(1900),
      lastDate: DateTime(2999),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar as categorias disponíveis com base no tipo selecionado
    final filteredCategories = CategoryModel.categories
        .where((category) => category.type == selectedType)
        .toList();

    // Encontrar as subcategorias para a categoria selecionada
    final subCategories = filteredCategories
        .firstWhere((category) => category.category == selectedCategory)
        .subCategories.toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Transação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Navigator.pop(context, 'delete'); // Indica exclusão da transação
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(selectedType),


              /*DropdownButtonFormField<String>(
                value: selectedType,
                items: ['Receita', 'Despesa']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedType = value;
                      // Atualizar a categoria quando o tipo mudar
                      selectedCategory = filteredCategories.isNotEmpty
                          ? filteredCategories[0].category
                          : '';
                      selectedSubCategory = '';
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),*/
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: filteredCategories
                    .map((category) => DropdownMenuItem(
                  value: category.category,
                  child: Text(category.category),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                      // Atualizar a subcategoria quando a categoria mudar
                      selectedSubCategory =
                      (subCategories.isNotEmpty ? subCategories[0] : '');
                    });
                  }
                },
                validator: (value) => value == null
                    ? 'Por favor, selecione a categoria'
                    : null,
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              DropdownButtonFormField<String>(
                value: subCategories.contains(selectedSubCategory)
                    ? selectedSubCategory
                    : null,
                items: subCategories
                    .map((subCategory) => DropdownMenuItem(
                  value: subCategory,
                  child: Text(subCategory),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedSubCategory = value;
                    });
                  }
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, selecione a subcategoria'
                    : null,
                decoration: const InputDecoration(labelText: 'Subcategoria'),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Data'),
                readOnly: true,
                onTap: _selectDate,
              ),
              const SizedBox(height: 20.0),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    final updatedTransaction = {
                      'type': selectedType,
                      'category': selectedCategory,
                      'subCategory': selectedSubCategory,
                      'date': _dateController.text,
                      'amount': selectedType == 'Despesa'
                          ? -(double.tryParse(_amountController.text) ?? 0.0)
                          : (double.tryParse(_amountController.text) ?? 0.0),
                    };
                    Navigator.pop(context, updatedTransaction);
                  }
                  },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



