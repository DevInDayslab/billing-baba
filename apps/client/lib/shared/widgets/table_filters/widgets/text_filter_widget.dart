import 'package:billing_baba/shared/widgets/table_filters/filter_inputs.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_layout.dart';
import 'package:flutter/material.dart';

typedef TextFilterApplyCallback = void Function(TextColumnFilter? filter);

/// Text filter — Contains / Exact Match only (Vyapar).
class TextFilterWidget extends StatefulWidget {
  const TextFilterWidget({
    required this.title,
    required this.initialFilter,
    required this.onApply,
    this.hintText = 'Enter value',
    super.key,
  });

  final String title;
  final TextColumnFilter? initialFilter;
  final TextFilterApplyCallback onApply;
  final String hintText;

  @override
  State<TextFilterWidget> createState() => _TextFilterWidgetState();
}

class _TextFilterWidgetState extends State<TextFilterWidget> {
  late TextColumnOperator _operator;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _operator = widget.initialFilter?.operator ?? TextColumnOperator.contains;
    _controller = TextEditingController(
      text: widget.initialFilter?.value ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      widget.onApply(null);
      return;
    }
    widget.onApply(TextColumnFilter(operator: _operator, value: value));
  }

  void _clear() => widget.onApply(null);

  @override
  Widget build(BuildContext context) {
    return FilterPopoverLayout(
      title: widget.title,
      operator: FilterOperatorSection<TextColumnOperator>(
        value: _operator,
        items: TextColumnOperator.values,
        labelBuilder: (v) => v.label,
        onChanged: (v) => setState(() => _operator = v),
      ),
      input: FilterTextInput(
        controller: _controller,
        hintText: widget.hintText,
        autofocus: true,
        onSubmitted: (_) => _apply(),
      ),
      onClear: _clear,
      onApply: _apply,
    );
  }
}
