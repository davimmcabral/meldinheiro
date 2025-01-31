class Category {
  String type; // Tipo da transação (Receita ou Despesa)
  String category; // Nome da categoria (ex: Alimentação, Transporte)
  List<String> subCategories; // Lista de subcategorias para essa categoria

  Category({
    required this.type,
    required this.category,
    required this.subCategories,
  });
}

class CategoryModel {
  static List<Category> categories = [
    // Categorias para RECEITAS
    Category(
      type: 'Receita',
      category: 'Salário',
      subCategories: [
        'Salário Mensal',
        'Bônus',
        'Comissão',
      ],
    ),
    Category(
      type: 'Receita',
      category: 'Investimentos',
      subCategories: [
        'Rendimentos de Poupança',
        'Dividendos',
        'Ações',
      ],
    ),
    Category(
      type: 'Receita',
      category: 'Outros',
      subCategories: [
        'Presentes',
        'Empréstimos Recebidos',
        'Outras Receitas',
      ],
    ),

    // Categorias para DESPESAS
    Category(
      type: 'Despesa',
      category: 'Alimentação',
      subCategories: [
        'Restaurante',
        'Supermercado',
        'Lanches',
      ],
    ),
    Category(
      type: 'Despesa',
      category: 'Transporte',
      subCategories: [
        'Ônibus',
        'Combustível',
        'Táxi',
        'Uber',
      ],
    ),
    Category(
      type: 'Despesa',
      category: 'Moradia',
      subCategories: [
        'Aluguel',
        'Água',
        'Energia',
        'Internet',
      ],
    ),
    Category(
      type: 'Despesa',
      category: 'Saúde',
      subCategories: [
        'Plano de Saúde',
        'Medicamentos',
        'Consultas Médicas',
      ],
    ),
    Category(
      type: 'Despesa',
      category: 'Educação',
      subCategories: [
        'Cursos',
        'Material Escolar',
        'Mensalidade Escolar',
      ],
    ),
    Category(
      type: 'Despesa',
      category: 'Lazer',
      subCategories: [
        'Cinema',
        'Viagem',
        'Jogos',
      ],
    ),
    Category(
      type: 'Despesa',
      category: 'Outros',
      subCategories: [
        'Presentes',
        'Multas',
        'Impostos',
        'Outros',
      ],
    ),
  ];
}
