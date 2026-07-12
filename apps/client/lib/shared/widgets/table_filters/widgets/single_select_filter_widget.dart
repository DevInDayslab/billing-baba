import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_layout.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_widgets.dart';
import 'package:flutter/material.dart';

typedef SelectFilterApplyCallback = void Function(SelectColumnFilter? filter);

/// Single-select filter — Vyapar-style dropdown.
class SingleSelectFilterWidget extends StatefulWidget {
  const SingleSelectFilterWidget({
    required this.title,
    required this.options,
    required this.initialFilter,
    required this.onApply,
    super.key,
  });

  final String title;
  final List<String> options;
  final SelectColumnFilter? initialFilter;
  final SelectFilterApplyCallback onApply;

  @override
  State<SingleSelectFilterWidget> createState() =>
      _SingleSelectFilterWidgetState();
}

class _SingleSelectFilterWidgetState extends State<SingleSelectFilterWidget> {
  static const _allLabel = 'All';

  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialFilter?.value ?? _allLabel;
  }

  List<String> get _items => [_allLabel, ...widget.options];

  void _apply() {
    if (_selected == _allLabel) {
      widget.onApply(null);
      return;
    }
    widget.onApply(SelectColumnFilter(value: _selected));
  }

  void _clear() => widget.onApply(null);

  @override
  Widget build(BuildContext context) {
    return FilterPopoverLayout(
      title: widget.title,
      operator: const SizedBox.shrink(),
      input: FilterOperatorDropdown<String>(
        value: _selected,
        items: _items,
        labelBuilder: (v) => v,
        onChanged: (v) => setState(() => _selected = v),
      ),
      onClear: _clear,
      onApply: _apply,
    );
  }
}
