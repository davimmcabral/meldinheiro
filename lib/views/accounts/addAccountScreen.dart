import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:meldinheiro/viewmodels/account_viewmodel.dart';
import 'package:meldinheiro/viewmodels/transaction_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../models/account.dart';


class AddAccountScreen extends StatefulWidget {
  final Account? account;

  const AddAccountScreen({super.key, this.account});

  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late MoneyMaskedTextController _initialBalanceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _initialBalanceController = MoneyMaskedTextController(
      initialValue: widget.account?.initialBalance ?? 0.0,
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  void _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final initialBalance = _initialBalanceController.numberValue;

      final account = Account(
        id: widget.account?.id,
        name: name,
        initialBalance: initialBalance,
      );

      final accountVM = Provider.of<AccountViewModel>(context, listen: false);
      final transactionVM = Provider.of<TransactionViewModel>(context, listen: false);

      try {
        if (widget.account == null) {
          await accountVM.addAccount(account);
          await transactionVM.loadTransactions();
        } else {
          await accountVM.updateAccount(account);
        }

        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Nova Conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome da Conta',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Informe um nome para a conta.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _initialBalanceController,
                decoration: InputDecoration(
                  labelText: 'Saldo Inicial',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveAccount,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/*class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _initialBalanceController;

  String _name = '';
  double _balance = 0.0;

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newAccount = Account(name: _name, balance: _balance);
      Provider.of<TransactionProvider>(context, listen: false).addAccount(newAccount);

      Navigator.of(context).pop(newAccount); // volta para tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nova Conta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Nome da Conta', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.orange.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  labelText: 'Nome da Conta',
                ),
                onSaved: (value) => _name = value!,
                validator: (value) => value!.isEmpty ? 'Informe o nome da conta' : null,
              ),
              const SizedBox(height: 24),
              Text('Saldo Inicial', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.orange.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  labelText: 'Saldo Inicial',
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _balance = double.tryParse(value!) ?? 0.0,
                validator: (value) =>
                value!.isEmpty || double.tryParse(value) == null
                    ? 'Informe um valor válido'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveAccount,
                child: Text('Salvar Conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/


/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/transaction_viewmodel.dart';

class AddAccountCard extends StatefulWidget {
  @override
  _AddAccountCardState createState() => _AddAccountCardState();
}

class _AddAccountCardState extends State<AddAccountCard> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _balance = 0.0;

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newAccount = Account(
        name: _name,
        balance: _balance,
      );

      Provider.of<TransactionProvider>(context, listen: false).addAccount(newAccount);
      Navigator.of(context).pop(newAccount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nova Conta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                ),
              ),
              SizedBox(height: 16),

              // Nome da Conta
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nome da Conta',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _name = value!.trim(),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Informe o nome da conta' : null,
              ),

              SizedBox(height: 12),

              // Saldo inicial
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Saldo Inicial',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) => _balance = double.tryParse(value!) ?? 0.0,
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null) return 'Informe um valor válido';
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Botão de salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveAccount,
                  icon: Icon(Icons.save),
                  label: Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/transaction_viewmodel.dart';


class AddAccountCard extends StatefulWidget {
  @override
  _AddAccountCardState createState() => _AddAccountCardState();
}

class _AddAccountCardState extends State<AddAccountCard> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _balance = 0.0;


  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newAccount = Account(
        name: _name,
        balance: _balance,

      );

      Provider.of<TransactionProvider>(context, listen: false).addAccount(newAccount);

      Navigator.of(context).pop(newAccount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nova Conta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome da Conta'),
                onSaved: (value) => _name = value!,
                validator: (value) => value!.isEmpty ? 'Informe o nome da conta' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Saldo Inicial'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _balance = double.tryParse(value!) ?? 0.0,
                validator: (value) =>
                value!.isEmpty || double.tryParse(value) == null ? 'Informe um valor válido' : null,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _saveAccount,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
