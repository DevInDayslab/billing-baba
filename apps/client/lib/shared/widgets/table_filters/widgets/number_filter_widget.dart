import 'package:billing_baba/shared/widgets/table_filters/filter_inputs.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

typedef NumberFilterApplyCallback = void Function(NumberColumnFilter? filter);

/// Number filter — Equal To / Less Than / Greater Than with single input (Vyapar).
class NumberFilterWidget extends StatefulWidget {
  const NumberFilterWidget({
    required this.title,
    required this.initialFilter,
    required this.onApply,
    this.prefixText = '₹ ',
    this.hintText = 'Enter amount',
    super.key,
  });

  final String title;
  final NumberColumnFilter? initialFilter;
  final NumberFilterApplyCallback onApply;
  final String prefixText;
  final String hintText;

  @override
  State<NumberFilterWidget> createState() => _NumberFilterWidgetState();
}

class _NumberFilterWidgetState extends State<NumberFilterWidget> {
  static final _inputFormatter = FilteringTextInputFormatter.allow(
    RegExp('[0-9.,]'),
  );

  late NumberColumnOperator _operator;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _operator =
        widget.initialFilter?.operator ?? NumberColumnOperator.equalTo;
    _controller = TextEditingController(
      text: widget.initialFilter != null
          ? _format(widget.initialFilter!.value)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(double value) =>
      NumberFormat('#,##0.##', 'en_IN').format(value);

  double? _parse() {
    final cleaned = _controller.text.replaceAll(',', '').trim();
    return double.tryParse(cleaned);
  }

  void _apply() {
    final parsed = _parse();
    if (parsed == null) {
      widget.onApply(null);
      return;
    }
    widget.onApply(NumberColumnFilter(operator: _operator, value: parsed));
  }

  void _clear() => widget.onApply(null);

  @override
  Widget build(BuildContext context) {
    return FilterPopoverLayout(
      title: widget.title,
      operator: FilterOperatorSection<NumberColumnOperator>(
        value: _operator,
        items: NumberColumnOperator.values,
        labelBuilder: (v) => v.label,
        onChanged: (v) => setState(() => _operator = v),
      ),
      input: FilterNumberInput(
        controller: _controller,
        prefixText: widget.prefixText,
        hintText: widget.hintText,
        inputFormatters: [_inputFormatter],
        onSubmitted: (_) => _apply(),
      ),
      onClear: _clear,
      onApply: _apply,
    );
  }
}
