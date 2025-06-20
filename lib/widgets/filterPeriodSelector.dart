import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum FilterPeriod {today, week, month, year, custom}

class FilterPeriodSelector extends StatefulWidget {
  final Function(FilterPeriod, DateTime?, DateTime?) onPeriodSelected;

  const FilterPeriodSelector({Key? key, required this.onPeriodSelected}) : super(key: key);

  @override
  State<FilterPeriodSelector> createState() => _FilterPeriodSelectorState();
}

class _FilterPeriodSelectorState extends State<FilterPeriodSelector> {
  FilterPeriod _selectedPeriod = FilterPeriod.today;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  Future<void> _selectDateRange(BuildContext context) async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedRange != null) {
      setState(() {
        _customStartDate = pickedRange.start;
        _customEndDate = pickedRange.end;
        _selectedPeriod = FilterPeriod.custom;
      });
      widget.onPeriodSelected(_selectedPeriod, _customStartDate, _customEndDate);
    }
  }
  void _updatePeriod(FilterPeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    widget.onPeriodSelected(period, null, null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ToggleButtons(
            isSelected: [
              _selectedPeriod == FilterPeriod.today,
              _selectedPeriod == FilterPeriod.week,
              _selectedPeriod == FilterPeriod.month,
              _selectedPeriod == FilterPeriod.year,
            ],
          onPressed: (index) => _updatePeriod(FilterPeriod.values[index]),
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.white,
          fillColor: Theme.of(context).primaryColor,
          children: const [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Hoje")),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Semana")),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Mês")),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Ano")),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _selectDateRange(context),
          child: Text(_selectedPeriod == FilterPeriod.custom
              ? "Período: ${DateFormat('dd/MM/yyyy').format(_customStartDate!)} - ${DateFormat('dd/MM/yyyy').format(_customEndDate!)}"
              : "Selecionar Período Personalizado"),
        ),
      ],
    );
  }
}

