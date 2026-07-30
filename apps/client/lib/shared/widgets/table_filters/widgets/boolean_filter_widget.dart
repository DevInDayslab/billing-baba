import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_layout.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_widgets.dart';
import 'package:flutter/material.dart';

typedef BooleanFilterApplyCallback = void Function(BooleanColumnFilter? filter);

/// Boolean filter — All / Yes / No radio buttons (Vyapar).
class BooleanFilterWidget extends StatefulWidget {
  const BooleanFilterWidget({
    required this.title,
    required this.initialFilter,
    required this.onApply,
    super.key,
  });

  final String title;
  final BooleanColumnFilter? initialFilter;
  final BooleanFilterApplyCallback onApply;

  @override
  State<BooleanFilterWidget> createState() => _BooleanFilterWidgetState();
}

class _BooleanFilterWidgetState extends State<BooleanFilterWidget> {
  bool? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialFilter?.value;
  }

  void _apply() {
    if (_selected == null) {
      widget.onApply(null);
      return;
    }
    widget.onApply(BooleanColumnFilter(value: _selected));
  }

  void _clear() => widget.onApply(null);

  @override
  Widget build(BuildContext context) {
    return FilterPopoverLayout(
      title: widget.title,
      input: Column(
        children: [
          FilterRadioTile(
            label: 'All',
            isSelected: _selected == null,
            onTap: () => setState(() => _selected = null),
          ),
          FilterRadioTile(
            label: 'Yes',
            isSelected: _selected == true,
            onTap: () => setState(() => _selected = true),
          ),
          FilterRadioTile(
            label: 'No',
            isSelected: _selected == false,
            onTap: () => setState(() => _selected = false),
          ),
        ],
      ),
      onClear: _clear,
      onApply: _apply,
    );
  }
}
