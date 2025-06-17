import 'package:flutter/material.dart';
import 'package:meldinheiro/views/transactionFilterPage.dart';
import 'package:meldinheiro/views/transactions/transaction_list_screen.dart';
import 'package:meldinheiro/views/dashboard_screen.dart';
import 'package:meldinheiro/views//reports_screen.dart';
import 'package:meldinheiro/views/transactionAnalysisPage.dart';
import 'package:meldinheiro/views/categories/categoryListScreen.dart';
import 'accounts/addAccountScreen.dart';
import 'categories/addCategoryScreen.dart';
import 'budgetPage.dart';
import 'categories/editCategoryScreen.dart';

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

  setPaginaAtual(pagina) {
    setState(() {
      paginaAtual = pagina;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        children: [
          DashboardScreen(),
          TransactionsHistoryScreen(),
          ReportsScreen(),
          //TransactionFilterPage(currentFilters: {},),
          //AddBudgetPage(),
          //EditCategoryScreen(),
          //AddAccountCard(),

          //TransactionsAnalysisPage(),
          //TransactionsHistory(),
        ],
        onPageChanged: setPaginaAtual,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaAtual,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Transações'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Relatórios'),
          //BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Conta'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Conta'),

        ],
        onTap: (pagina) {
          pc.animateToPage(
            pagina,
            duration: Duration(milliseconds: 400),
            curve: Curves.ease,
          );
        },
        // backgroundColor: Colors.grey[100],
      ),
    );
  }
}
