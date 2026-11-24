import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

class DayOfYearPicker extends StatefulWidget {
  const DayOfYearPicker({super.key, this.onChanged});

  final ValueChanged<int>? onChanged;

  @override
  State<DayOfYearPicker> createState() => _DayOfYearPickerState();
}

class _DayOfYearPickerState extends State<DayOfYearPicker> {
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late int _year;
  late final TextEditingController _dayController;
  late int _month;
  late int _dayOfYear;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _year = today.year;
    _month = today.month;
    _dayController = TextEditingController(text: today.day.toString());
    _dayOfYear = _getDayOfYear(today);
  }

  @override
  void dispose() {
    _dayController.dispose();
    super.dispose();
  }

  int _daysInMonth(int month) => DateTime(_year, month + 1, 0).day;

  int get _daysInYear =>
      DateTime(_year + 1, 1, 1).difference(DateTime(_year, 1, 1)).inDays;

  int _getDayOfYear(DateTime date) =>
      date.difference(DateTime(_year, 1, 1)).inDays + 1;

  DateTime? _dateForDay(int day) {
    if (day < 1 || day > _daysInMonth(_month)) return null;
    return DateTime(_year, _month, day);
  }

  void _onMonthChanged(int? month) {
    if (month == null) return;

    int? dayOfYear;
    setState(() {
      _month = month;
      final day = int.tryParse(_dayController.text);
      if (day != null) {
        final adjustedDay = day.clamp(1, _daysInMonth(_month));
        _dayController.text = adjustedDay.toString();
        dayOfYear =
            DateTime(
              _year,
              _month,
              adjustedDay,
            ).difference(DateTime(_year, 1, 1)).inDays +
            1;
        _dayOfYear = dayOfYear!;
      }
    });
    if (dayOfYear != null) widget.onChanged?.call(dayOfYear!);
  }

  void _onDayChanged(String value) {
    final day = int.tryParse(value);
    final date = day == null ? null : _dateForDay(day);
    if (date == null) return;

    setState(() {
      _dayOfYear = _getDayOfYear(date);
    });
    widget.onChanged?.call(_dayOfYear);
  }

  void _onDayOfYearChanged(double value) {
    final dayOfYear = value.round();
    final date = DateTime(_year, 1, 1).add(Duration(days: dayOfYear - 1));

    setState(() {
      _dayOfYear = dayOfYear;
      _month = date.month;
      _dayController.text = date.day.toString();
    });
    widget.onChanged?.call(dayOfYear);
  }

  void _setCurrentDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays + 1;

    setState(() {
      _year = today.year;
      _month = today.month;
      _dayOfYear = dayOfYear;
      _dayController.text = today.day.toString();
    });
    widget.onChanged?.call(dayOfYear);
  }

  String? _validateDay(String? value) {
    final day = int.tryParse(value ?? '');
    if (day == null || _dateForDay(day) == null) {
      return 'Enter a day from 1 to ${_daysInMonth(_month)}.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                key: ValueKey('day-of-year-month-$_month'),
                initialValue: _month,
                isExpanded: true,
                items: [
                  for (var month = 1; month <= _monthNames.length; month++)
                    DropdownMenuItem(
                      value: month,
                      child: Text(_monthNames[month - 1]),
                    ),
                ],
                onChanged: _onMonthChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                key: const Key('day-of-year-day'),
                controller: _dayController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _validateDay,
                onChanged: _onDayChanged,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: _setCurrentDate, child: const Text('Today')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Day of year: $_dayOfYear'),
            const SizedBox(width: 16),
            Expanded(
              child: Slider(
                key: const Key('day-of-year-slider'),
                min: 1,
                max: _daysInYear.toDouble(),
                divisions: _daysInYear - 1,
                value: _dayOfYear.toDouble(),
                label: '$_dayOfYear',
                onChanged: _onDayOfYearChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
