import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_inputs.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_layout.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_widgets.dart';
import 'package:flutter/material.dart';

typedef MultiSelectFilterApplyCallback = void Function(
  MultiSelectColumnFilter? filter,
);

/// Multi-select filter — checkbox list with optional search (Vyapar).
class MultiSelectFilterWidget extends StatefulWidget {
  const MultiSelectFilterWidget({
    required this.title,
    required this.options,
    required this.initialFilter,
    required this.onApply,
    this.searchable = true,
    this.exclusivePairs = const [],
    super.key,
  });

  final String title;
  final List<String> options;
  final MultiSelectColumnFilter? initialFilter;
  final MultiSelectFilterApplyCallback onApply;
  final bool searchable;
  final List<(String, String)> exclusivePairs;

  @override
  State<MultiSelectFilterWidget> createState() =>
      _MultiSelectFilterWidgetState();
}

class _MultiSelectFilterWidgetState extends State<MultiSelectFilterWidget> {
  late Set<String> _selected;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.initialFilter?.values ?? {});
    _searchController = TextEditingController();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredOptions {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.options;
    return widget.options
        .where((o) => o.toLowerCase().contains(query))
        .toList();
  }

  void _toggle(String option) {
    setState(() {
      if (_selected.contains(option)) {
        _selected.remove(option);
        return;
      }
      for (final (a, b) in widget.exclusivePairs) {
        if (option == a) _selected.remove(b);
        if (option == b) _selected.remove(a);
      }
      _selected.add(option);
    });
  }

  void _apply() {
    if (_selected.isEmpty) {
      widget.onApply(null);
      return;
    }
    widget.onApply(MultiSelectColumnFilter(values: _selected));
  }

  void _clear() => widget.onApply(null);

  @override
  Widget build(BuildContext context) {
    return FilterPopoverLayout(
      title: widget.title,
      operator: widget.searchable
          ? FilterTextInput(
              controller: _searchController,
              hintText: 'Search...',
            )
          : null,
      input: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final option in _filteredOptions)
              FilterCheckboxTile(
                label: option,
                isSelected: _selected.contains(option),
                onChanged: () => _toggle(option),
              ),
            if (_filteredOptions.isEmpty)
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
      ),
      onClear: _clear,
      onApply: _apply,
    );
  }
}
