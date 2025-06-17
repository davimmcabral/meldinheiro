class SubCategory {
  final int? id;
  final String name;
  final int categoryId;

  SubCategory({
    this.id,
    required this.name,
    required this.categoryId,
  });

  // Converter de Map (banco de dados) para Objeto
  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['id'],
      name: map['name'],
      categoryId: map['category_id'],
    );
  }

  // Converter de Objeto para Map (banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
    };
  }
}
