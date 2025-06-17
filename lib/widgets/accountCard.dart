import 'package:flutter/material.dart';
import '../models/account.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback onEdit;
  final VoidCallback onAdd;

  const AccountCard({
    Key? key,
    required this.account,
    required this.onEdit,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                account.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                'Saldo: R\$ ${account.balance.toStringAsFixed(2)}',
                style: TextStyle(
                  color: account.balance >= 0
                      ? Colors.green
                      : Colors.red,
                  fontSize: 16,
              ),
            ),
            ),
            /*Row(
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
            ),*/
          ],
        ),
      ),
    );
  }
}
