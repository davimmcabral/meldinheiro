import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meldinheiro/widgets/dateFilterWidget.dart';
import 'package:meldinheiro/viewmodels/category_viewmodel.dart';
import 'package:meldinheiro/viewmodels/subcategory_viewmodel.dart';
import 'package:meldinheiro/viewmodels/transaction_viewmodel.dart';

import 'package:provider/provider.dart';




class ReportsScreen extends StatefulWidget {
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  int? _touchedIndexReceita;
  int? _touchedIndexDespesa;


  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    Future.microtask(() {
      Provider.of<CategoryViewModel>(context, listen: false).loadCategories();
      Provider.of<SubCategoryViewModel>(context, listen: false).loadSubCategories();
      Provider.of<TransactionViewModel>(context, listen: false).loadTransactions();
    });
  }

  //Gerar cores aleatórias para Categorias
  final Map<String, Color> _categoryColors = {};

  Color getCategoryColor(String category) {
    if (!_categoryColors.containsKey(category)) {
      _categoryColors[category] = Color((category.hashCode * 0xFFFFFF).toRadixString(16).padLeft(6, '0').hashCode).withOpacity(1.0);
    }
    return _categoryColors[category]!;
  }

  @override
  Widget build(BuildContext context) {
    final transactionVM = Provider.of<TransactionViewModel>(context);
    final categoryVM = Provider.of<CategoryViewModel>(context);
    final subCategoryVM = Provider.of<SubCategoryViewModel>(context);
    final subCategoryMap = getSubCategoryMap(subCategoryVM);
    final categoryMap = getCategoryMap(categoryVM);
    final filteredTransactions = Provider.of<TransactionViewModel>(context).filteredTransactions; // Agora usando transações filtradas
    final totalIncome = transactionVM.totalIncome;
    final totalExpense = transactionVM.totalExpense;

    return Scaffold(
      appBar: AppBar(title: Text('Relatórios')),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            child: DateFilterWidget(
              initialDate: transactionVM.selectedDate,
              initialPeriod: transactionVM.selectedPeriod,
              onDateChanged: (newDate, period) {
                transactionVM.setFilter(newDate, period);
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Receitas por Categoria', 'Receita', Colors.green, filteredTransactions, categoryMap, totalIncome),
                  _buildPieChart('Receita', filteredTransactions, categoryMap, subCategoryMap),

                  _buildSection('Despesas por Categoria', 'Despesa', Colors.red, filteredTransactions, categoryMap, totalExpense),
                  _buildPieChart('Despesa', filteredTransactions, categoryMap, subCategoryMap),

                  _buildResult(totalIncome, totalExpense),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String type, Color color, List transactions, Map<int, String> categoryMap, double total) {
    final groupedTransactions = _groupByCategory(type, transactions, categoryMap);
    return ExpansionTile(
      title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      children: groupedTransactions.entries.map((entry) {
        final totalCategory = entry.value.fold(0.0, (sum, t) => sum + t.amount);
        final percentage = ((totalCategory / (total == 0 ? 1 : total)) * 100).toStringAsFixed(2);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: getCategoryColor(entry.key),
            radius: 8,
          ),
          title: Text('${entry.key} - ${formatCurrency(totalCategory)} (${percentage}%)',
          style: TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResult(double income, double expense) {
    final result = income - expense;
    final resultColor = result >= 0 ? Colors.green : Colors.red;
    return Column(

      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFinanceRow('Receitas', income, Colors.green),
                const Divider(),
                _buildFinanceRow('Despesas', expense, Colors.red),
                const Divider(),
                _buildFinanceRow(
                  'Resultado do Período',
                  result,
                  resultColor,
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Map<String, List> _groupByCategory(String type, List transactions, Map<int, String> categoryMap) {
    final filteredTransactions = transactions.where((t) => t.type == type).toList();
    Map<String, List> grouped = {};
    for (var t in filteredTransactions) {
      final categoryName = categoryMap[t.categoryId] ?? 'Desconhecido';
      grouped.putIfAbsent(categoryName, () => []).add(t);
    }
    return grouped;
  }

  Map<int, String> getCategoryMap(CategoryViewModel categoryVM) {
    return {for (var category in categoryVM.categories)
      if (category.id != null) category.id!: category.name};
  }

  Map<int, String> getSubCategoryMap (SubCategoryViewModel subCategoryVM) {
    return {for (var sub in subCategoryVM.subCategories)
      if (sub.id != null) sub.id!: sub.name};
  }

  Widget _buildPieChart(String type, List transactions, Map<int, String> categoryMap, Map<int, String> subCategoryMap) {
    final grouped = _groupByCategory(type, transactions, categoryMap);
    final total = grouped.values.expand((list) => list).fold(0.0, (sum, t) => sum + t.amount);

    if (total == 0) {
      return Center(child: Text("Sem dados para o gráfico"));
    }
    final entries = grouped.entries.toList();
    final touchedIndex = type == 'Receita' ? _touchedIndexReceita : _touchedIndexDespesa;
    final touchedEntry = (touchedIndex != null && touchedIndex >= 0 && touchedIndex < entries.length)
        ? entries[touchedIndex]
        : null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Distribuição de ${type == "Receita" ? "Receitas" : "Despesas"}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: List.generate(entries.length, (i) {
                    final entry = entries[i];
                    final amount = entry.value.fold(0.0, (sum, t) => sum + t.amount);
                    final percentage = amount / total;
                    final isTouched = i == touchedIndex;

                    return PieChartSectionData(
                      color: getCategoryColor(entry.key),
                      value: amount,
                      title: isTouched ? '${entry.key}\n${(percentage * 100).toStringAsFixed(1)}%' : '',
                      radius: isTouched ? 60 : 50,
                      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, backgroundColor: Colors.black),
                    );
                  }),
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (response == null || response.touchedSection == null) {
                        return;
                      }
                      setState(() {
                        final index = response.touchedSection!.touchedSectionIndex;
                        if (type == 'Receita') {
                          _touchedIndexReceita = index;
                        } else {
                          _touchedIndexDespesa = index;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),

            if (touchedEntry != null) ...[
              SizedBox(height: 12),
              Text(
                'Categoria: ${touchedEntry.key}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Total: ${formatCurrency(touchedEntry.value.fold(0.0, (sum, t) => sum + t.amount))}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              ...touchedEntry.value.map<Widget>((t) {
                  final subCategoryName = subCategoryMap[t.subCategoryId] ?? 'Sem subcategoria';
                   return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(subCategoryName),
                subtitle: Text('${formatCurrency(t.amount)} - ${t.date.day}/${t.date.month}/${t.date.year}'),
              );}),
            ]
          ],
        ),
      ),
    );
  }
  Widget _buildFinanceRow(String label, double value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '${formatCurrency(value)}',
          style: TextStyle(
            fontSize: 18,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

}


