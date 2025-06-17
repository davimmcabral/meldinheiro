import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meldinheiro/component/dateFilterWidget.dart';
import 'package:meldinheiro/models/category.dart';
import 'package:meldinheiro/models/subcategory.dart';
import 'package:meldinheiro/viewmodels/account_viewmodel.dart';
import 'package:meldinheiro/viewmodels/transaction_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../models/transaction.dart' as model;
import '../../models/account.dart';
import '../../viewmodels/category_viewmodel.dart';
import 'editTransactionScreen.dart';
import 'transaction_form_screen.dart';

class TransactionsHistoryScreen extends StatefulWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  _TransactionsHistoryScreenState createState() => _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> {
  String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    Future.microtask(() {
      Provider.of<CategoryViewModel>(context, listen: false).loadCategories();
      Provider.of<CategoryViewModel>(context, listen: false).loadSubCategories();
      Provider.of<TransactionViewModel>(context, listen: false).loadTransactions();
      Provider.of<AccountViewModel>(context, listen: false).loadAccounts();

    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryViewModel>(context);
    final transactionVM = Provider.of<TransactionViewModel>(context);
    final transactions = Provider.of<TransactionViewModel>(context).filteredTransactions;
    final accountVM = Provider.of<AccountViewModel>(context);

    final groupedTransactions = <String, List<model.Transaction>>{};
    for (var transaction in transactions) {
      final date = DateFormat('yyyy-MM-dd').format(transaction.date);
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    final sortedDates = groupedTransactions.keys.toList()..sort((a, b) => b.compareTo(a));

    //String formattedDate = DateFormat('MMMM yyyy', 'pt_BR').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Transações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () async {

            },
          ),

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DateFilterWidget(
              initialDate: transactionVM.selectedDate,
              initialPeriod: transactionVM.selectedPeriod,
              onDateChanged: (newDate, period) {
                transactionVM.setFilter(newDate, period);
              },
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
                              'Total: ${formatCurrency(totalForDate)}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: totalForDate >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...transactionsForDate.map((transaction) {
                        final Category category = categoryProvider.categories.firstWhere(
                          (cat) => cat.id == transaction.categoryId,
                          orElse: () => Category(id: 0, name: 'Categoria Removida', type: transaction.type),
                          //orElse: () => throw Exception('Categoria não encontrada para ID: ${transaction.categoryId}'),
                           );

                        final SubCategory subCategory = categoryProvider.subCategories.firstWhere(
                          (subCat) => subCat.id == transaction.subCategoryId,
                          orElse: () => SubCategory(id: 0, name: 'Subcategoria Removida', categoryId: category.id ?? 0),
                          //orElse: () => throw Exception('Subcategoria não encontrada para ID: ${transaction.subCategoryId}'),
                          );
                        final Account account = accountVM.account.firstWhere(
                            (account) => account.id == transaction.accountId,
                          orElse: () => Account(id: 0, name: 'Conta Removida', balance: 0.0, initialBalance: 0.0),
                          //orElse: () => throw Exception('Conta não encontrada para o ID: ${transaction.accountId}'),
                        );
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTransactionScreen(transaction: transaction),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Ícone da transação
                                  CircleAvatar(
                                    backgroundColor:
                                    transaction.type == 'Receita' ? Colors.green : Colors.red,
                                    child: Icon(
                                      transaction.type == 'Receita' ? Icons.add : Icons.remove,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Coluna com data, título e descrição
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Data no topo
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(transaction.date),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),

                                        // Categoria e Subcategoria
                                        Text(
                                          '${category.name} - ${subCategory.name}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        // Descrição
                                        Text(
                                          '${transaction.description}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Coluna com valor e conta
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        formatCurrency(transaction.amount),
                                        style: TextStyle(
                                          color: transaction.type == 'Receita'
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: 80, // limita o nome da conta
                                        child: Text(
                                          account.name,
                                          textAlign: TextAlign.end,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                        /*return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
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
                          title: Text('${category.name} - ${subCategory.name}'),
                          subtitle: Text('${transaction.description}', overflow: TextOverflow.ellipsis),
                          trailing: Container(
                            width: MediaQuery.of(context).size.width * 0.32,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center ,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\n${formatCurrency(transaction.amount)}',
                                  style: TextStyle(
                                    color: transaction.type == 'Receita'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                Text(
                                  account.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12),

                                ),
                              ],
                            ),
                          ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTransactionScreen(
                                      transaction: transaction),
                                ),
                              );
                            },
                          ),
                        );*/
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.remove, color: Colors.white),
              backgroundColor: Colors.red,
              label: 'Despesa',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionFormScreen(
                      initialType: 'Despesa',
                      onSave: (transaction) =>
                          transactionVM.addTransaction(transaction),
                    ),
                  ),
                );
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.green,
              label: 'Receita',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionFormScreen(
                      initialType: 'Receita',
                      onSave: (transaction) =>
                      transactionVM.addTransaction(transaction),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }
}