import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_calendar.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared text field for filter popovers.
class FilterTextInput extends StatelessWidget {
  const FilterTextInput({
    required this.controller,
    this.hintText,
    this.autofocus = false,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String? hintText;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TableFilterTheme.fieldHeight,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        cursorColor: AppColors.primary,
        style: TableFilterTheme.fieldTextStyle,
        decoration: TableFilterTheme.fieldDecoration(hintText: hintText),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

/// Shared numeric field for filter popovers.
class FilterNumberInput extends StatelessWidget {
  const FilterNumberInput({
    required this.controller,
    this.prefixText,
    this.hintText,
    this.inputFormatters = const [],
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String? prefixText;
  final String? hintText;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TableFilterTheme.fieldHeight,
      child: TextField(
        controller: controller,
        cursorColor: AppColors.primary,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: inputFormatters,
        style: TableFilterTheme.fieldTextStyle,
        decoration: TableFilterTheme.fieldDecoration(
          prefixText: prefixText,
          hintText: hintText,
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

/// Shared date text field with inline calendar (no fullscreen picker).
class FilterDateInput extends StatefulWidget {
  const FilterDateInput({
    required this.controller,
    required this.selectedDate,
    required this.onDateChanged,
    this.label,
    super.key,
  });

  final TextEditingController controller;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final String? label;

  @override
  State<FilterDateInput> createState() => _FilterDateInputState();
}

class _FilterDateInputState extends State<FilterDateInput> {
  bool _showCalendar = false;

  void _toggleCalendar() {
    setState(() => _showCalendar = !_showCalendar);
  }

  void _selectDate(DateTime date) {
    widget.onDateChanged(date);
    setState(() => _showCalendar = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: TableFilterTheme.sectionLabelStyle),
          const SizedBox(height: AppSpacing.xs),
        ],
        SizedBox(
          height: TableFilterTheme.fieldHeight,
          child: TextField(
            controller: widget.controller,
            cursorColor: AppColors.primary,
            style: TableFilterTheme.fieldTextStyle,
            inputFormatters: [FilterDateFormat.inputFormatter],
            decoration: TableFilterTheme.fieldDecoration(
              hintText: 'DD/MM/YYYY',
              suffixIcon: IconButton(
                onPressed: _toggleCalendar,
                icon: Icon(
                  _showCalendar
                      ? Icons.keyboard_arrow_up
                      : Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ),
          ),
        ),
        if (_showCalendar) ...[
          const SizedBox(height: AppSpacing.sm),
          FilterInlineCalendar(
            selectedDate: widget.selectedDate,
            onDateSelected: _selectDate,
          ),
        ],
      ],
    );
  }
}
