import 'package:flutter/material.dart';
import 'package:meldinheiro/models/transactionProvider.dart';
import 'package:provider/provider.dart';
import 'package:meldinheiro/widgets/accountCard.dart';
import '../../models/account.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<TransactionViewModel>(context);
    final accounts = accountProvider.account;

    void _editAccount(BuildContext context, Account account) {
      TextEditingController nameController = TextEditingController(text: account.name);
      TextEditingController balanceController = TextEditingController(text: account.balance.toString());

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Editar Conta'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nome da Conta'),
                ),
                TextField(
                  controller: balanceController,
                  decoration: InputDecoration(labelText: 'Saldo'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  String newName = nameController.text;
                  double? newBalance = double.tryParse(balanceController.text);

                  if (newName.isNotEmpty && newBalance != null) {
                    Provider.of<TransactionViewModel>(context, listen: false)
                        .updateAccount(account);
                    Navigator.pop(context);
                  }
                },
                child: Text('Salvar'),
              ),
            ],
          );
        },
      );
    }

    void _addAccount() {
      // Lógica para adicionar nova conta
      print('Adicionar conta');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Contas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return AccountCard(
                    account: account,
                    onEdit: () => _editAccount(context, account),
                    onAdd: _addAccount,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
