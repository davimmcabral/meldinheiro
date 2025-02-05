import 'package:flutter/material.dart';
import 'package:meldinheiro/models/transacoesFormulario.dart';
import 'package:meldinheiro/models/transaction.dart';
import 'package:meldinheiro/models/transactionForm.dart';
import 'package:meldinheiro/models/transactionProvider.dart';
import 'package:meldinheiro/screens/dashboard.dart';
import 'package:meldinheiro/screens/dashboardNovo.dart';
import 'package:meldinheiro/screens/dashboardScreen.dart';
import 'package:provider/provider.dart';

import 'models/transaction_history.dart';
import 'models/transactionsHistory.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
      ], child: const MelDinheiro(),
    ),
  );
}


class MelDinheiro extends StatelessWidget {
  const MelDinheiro({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home:  //TransactionForm(onSave: (Transaction) {  },),
       //TransactionsHistoryPage(),
      DashboardScreen(),//DashboardNovo(transactions: [],),
    );
  }
}
