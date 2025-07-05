import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'meldinheiro.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE NOT NULL,
            initialBalance REAL
            )
        ''');
        await _insertDefaultAccounts(db);

        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL CHECK(type IN ('Receita', 'Despesa'))
          )
        ''');
        await _insertDefaultCategories(db);


        await db.execute('''
          CREATE TABLE subcategories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category_id INTEGER,
            name TEXT,
            FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
          )
        ''');
        await _insertDefaultSubCategories(db);

        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            category_id INTEGER NOT NULL,
            subCategory_id INTEGER NOT NULL,
            description TEXT,
            date TEXT,
            amount REAL,
            account_id INTEGER NOT NULL,
            FOREIGN KEY (category_id) REFERENCES categories (id),
            FOREIGN KEY (subCategory_id) REFERENCES subcategories (id)
            FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<Database?> _insertDefaultAccounts(Database db) async {
    await db.insert(
        'accounts', {'id': 1, 'name': 'Dinheiro', 'initialBalance': 0.0});
    return db;
  }

  Future<Database> _insertDefaultCategories(Database db) async {
    await db.insert(
        'categories', {'id': 1, 'name': 'Moradia', 'type': 'Despesa'});
    await db.insert(
        'categories', {'id': 2, 'name': 'Pessoal', 'type': 'Despesa'});
    await db.insert('categories',
        {'id': 3, 'name': 'Despesas Bancárias', 'type': 'Despesa'});
    await db.insert(
        'categories', {'id': 4, 'name': 'Saúde', 'type': 'Despesa'});
    await db.insert(
        'categories', {'id': 5, 'name': 'Educação', 'type': 'Despesa'});
    await db.insert(
        'categories', {'id': 6, 'name': 'Lazer', 'type': 'Despesa'});
    await db.insert(
        'categories', {'id': 7, 'name': 'Veículos', 'type': 'Despesa'});
    await db.insert(
        'categories', {'id': 8, 'name': 'Outros', 'type': 'Despesa'});
    await db.insert(
        'categories', {'id': 9, 'name': 'Salário', 'type': 'Receita'});
    await db.insert(
        'categories', {'id': 10, 'name': 'Investimentos', 'type': 'Receita'});
    await db.insert(
        'categories', {'id': 11, 'name': 'Receitas Extras', 'type': 'Receita'});
    await db.insert('categories',
        {'id': 12, 'name': 'Outros Rendimentos', 'type': 'Receita'});

    return db;
  }

  Future<Database> _insertDefaultSubCategories(Database db) async {
    //category_id: 1
    await db.insert('subcategories',
        {'name': 'Compras/vendas e prestações diversas', 'category_id': 1});
    await db.insert(
        'subcategories', {'name': 'Aluguéis e condomínios', 'category_id': 1});
    await db.insert('subcategories',
        {'name': 'Supermercado, alimentação e higiene', 'category_id': 1});
    await db.insert('subcategories',
        {'name': 'Móveis, utensílios e reformas', 'category_id': 1});
    await db.insert('subcategories',
        {'name': 'Luz, água, segurança e gás', 'category_id': 1});
    await db.insert('subcategories',
        {'name': 'Telefone fixo/celular e correios', 'category_id': 1});
    await db.insert('subcategories',
        {'name': 'Impostos, taxas e despesas legais', 'category_id': 1});
    await db.insert('subcategories',
        {'name': 'Empregados, diaristas e serviços', 'category_id': 1});

    //category_id: 2
    await db.insert(
        'subcategories', {'name': 'Açougue e/ou peixaria', 'category_id': 2});
    await db.insert('subcategories',
        {'name': 'Feira, mercado, padaria ou quitanda', 'category_id': 2});
    await db.insert(
        'subcategories', {'name': 'Restaurantes e lanches', 'category_id': 2});
    await db.insert('subcategories',
        {'name': 'Higiene pessoal e perfumes', 'category_id': 2});
    await db.insert('subcategories',
        {'name': 'Vestuário, calçados e acessórios', 'category_id': 2});

    // category_id: 3
    await db.insert('subcategories',
        {'name': 'Pgto Faturas de Cartões de crédito', 'category_id': 3});
    await db.insert('subcategories',
        {'name': 'Juros e amortizações de empréstimos', 'category_id': 3});
    await db.insert('subcategories', {'name': 'Empréstimos', 'category_id': 3});
    await db
        .insert('subcategories', {'name': 'Tarifas e taxas', 'category_id': 3});
    await db.insert('subcategories',
        {'name': 'Poupança e aplicações (-Saques)', 'category_id': 3});
    await db.insert(
        'subcategories',
        {'name': 'Rendimentos incorporados', 'category_id': 3});
    await db.insert(
        'subcategories', {'name': 'Prestações e planos', 'category_id': 3});

    // category_id: 4
    await db
        .insert('subcategories', {'name': 'Planos de saúde', 'category_id': 4});
    await db.insert('subcategories',
        {'name': 'Seguros e Previdência privada', 'category_id': 4});
    await db.insert(
        'subcategories', {'name': 'Assistência médica', 'category_id': 4});
    await db.insert(
        'subcategories', {'name': 'Dentista e Psicólogo', 'category_id': 4});
    await db.insert(
        'subcategories', {'name': 'Medicamentos e exames', 'category_id': 4});
    await db.insert('subcategories', {'name': 'Academias', 'category_id': 4});

    // category_id: 5
    await db.insert(
        'subcategories', {'name': 'Mensalidade escolar', 'category_id': 5});
    await db
        .insert('subcategories', {'name': 'Cursos e livros', 'category_id': 5});
    await db.insert('subcategories',
        {'name': 'Material escolar e papelaria', 'category_id': 5});
    await db.insert(
        'subcategories', {'name': 'Jornais e revistas', 'category_id': 5});
    await db.insert(
        'subcategories',
        {'name': 'Sindicatos e associações', 'category_id': 5});
    await db.insert(
        'subcategories',
        {'name': 'Inscrições e publicações', 'category_id': 5});

    // category_id: 6
    await db.insert('subcategories',
        {'name': 'Cinema, shows, teatro... diversões', 'category_id': 6});
    await db.insert('subcategories',
        {'name': 'Clube - mensalidades e outros', 'category_id': 6});
    await db.insert('subcategories',
        {'name': 'Streaming de vídeo, TV paga e internet', 'category_id': 6});
    await db.insert(
        'subcategories', {'name': 'Streaming de música', 'category_id': 6});
    await db.insert(
        'subcategories',
        {'name': 'Jogos, loterias e outros', 'category_id': 6});

    // category_id: 7
    await db.insert('subcategories',
        {'name': 'Compras/vendas e prestações diversas', 'category_id': 7});
    await db.insert('subcategories',
        {'name': 'Combustível, manutenção e acessórios', 'category_id': 7});
    await db.insert('subcategories',
        {'name': 'Impostos, taxas e despesas legais', 'category_id': 7});
    await db.insert('subcategories', {'name': 'Seguros', 'category_id': 7});
    await db.insert('subcategories',
        {'name': 'Transporte - uber, taxi, ônibus, metrô', 'category_id': 7});

    // category_id: 8
    await db.insert('subcategories',
        {'name': 'Contribuições e presentes', 'category_id': 8});
    await db.insert('subcategories', {'name': 'Advogados', 'category_id': 8});
    await db.insert(
        'subcategories', {'name': 'Animais de estimação', 'category_id': 8});
    await db
        .insert('subcategories', {'name': 'Extras diversos', 'category_id': 8});

    // category_id: 9
    await db.insert(
        'subcategories', {'name': 'Salário principal', 'category_id': 9});
    await db
        .insert('subcategories', {'name': 'Outros salários', 'category_id': 9});

    // category_id: 10
    await db
        .insert('subcategories', {'name': 'Juros obtidos', 'category_id': 10});

    // category_id: 11
    await db.insert('subcategories',
        {'name': 'Pagamentos, IR restituição', 'category_id': 11});

    // category_id: 12
    await db.insert('subcategories', {'name': 'Aluguéis', 'category_id': 12});
    await db.insert('subcategories', {'name': 'Lucros', 'category_id': 12});

    return db;
  }

  //Deleta Banco de Dados
  Future<void> deleteDatabaseFile() async {
    final String path = join(await getDatabasesPath(), 'meldinheiro.db');
    await deleteDatabase(path);
  }
}
