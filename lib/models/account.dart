class Account {
  int? id;
  String name;
  double initialBalance;
  double balance;


  Account({this.id, required this.name, required this.initialBalance, this.balance = 0.0,});

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      initialBalance: map['initialBalance'] ?? 0.0,
      balance: 0.0,
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'initialBalance': initialBalance,
    };
  }
}