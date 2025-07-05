class SubCategory {
  final int? id;
  final String name;
  final int categoryId;

  SubCategory({
    this.id,
    required this.name,
    required this.categoryId,
  });


  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['id'],
      name: map['name'],
      categoryId: map['category_id'],
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
    };
  }
}
