import 'package:flutter/material.dart';

import '../models/transacoesFormulario.dart';
import '../models/transaction.dart';

class Dashboard extends StatelessWidget {
  final List<Transaction> transactions;

  const Dashboard({Key? key, required this.transactions}) : super(key: key);

  double calcularEntradas() {
    return transactions
        .where((transaction) => transaction.amount > 0)
        .fold(0.0, (total, transaction) => total + transaction.amount);
  }

  double calcularSaidas() {
    return transactions
        .where((transaction) => transaction.amount < 0)
        .fold(0.0, (total, transaction) => total + transaction.amount.abs());
  }

  double calcularSaldo() {
    return transactions.fold(0.0, (total, transaction) => total + transaction.amount);
  }

  @override
  Widget build(BuildContext context) {
    final entradas = calcularEntradas();
    final saidas = calcularSaidas();
    final saldo = calcularSaldo();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MelDinheiro'),
      ),
      body: ListView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  // Card com o saldo
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Saldo Atual',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'R\$ ${saldo.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 36,
                              color: saldo >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Linha com botões
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          // Botão de subtração para despesa
                          FloatingActionButton(
                            tooltip: 'Despesa',
                            onPressed: () {
                              // Função para incluir despesa
                            },
                            child: const Icon(Icons.remove),
                            backgroundColor: Colors.red,
                          ),

                          // Botão de adição para receita
                          FloatingActionButton(
                            onPressed: () {
                              // Função para incluir receita
                            },
                            child: const Icon(Icons.add),
                            backgroundColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Card com resumo de entradas e saídas
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Resumo',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          // Exibição das entradas e saídas
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Icon(Icons.add_circle, color: Colors.green),
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
                            children: <Widget>[
                              const Icon(Icons.remove_circle, color: Colors.red),
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
/*

  final double entradas = 2500.00; // Exemplo de receita
  final double saidas = 1000.00; // Exemplo de despesa
  final double saldo = 1500.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('MelDinheiro'),
        ),
        body:
        ListView(children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  // Card com o saldo
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Saldo Atual',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'R\$ 1.000,00',
                            style: TextStyle(fontSize: 36, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Linha com botões
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          // Botão de subtração para despesa
                          FloatingActionButton(
                            tooltip: 'Despesa',
                            onPressed: () {
                              // Função para incluir despesa
                            },
                            child: Icon(Icons.remove),
                            backgroundColor: Colors.red,
                          ),

                          // Botão de adição para receita
                          FloatingActionButton(
                            onPressed: () {
                              // Função para incluir receita
                            },
                            child: Icon(Icons.add),
                            backgroundColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Card com resumo de entradas e saídas
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Resumo',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          // Exibição das entradas e saídas
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16.0),
                                  ),
                                ),
                                child: Icon(
                                  Icons.add_circle,
                                  color: Colors.green,
                                ),
                              ),

                              Text(
                                'Entradas:',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                'R\$ ${entradas.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 18, color: Colors.green),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16.0),
                                  ),
                                ),
                                child: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                'Saídas:',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                'R\$ ${saidas.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 18, color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),],
              ),
            ),
          ),
          */
/*Align(
            alignment: Alignment.topCenter,
            child: SaldoCard(),
          ),*//*

          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [

              ElevatedButton(
                child: Text('Receitas'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return transacoesForm();
                    },
                  ));
                },
              ),
              ElevatedButton(
                child: Text('Despesas'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return transacoesForm();
                    },
                  ));
                },
              ),
            ],
          ),
          //UltimasTransacoes(), a ser implementado...


        ]));
  }
*/
}
