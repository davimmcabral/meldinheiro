import 'package:flutter/material.dart';

import '../database/database.dart';
import '../models/transaction.dart';
import '../models/transactionsHistory.dart';

class DashboardNovo extends StatefulWidget {
  final List<Transaction> transactions;

  const DashboardNovo({Key? key, required this.transactions}) : super(key: key);

  @override
  State<DashboardNovo> createState() => _DashboardNovoState();
}

class _DashboardNovoState extends State<DashboardNovo> {
  String _selectedPeriod = 'Mensal';
  DateTime _selectedDate = DateTime.now();
  List<Transaction> _transactions = [];

  final List<String> _months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];

  @override
  void initState(){
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await DatabaseHelper.instance.getTransactions();
    setState(() {
      _transactions = transactions;
    });
  }
  List<Transaction> _filterTransactionsByPeriod() {
    return _transactions.where((transaction) {
      if (_selectedPeriod == 'Mensal') {
        return transaction.date.year == _selectedDate.year &&
            transaction.date.month == _selectedDate.month;
      } else if (_selectedPeriod == 'Anual') {
        return transaction.date.year == _selectedDate.year;
      }
      return false;
    }).toList();
  }

  /*List<Transaction> _filterTransactionsByPeriod() {
    return widget.transactions.where((transaction) {
      if (_selectedPeriod == 'Mensal') {
        return transaction.date.year == _selectedDate.year &&
            transaction.date.month == _selectedDate.month;
      } else if (_selectedPeriod == 'Anual') {
        return transaction.date.year == _selectedDate.year;
      }
      return false;
    }).toList();
  }*/

  double _calculateEntradas(List<Transaction> transactions) {
    return transactions
        .where((transaction) => transaction.amount > 0)
        .fold(0.0, (total, transaction) => total + transaction.amount);
  }

  double _calculateSaidas(List<Transaction> transactions) {
    return transactions
        .where((transaction) => transaction.amount < 0)
        .fold(0.0, (total, transaction) => total + transaction.amount.abs());
  }

  double _calculateSaldo(List<Transaction> transactions) {
    return transactions.fold(0.0, (total, transaction) => total + transaction.amount);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _filterTransactionsByPeriod();
    final entradas = _calculateEntradas(filteredTransactions);
    final saidas = _calculateSaidas(filteredTransactions);
    final saldo = _calculateSaldo(filteredTransactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MelDinheiro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: ListView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Seletores de período
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Visão:', style: TextStyle()
                        ,),
                      DropdownButton<String>(
                        value: _selectedPeriod,
                        items: const [
                          DropdownMenuItem(value: 'Mensal', child: Text('Mensal')),
                          DropdownMenuItem(value: 'Anual', child: Text('Anual')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriod = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      // Seletor de mês (exibido apenas no modo Mensal)
                      if (_selectedPeriod == 'Mensal')
                        DropdownButton<int>(
                          value: _selectedDate.month,
                          items: List.generate(
                            12,
                                (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text(_months[index]),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedDate = DateTime(
                                _selectedDate.year,
                                value!,
                              );
                            });
                          },
                        ),
                      const SizedBox(width: 20),
                      // Seletor de ano
                      DropdownButton<int>(
                        value: _selectedDate.year,
                        items: List.generate(
                          5,
                              (index) => DropdownMenuItem(
                            value: DateTime.now().year - index,
                            child: Text((DateTime.now().year - index).toString()),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedDate = DateTime(
                              value!,
                              _selectedDate.month,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Resumo
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumo de ${_selectedPeriod == 'Mensal' ? _months[_selectedDate.month - 1] : ''} ${_selectedDate.year}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          _buildResumoRow('Entradas:', entradas, Colors.green),
                          _buildResumoRow('Saídas:', saidas, Colors.red),
                          _buildResumoRow('Saldo:', saldo, saldo >= 0 ? Colors.green : Colors.red, isBold: true),
                         /* Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Entradas:',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                'R\$ ${entradas.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18, color: Colors.green),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Saídas:',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                'R\$ ${saidas.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18, color: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               const Text(
                                'Saldo:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,

                                ),
                              ),
                              Text(
                                'R\$ ${saldo.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: saldo >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],

                          ),*/
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text('Histórico de Transações'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionsHistory(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildResumoRow(String title, double value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
