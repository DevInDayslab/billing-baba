import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart'
    show SaleDateRangePickerAnchor;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Inline single-month calendar — same visual language as [SaleDateRangePickerAnchor].
class FilterInlineCalendar extends StatefulWidget {
  const FilterInlineCalendar({
    required this.selectedDate,
    required this.onDateSelected,
    this.initialMonth,
    super.key,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? initialMonth;

  @override
  State<FilterInlineCalendar> createState() => _FilterInlineCalendarState();
}

class _FilterInlineCalendarState extends State<FilterInlineCalendar> {
  static final _monthFormat = DateFormat('MMMM yyyy');
  static const _weekdayLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final seed = widget.selectedDate ?? widget.initialMonth ?? DateTime.now();
    _visibleMonth = DateTime(seed.year, seed.month);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _daysInMonth(DateTime month) =>
      DateTime(month.year, month.month + 1, 0).day;

  int _firstWeekdayOffset(DateTime month) =>
      DateTime(month.year, month.month).weekday % 7;

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _NavButton(
              icon: Icons.chevron_left,
              onPressed: () => _shiftMonth(-1),
            ),
            Expanded(
              child: Text(
                _monthFormat.format(_visibleMonth),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _NavButton(
              icon: Icons.chevron_right,
              onPressed: () => _shiftMonth(1),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        _MonthGrid(
          month: _visibleMonth,
          weekdayLabels: _weekdayLabels,
          daysInMonth: _daysInMonth(_visibleMonth),
          firstWeekdayOffset: _firstWeekdayOffset(_visibleMonth),
          isSelected: (day) =>
              widget.selectedDate != null &&
              _isSameDay(day, widget.selectedDate!),
          onDayTap: (day) => widget.onDateSelected(_dateOnly(day)),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.weekdayLabels,
    required this.daysInMonth,
    required this.firstWeekdayOffset,
    required this.isSelected,
    required this.onDayTap,
  });

  final DateTime month;
  final List<String> weekdayLabels;
  final int daysInMonth;
  final int firstWeekdayOffset;
  final bool Function(DateTime day) isSelected;
  final ValueChanged<DateTime> onDayTap;

  static const _calendarRowCount = 6;
  static const _dayCellHeight = 32.0;
  static const _selectedDayFill = Color(0xFF212121);
  static const _hoverColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (final label in weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        for (var row = 0; row < _calendarRowCount; row++)
          SizedBox(
            height: _dayCellHeight,
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(child: _buildDayCell(row, col)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDayCell(int row, int col) {
    final cellIndex = row * 7 + col;
    final dayNumber = cellIndex - firstWeekdayOffset + 1;

    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox.shrink();
    }

    final day = DateTime(month.year, month.month, dayNumber);
    final selected = isSelected(day);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => onDayTap(day),
        hoverColor: _hoverColor,
        child: Container(
          alignment: Alignment.center,
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? _selectedDayFill : null,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Parses and formats DD/MM/YYYY dates for filter inputs.
abstract final class FilterDateFormat {
  static final format = DateFormat('dd/MM/yyyy');
  static final inputFormatter = FilteringTextInputFormatter.allow(
    RegExp('[0-9/]'),
  );

  static String formatDate(DateTime date) => format.format(date);

  static DateTime? parse(String value) {
    try {
      return format.parseStrict(value.trim());
    } on FormatException {
      return null;
    }
  }
}
