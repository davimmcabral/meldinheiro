import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meldinheiro/models/transactionProvider.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart' as model;
import 'editTransactionPage.dart';
import 'transactionForm.dart';

class TransactionsHistoryPage extends StatefulWidget {
  const TransactionsHistoryPage({super.key});

  @override
  _TransactionsHistoryPageState createState() => _TransactionsHistoryPageState();
}

class _TransactionsHistoryPageState extends State<TransactionsHistoryPage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    Future.microtask(() =>
        Provider.of<TransactionProvider>(context, listen: false).loadTransactions());
  }

  void _navigateMonth(int offset) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + offset, 1);
    });
    Future.microtask(() =>
        Provider.of<TransactionProvider>(context, listen: false).loadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions.where((transaction) {
      return transaction.date.year == selectedDate.year &&
          transaction.date.month == selectedDate.month;
    }).toList();
    final groupedTransactions = <String, List<model.Transaction>>{};

    for (var transaction in transactions) {
      final date = DateFormat('yyyy-MM-dd').format(transaction.date);
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    final sortedDates = groupedTransactions.keys.toList()..sort((a, b) => b.compareTo(a));


    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Transações')),
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
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTransactionPage(transaction: transaction),
                              ),
                            );

                            if (result == 'delete') {
                              await transactionProvider.deleteTransaction(transaction.id!);
                            } else if (result is model.Transaction) {
                              await transactionProvider.updateTransaction(result);
                            }
                          },
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
                onSave: (transaction) => transactionProvider.addTransaction(transaction),
              ),
            ),
          );
        },
      ),
    );
  }
}

    /*ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            title: Text(transaction.category ?? 'Sem categoria'),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(transaction.date)),
            trailing: Text('R\$ ${transaction.amount.toStringAsFixed(2)}'),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTransactionPage(transaction: transaction),
                ),
              );

              if (result == 'delete') {
                await transactionProvider.deleteTransaction(transaction.id!);
              } else if (result is model.Transaction) {
                await transactionProvider.updateTransaction(result);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionForm(
                onSave: (transaction) => transactionProvider.addTransaction(transaction),
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
*/