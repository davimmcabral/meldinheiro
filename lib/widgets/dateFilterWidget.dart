import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilterWidget extends StatefulWidget {
  final DateTime initialDate;
  final String initialPeriod;
  final Function(DateTime, String) onDateChanged;

  const DateFilterWidget({
    Key? key,
    required this.initialDate,
    required this.initialPeriod,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  _DateFilterWidgetState createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterWidget> {
  late DateTime _selectedDate; //= DateTime.now();
  late String _selectedPeriod; //= "Mês"; // Padrão inicial

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedPeriod = widget.initialPeriod;
  }
  void _changePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      _selectedDate = DateTime.now(); // Reseta para hoje ao mudar o período
    });
    widget.onDateChanged(_selectedDate, _selectedPeriod);
  }

  void _changeDate(int increment) {
    setState(() {
      switch (_selectedPeriod) {
        case "Dia":
          _selectedDate = _selectedDate.add(Duration(days: increment));
          break;
        case "Semana":
          _selectedDate = _selectedDate.add(Duration(days: 7 * increment));
          break;
        case "Mês":
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + increment, 1);
          break;
        case "Ano":
          _selectedDate = DateTime(_selectedDate.year + increment, 1, 1);
          break;
      }
    });
    widget.onDateChanged(_selectedDate, _selectedPeriod);
  }

  void _showPeriodSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: ["Dia", "Semana", "Mês", "Ano"].map((String period) {
            return ListTile(
              title: Text(period),
              tileColor: Colors.orange.shade100,
              onTap: () {
                Navigator.pop(context);
                _changePeriod(period);
              },
            );
          }).toList(),
        );
      },
    );
  }

  String _formatDate() {
    switch (_selectedPeriod) {
      case "Dia":
        return DateFormat('dd/MM/yyyy').format(_selectedDate);
      case "Semana":
        DateTime endOfWeek = _selectedDate.add(Duration(days: 6));
        return "${DateFormat('dd/MM').format(_selectedDate)} - ${DateFormat('dd/MM').format(endOfWeek)}";
      case "Mês":
        return DateFormat('MMMM yyyy', 'pt_BR').format(_selectedDate);
      case "Ano":
        return DateFormat('yyyy').format(_selectedDate);
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.orangeAccent, size: 28),
            onPressed: () => _changeDate(-1),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: _showPeriodSelection,
            child: Column(
              children: [
                Text(
                  _selectedPeriod,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.orangeAccent,
                  ),
                ),
                Text(
                  _formatDate()[0].toUpperCase() + _formatDate().substring(1),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.orangeAccent, size: 28),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }
}
