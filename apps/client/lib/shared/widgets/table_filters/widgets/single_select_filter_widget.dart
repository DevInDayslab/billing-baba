import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_inputs.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_layout.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_widgets.dart';
import 'package:flutter/material.dart';

typedef SelectFilterApplyCallback = void Function(SelectColumnFilter? filter);

/// Single-select filter — radio list with optional search.
class SingleSelectFilterWidget extends StatefulWidget {
  const SingleSelectFilterWidget({
    required this.title,
    required this.options,
    required this.initialFilter,
    required this.onApply,
    this.searchable = true,
    super.key,
  });

  final String title;
  final List<String> options;
  final SelectColumnFilter? initialFilter;
  final SelectFilterApplyCallback onApply;
  final bool searchable;

  @override
  State<SingleSelectFilterWidget> createState() =>
      _SingleSelectFilterWidgetState();
}

class _SingleSelectFilterWidgetState extends State<SingleSelectFilterWidget> {
  static const _allLabel = 'All';

  late String _selected;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialFilter?.value ?? _allLabel;
    _searchController = TextEditingController();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    if (!widget.searchable || query.isEmpty) {
      return [_allLabel, ...widget.options];
    }

    final filteredOptions = widget.options
        .where((option) => option.toLowerCase().contains(query))
        .toList();

    return [_allLabel, ...filteredOptions];
  }

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
    final items = _filteredItems;

    return FilterPopoverLayout(
      title: widget.title,
      operator: widget.searchable
          ? FilterTextInput(
              controller: _searchController,
              hintText: 'Search...',
            )
          : null,
      input: Column(
        children: [
          for (final item in items)
            FilterRadioTile(
              label: item,
              isSelected: _selected == item,
              onTap: () => setState(() => _selected = item),
            ),
          if (items.length == 1)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Text(
                'No matches',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
      onClear: _clear,
      onApply: _apply,
    );
  }
}
