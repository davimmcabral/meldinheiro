

class Transaction {
  int? id;
  String type; // Tipo da transação (Despesa, Receita, etc.)
  int categoryId; // Categoria (ex: Alimentação, Transporte)
  int subCategoryId; // Subcategoria (ex: Restaurante, Ônibus)
  String? description;
  DateTime date; // Data da transação
  double amount; // Valor da transação (negativo para despesas)
  int accountId;

  Transaction({
    this.id,
    required this.type,
    required this.categoryId,
    required this.subCategoryId,
    this.description,
    required this.date,
    required this.amount,
    required this.accountId,
  });

  // Converter a transação para um Map (para inserir no banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category_id': categoryId,
      'subCategory_id': subCategoryId,
      'description': description ?? '',
      'date': date.toIso8601String(),
      'amount': amount,
      'account_id': accountId,
    };
  }

  // Criar uma transação a partir de um Map (para recuperar do banco de dados)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      categoryId: map['category_id'],
      subCategoryId: map['subCategory_id'],
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      amount: (map['amount'] is num) ? map['amount'].toDouble() : double.tryParse(map['amount'].toString()) ?? 0.0,
      accountId: map['account_id']
      //amount: map['amount' as num].toDouble(),
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, type: $type, categoryId: $categoryId, subCategoryId: $subCategoryId, description: $description, date: $date, amount: $amount, account: $accountId}';
  }
}