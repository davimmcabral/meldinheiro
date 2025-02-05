import 'package:flutter/material.dart';
import 'package:meldinheiro/models/transaction_history.dart';
import 'package:provider/provider.dart';
import '../models/transactionProvider.dart';
import '../models/transactionsHistory.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text('Entradas'),
                trailing: Text(
                  'R\$ ${transactionProvider.income.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.green, fontSize: 18),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Saídas'),
                trailing: Text(
                  'R\$ ${transactionProvider.expense.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Saldo'),
                trailing: Text(
                  'R\$ ${transactionProvider.balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transactionProvider.balance >= 0
                        ? Colors.green
                        : Colors.red,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionsHistoryPage(),
                  ),
                );
              },
              child: Text('Ver Histórico de Transações'),
            ),
          ],
        ),
      ),
    );
  }
}
