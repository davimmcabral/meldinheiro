import 'package:flutter/material.dart';
import 'package:meldinheiro/viewmodels/account_viewmodel.dart';
import 'package:meldinheiro/viewmodels/transaction_viewmodel.dart';
import 'package:meldinheiro/views/transactions/transaction_list_screen.dart';
import 'package:meldinheiro/views/dashboard/dashboard_screen.dart';
import 'package:meldinheiro/views/reports/reports_screen.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int paginaAtual = 0;
  late PageController pc;

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }

  void _onPageChanged(int index) async {
    setState(() {
      paginaAtual = index;
    });

    if (index == 0) {
      final transactionVM = context.read<TransactionViewModel>();
      final accountVM = context.read<AccountViewModel>();

      await transactionVM.loadTransactions();
      await accountVM.updateBalancesWithTransactions(transactionVM.transactions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        onPageChanged: _onPageChanged,
        children: [
          DashboardScreen(),
          TransactionsHistoryScreen(),
          ReportsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaAtual,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Transações'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Relatórios'),
        ],
        onTap: (pagina) {
          pc.animateToPage(
            pagina,
            duration: Duration(milliseconds: 400),
            curve: Curves.ease,
          );
        },
         backgroundColor: Colors.grey[100],
      ),
    );
  }
}
