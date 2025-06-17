import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meldinheiro/viewmodels/account_viewmodel.dart';
import 'package:meldinheiro/viewmodels/transaction_viewmodel.dart';
import 'package:meldinheiro/views/transactions/transaction_list_screen.dart';
import 'package:meldinheiro/widgets/accountSummaryCard.dart';
import 'package:provider/provider.dart';
import '../component/dateFilterWidget.dart';
import '../data/db/database.dart';


class DashboardScreen extends StatefulWidget {

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TransactionViewModel>(context, listen: false).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionVM = Provider.of<TransactionViewModel>(context);
    final accountVM = Provider.of<AccountViewModel>(context);

    Future<void> _deleteDatabase() async {
      await DatabaseHelper.instance.deleteDatabaseFile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banco de dados deletado com sucesso!')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child:
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 16.0),
                child: DateFilterWidget(
                  initialDate: transactionVM.selectedDate,
                  initialPeriod: transactionVM.selectedPeriod,
                  onDateChanged: (newDate, period) {
                    transactionVM.setFilter(newDate, period);
                  },
                ),
              ),
              // Saldo total
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber[600],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 24),
                        Text('Saldo Total', style: TextStyle(color: Colors.black87, fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${formatCurrency(accountVM.balance,)}',
                      //'R\$ ${provider.balance.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Entradas e saídas
              Row(
                children: [
                  // Card de RECEITAS
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.add, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Receitas',
                                  style: TextStyle(color: Colors.green[900]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatCurrency(transactionVM.totalIncome),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[900],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Card de DESPESAS
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.remove, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Despesas',
                                  style: TextStyle(color: Colors.red[900]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatCurrency(transactionVM.totalExpense),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[900],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              /*Row(
                children: [
                  // Receita
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.add, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Receitas', style: TextStyle(color: Colors.green[900])),
                              SizedBox(height: 4),
                              Text(
                                formatCurrency(transactionProvider.income),
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Despesa
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      //margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.remove, color: Colors.white, size: 24),
                          ),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Despesas', style: TextStyle(color: Colors.red[900])),
                              SizedBox(height: 4),
                              Text(
                                formatCurrency(transactionProvider.expense),
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[900]),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),*/
              SizedBox(height: 20),

              const AccountSummaryCard(),

              SizedBox(height: 20),

             /* ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionsHistoryScreen(),
                    ),
                  );
                  setState((){});
                },
                child: Text('Ver Histórico de Transações'),
              ),*/
              ElevatedButton(
                onPressed: _deleteDatabase,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Deletar Banco de Dados', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
