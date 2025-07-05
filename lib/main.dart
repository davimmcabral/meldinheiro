import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meldinheiro/viewmodels/category_viewmodel.dart';
import 'package:meldinheiro/viewmodels/account_viewmodel.dart';
import 'package:meldinheiro/viewmodels/subcategory_viewmodel.dart';
import 'package:meldinheiro/viewmodels/transaction_viewmodel.dart';
import 'package:meldinheiro/views/homepage/home_page_screen.dart';
import 'package:meldinheiro/theme/honeytheme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  final accountViewModel = AccountViewModel();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountViewModel>.value(value: accountViewModel),
        ChangeNotifierProvider(create: (_) => TransactionViewModel(accountViewModel: accountViewModel)),
        //ChangeNotifierProvider<TransactionViewModel>.value(value: transactionViewModel),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => SubCategoryViewModel()),
      ],
      child: const MelDinheiro(),
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
      theme: honeyTheme,
      home: HomePage(),
    );
  }
}
