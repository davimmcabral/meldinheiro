import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/transactionProvider.dart';

class TransactionsAnalysisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionViewModel>(context);
    final transactions = transactionProvider.transactions;

    final incomeData = _groupTransactionsByCategory(transactions, 'Receita');
    final expenseData = _groupTransactionsByCategory(transactions, 'Despesa');

    return Scaffold(
      appBar: AppBar(title: Text('Análise de Transações')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Gráfico de Despesas e Receitas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(child: _buildPieChart(expenseData, 'Despesas', Colors.red)),
            Expanded(child: _buildPieChart(incomeData, 'Receitas', Colors.green)),
          ],
        ),
      ),
    );
  }

  Map<int, double> _groupTransactionsByCategory(List<Transaction> transactions, String type) {
    Map<int, double> categoryTotals = {};

    for (var transaction in transactions.where((t) => t.type == type)) {
      categoryTotals[transaction.categoryId] =
          (categoryTotals[transaction.categoryId] ?? 0) + transaction.amount;
    }

    return categoryTotals;
  }

  Widget _buildPieChart(Map<int, double> data, String title, Color color) {
    final total = data.values.fold(0.0, (sum, value) => sum + value);

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Expanded(
            child: data.isEmpty
                ? Center(child: Text('Sem dados'))
                : PieChart(
              PieChartData(
                sections: data.entries.map((entry) {
                  final percentage = (entry.value / total) * 100;
                  final opacity = ((entry.value / total) + 0.3).clamp(0.0, 1.0);
                  return PieChartSectionData(
                    value: entry.value,
                    title: '${entry.key} (${percentage.toStringAsFixed(1)}%)',
                    color: color.withOpacity(opacity),
                    radius: 50,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
