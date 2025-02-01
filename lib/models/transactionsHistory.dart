import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meldinheiro/models/transactionForm.dart';
import 'package:meldinheiro/models/transaction.dart' as model;
import '../database/database.dart';
import 'editTransactionPage.dart';


class TransactionsHistory extends StatefulWidget {
  @override
  _TransactionsHistoryState createState() => _TransactionsHistoryState();
}
class _TransactionsHistoryState extends State<TransactionsHistory> {
  List<model.Transaction> _transactions = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _transactions = [];
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await DatabaseHelper.instance.getTransactions();
    setState(() {
      _transactions = transactions;
    });
  }

  void _navigateMonth(int offset) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + offset, 1);
    });
    _loadTransactions(); // Recarrega os dados ao mudar de mês
  }

  List<model.Transaction> getFilteredTransactions() {
    return _transactions.where((transaction) {
      return transaction.date.year == selectedDate.year &&
          transaction.date.month == selectedDate.month;
    }).toList();
  }

  void _addTransaction(model.Transaction transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    _loadTransactions(); // Recarrega os dados do banco após inserção
  }

  void navigateToEditTransaction(model.Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionPage(transaction: transaction),
      ),
    ).then((result) {
      if (result != null) {
        if (result == 'delete') {
          DatabaseHelper.instance.deleteTransaction(transaction.id!);
        } else {
          DatabaseHelper.instance.updateTransaction(result);
        }
        _loadTransactions(); // Recarrega os dados após edição ou exclusão
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = getFilteredTransactions();
    final groupedTransactions = <String, List<model.Transaction>>{};

    for (var transaction in filteredTransactions) {
      final date = DateFormat('yyyy-MM-dd').format(transaction.date);
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    final sortedDates = groupedTransactions.keys.toList()..sort((a, b) => b.compareTo(a));

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
              child: ListView.builder(
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final transactionsForDate = groupedTransactions[date]!;
                  final totalForDate = transactionsForDate.fold<double>(
                    0.0,
                        (sum, transaction) => transaction.type == 'Receita'
                        ? sum + transaction.amount
                        : sum - transaction.amount,
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
                            backgroundColor: transaction.type == 'Receita'
                                ? Colors.green
                                : Colors.red,
                            child: Icon(
                              transaction.type == 'Receita'
                                  ? Icons.add
                                  : Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            transaction.category ?? 'Categoria desconhecida',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(transaction.subCategory ?? 'Subcategoria desconhecida'),
                          trailing: Text(
                            '\nR\$ ${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: transaction.amount >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                          onTap: () => navigateToEditTransaction(transaction),
                        ),
                      )),
                    ],
                  );
                },
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
                onSave: (transaction) => _addTransaction(transaction),
              ),
            ),
          ).then((newTransaction) {
            if (newTransaction != null) {
              _loadTransactions(); // Recarrega os dados após edição ou exclusão
            }
          });;
        },
      ),
    );
  }
}




  /*List<Map<String, dynamic>> getFilteredTransactionsCategory({
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
  }*/
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




