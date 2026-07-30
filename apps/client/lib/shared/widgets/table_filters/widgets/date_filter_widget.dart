import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_calendar.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_inputs.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_layout.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_theme.dart';
import 'package:flutter/material.dart';

typedef DateFilterApplyCallback = void Function(DateColumnFilter? filter);

/// Date filter — Equal / Less / Greater / Range with inline calendar (Vyapar).
class DateFilterWidget extends StatefulWidget {
  const DateFilterWidget({
    required this.title,
    required this.initialFilter,
    required this.onApply,
    super.key,
  });

  final String title;
  final DateColumnFilter? initialFilter;
  final DateFilterApplyCallback onApply;

  @override
  State<DateFilterWidget> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterWidget> {
  late DateColumnOperator _operator;
  late TextEditingController _dateController;
  late TextEditingController _fromController;
  late TextEditingController _toController;
  DateTime? _selectedDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  bool get _isRange => _operator == DateColumnOperator.range;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialFilter;
    _operator = initial?.operator ?? DateColumnOperator.equalTo;
    _selectedDate = initial?.date;
    _rangeStart = initial?.startDate;
    _rangeEnd = initial?.endDate;

    _dateController = TextEditingController(
      text: _selectedDate != null
          ? FilterDateFormat.formatDate(_selectedDate!)
          : '',
    );
    _fromController = TextEditingController(
      text: _rangeStart != null
          ? FilterDateFormat.formatDate(_rangeStart!)
          : '',
    );
    _toController = TextEditingController(
      text: _rangeEnd != null ? FilterDateFormat.formatDate(_rangeEnd!) : '',
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _onSingleDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
      _dateController.text = FilterDateFormat.formatDate(date);
    });
  }

  void _onFromChanged(DateTime date) {
    setState(() {
      _rangeStart = date;
      _fromController.text = FilterDateFormat.formatDate(date);
    });
  }

  void _onToChanged(DateTime date) {
    setState(() {
      _rangeEnd = date;
      _toController.text = FilterDateFormat.formatDate(date);
    });
  }

  void _apply() {
    if (_isRange) {
      final start = FilterDateFormat.parse(_fromController.text);
      final end = FilterDateFormat.parse(_toController.text);
      if (start == null || end == null) {
        _showInvalidDateSnackBar();
        return;
      }
      widget.onApply(
        DateColumnFilter(
          operator: DateColumnOperator.range,
          startDate: start,
          endDate: end,
        ),
      );
      return;
    }

    final parsed =
        FilterDateFormat.parse(_dateController.text) ?? _selectedDate;
    if (parsed == null) {
      _showInvalidDateSnackBar();
      return;
    }
    widget.onApply(
      DateColumnFilter(operator: _operator, date: parsed),
    );
  }

  void _showInvalidDateSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enter a valid date (DD/MM/YYYY)')),
    );
  }

  void _clear() => widget.onApply(null);

  @override
  Widget build(BuildContext context) {
    return FilterPopoverLayout(
      title: widget.title,
      width: _isRange ? 300 : TableFilterTheme.popoverWidth,
      operator: FilterOperatorSection<DateColumnOperator>(
        value: _operator,
        items: DateColumnOperator.values,
        labelBuilder: (v) => v.label,
        onChanged: (v) => setState(() => _operator = v),
      ),
      input: _isRange
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilterDateInput(
                  label: 'From',
                  controller: _fromController,
                  selectedDate: _rangeStart,
                  onDateChanged: _onFromChanged,
                ),
                const SizedBox(height: AppSpacing.sm),
                FilterDateInput(
                  label: 'To',
                  controller: _toController,
                  selectedDate: _rangeEnd,
                  onDateChanged: _onToChanged,
                ),
              ],
            )
          : FilterDateInput(
              controller: _dateController,
              selectedDate: _selectedDate,
              onDateChanged: _onSingleDateChanged,
            ),
      onClear: _clear,
      onApply: _apply,
    );
  }
}
