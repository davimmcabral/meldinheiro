

class Transaction {
  int? id;
  String type; // Tipo da transação (Despesa, Receita, etc.)
  String category; // Categoria (ex: Alimentação, Transporte)
  String subCategory; // Subcategoria (ex: Restaurante, Ônibus)
  String? description;
  DateTime date; // Data da transação
  double amount; // Valor da transação (negativo para despesas)

  Transaction({
    this.id,
    required this.type,
    required this.category,
    required this.subCategory,
    this.description,
    required this.date,
    required this.amount,
  });

  // Converter a transação para um Map (para inserir no banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'subCategory': subCategory,
      'description': description,
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }

  // Criar uma transação a partir de um Map (para recuperar do banco de dados)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      category: map['category'],
      subCategory: map['subCategory'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      amount: map['amount'].toDouble(),
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, type: $type, category: $category, subCategory: $subCategory, description: $description, date: $date, amount: $amount}';
  }
}