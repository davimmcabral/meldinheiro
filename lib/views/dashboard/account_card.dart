import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meldinheiro/models/account.dart';
import 'package:meldinheiro/viewmodels/account_viewmodel.dart';
import 'package:meldinheiro/viewmodels/transaction_viewmodel.dart';
import 'package:meldinheiro/views/accounts/editAccountScreen.dart';
import 'package:provider/provider.dart';
import '../accounts/addAccountScreen.dart';

class AccountSummaryCard extends StatelessWidget {

  const AccountSummaryCard({Key? key,}) : super(key: key);

  String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountViewModel>(
      builder: (context, accountVM, child) {
        final accounts = accountVM.accounts;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título e botões
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Minhas Contas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),

                ],
              ),

              SizedBox(height: 8),
              Divider(),
              SizedBox(height: 8),

              // Lista de contas
              Column(
                children: accounts.map((account) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),

                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditAccountScreen(account: account)),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet_rounded, color: Colors.blueGrey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              account.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                          Text(
                            formatCurrency(account.balance),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: account.balance >= 0 ? Colors.green : Colors.red,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              /*Column(
                children: accounts.map((account) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      account.name,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Saldo: ${formatCurrency(account.balance)}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: Icon(Icons.account_balance_wallet_rounded, color: Colors.blueGrey),
                    onTap: () {
                      //_editAccount(context, account);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditAccountScreen(account: account)),
                      );
                    },
                  );
                }).toList(),
              ),*/
              /*...accounts.map((account) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[600],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      account.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Saldo: ${formatCurrency(account.balance)}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: Icon(Icons.account_balance_wallet_rounded, color: Colors.blueGrey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccountScreen()),
                      );
                    },
                  ),
                );
              }).toList(),*/

              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.account_balance),
                  label: Text('Adicionar Conta'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddAccountScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meldinheiro/models/account.dart';
import 'package:meldinheiro/models/transaction_viewmodel.dart';
import 'package:provider/provider.dart';

import '../screens/accountScreen.dart';

class AccountSummaryCard extends StatelessWidget {

  String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }
  //final List<Account> accounts;
  final VoidCallback onEdit;
  final VoidCallback onAdd;

  const AccountSummaryCard({
    Key? key,
    //required this.accounts,
    required this.onEdit,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final accounts = transactionProvider.account;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Minhas Contas',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          alignment: AlignmentDirectional.centerEnd,
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: onEdit,
                        ),
                      ],
                    ),
                    IconButton(
                      alignment: AlignmentDirectional.centerEnd,
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: onAdd,
                    ),
                  ],
                ),

                Divider(),
                Column(
                  children: accounts.map((account) {
                    return ListTile(
                      title: Text(
                        account.name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Saldo: ${formatCurrency(account.balance)}',
                        style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                      ),
                      onTap: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AccountScreen(),
                            ),
                          ),
                    );
                  }).toList(),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: onAdd,
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountScreen(),
                      ),
                    );
                  },
                  child: Text('Ver Detalhes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
*/
