import 'package:flutter/material.dart';
import 'transaction.dart';

class transacoesForm extends StatefulWidget {
  @override
  _transacoesFormState createState() => _transacoesFormState();
}

class _transacoesFormState extends State<transacoesForm> {
  // Controladores dos campos do formulário
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedType; // Tipo da transação (Despesa ou Receita)
  String? _selectedCategory; // Categoria selecionada
  String? _selectedSubCategory; // Subcategoria selecionada
  String? description;
  double? amount;
  DateTime? selectedDate;

  // Lista de categorias e subcategorias (exemplo)
  final List<String> _categories = ['Alimentação', 'Transporte', 'Lazer'];
  final Map<String, List<String>> _subCategories = {
    'Alimentação': ['Restaurante', 'Supermercado', 'Café'],
    'Transporte': ['Combustível', 'Ônibus', 'Táxi'],
    'Lazer': ['Cinema', 'Parque', 'Viagem'],
  };

  @override
  void initState() {
    super.initState();
    // Inicializar a data atual e o controlador de data
    selectedDate = DateTime.now();
    _dateController.text = "${selectedDate!.toLocal()}".split(' ')[0]; // Formato YYYY-MM-DD
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário de Transações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo para selecionar o tipo da transação (Despesa ou Receita)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Tipo de Transação',
                  border: OutlineInputBorder(),
                ),
                items: ['Despesa', 'Receita']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                value: _selectedType,
                validator: (value) {
                  if (value == null || !(['Despesa', 'Receita'].contains(value))) {
                    return 'Por favor, selecione "Despesa" ou "Receita"';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),

              // Campo para selecionar a categoria
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedSubCategory = null; // Resetar subcategoria
                  });
                },
                value: _selectedCategory,
                validator: (value) =>
                value == null ? 'Por favor, selecione uma categoria' : null,
              ),
              SizedBox(height: 16.0),

              // Campo para selecionar a subcategoria
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Subcategoria',
                  border: OutlineInputBorder(),
                ),
                items: (_selectedCategory != null && _subCategories.containsKey(_selectedCategory)
                    ? _subCategories[_selectedCategory]!
                    : <String>[])
                    .map((subCategory) => DropdownMenuItem(
                  value: subCategory,
                  child: Text(subCategory),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubCategory = value;
                  });
                },
                value: _selectedSubCategory,
                validator: (value) =>
                value == null ? 'Por favor, selecione uma subcategoria' : null,
              ),
              SizedBox(height: 16.0),

              // Campo para inserir o valor da transação
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => amount = double.tryParse(value ?? ''),
                validator: (value) =>
                value == null || double.tryParse(value) == null
                    ? 'Por favor, insira um valor válido'
                    : null,
              ),
              SizedBox(height: 16.0),

              // Campo para selecionar a data da transação
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Data',
                  border: OutlineInputBorder(),
                ),
                readOnly: true, // Impede que o usuário digite diretamente
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                      _dateController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Formato YYYY-MM-DD
                    });
                  }
                },
                validator: (value) =>
                value == null || value.isEmpty ? 'Por favor, selecione uma data' : null,
              ),
              SizedBox(height: 16.0),

              // Botão de salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      _saveTransaction();
                    }
                  },
                  child: Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Função para salvar a transação no banco de dados
  void _saveTransaction() async {
    // Crie uma instância de Transaction com os dados do formulário
    final transaction = Transaction(
      type: _selectedType!, // Despesa ou Receita
      category: _selectedCategory!,
      subCategory: _selectedSubCategory!,
      description: description,
      date: selectedDate!,
      amount: amount!, // O valor pode ser negativo para despesa
    );
    print(transaction);
    // Salve a transação no banco de dados
    //final dbHelper = DatabaseHelper();
  //  final id = await dbHelper.insertTransaction(transaction);

    // Mostre um diálogo de sucesso ou qualquer outro feedback
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sucesso'),
        content: Text('Transação salva com sucesso!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }
}
