import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _panelBorder = Color(0xFFE0E0E0);

const systemFilterOptions = [
  'Activities',
  'Cadences',
  'Latest Email Status',
  'Locked',
  'Record Action',
  'Related Records Action',
  'Touched Records',
  'Untouched Records',
];

const fieldFilterOptions = [
  'Account Name',
  'Amount',
  'Closing Date',
  'Deal Name',
  'Deal Owner',
  'Stage',
];

class DealsFilterPanel extends StatefulWidget {
  const DealsFilterPanel({
    required this.systemFilters,
    required this.fieldFilters,
    required this.onSystemFilterToggle,
    required this.onFieldFilterToggle,
    super.key,
  });

  final Set<String> systemFilters;
  final Set<String> fieldFilters;
  final ValueChanged<String> onSystemFilterToggle;
  final ValueChanged<String> onFieldFilterToggle;

  @override
  State<DealsFilterPanel> createState() => _DealsFilterPanelState();
}

class _DealsFilterPanelState extends State<DealsFilterPanel> {
  String _searchQuery = '';
  bool _systemExpanded = true;
  bool _fieldsExpanded = true;

  List<String> _filterOptions(List<String> options) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return options;
    return options
        .where((option) => option.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final systemOptions = _filterOptions(systemFilterOptions);
    final fieldOptions = _filterOptions(fieldFilterOptions);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _panelBorder),
        borderRadius: AppRadius.mdBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Deals by',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(fontSize: 13),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mdBorder,
                      borderSide: const BorderSide(color: _panelBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.mdBorder,
                      borderSide: const BorderSide(color: _panelBorder),
                    ),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _panelBorder),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              children: [
                _FilterSection(
                  title: 'System Defined Filters',
                  expanded: _systemExpanded,
                  onToggle: () =>
                      setState(() => _systemExpanded = !_systemExpanded),
                  children: systemOptions
                      .map(
                        (option) => _FilterCheckbox(
                          label: option,
                          checked: widget.systemFilters.contains(option),
                          onChanged: () => widget.onSystemFilterToggle(option),
                        ),
                      )
                      .toList(),
                ),
                _FilterSection(
                  title: 'Filter By Fields',
                  expanded: _fieldsExpanded,
                  onToggle: () =>
                      setState(() => _fieldsExpanded = !_fieldsExpanded),
                  children: fieldOptions
                      .map(
                        (option) => _FilterCheckbox(
                          label: option,
                          checked: widget.fieldFilters.contains(option),
                          onChanged: () => widget.onFieldFilterToggle(option),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Icon(
                  expanded ? Icons.expand_more : Icons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...children,
      ],
    );
  }
}

class _FilterCheckbox extends StatelessWidget {
  const _FilterCheckbox({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final bool checked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.sm,
          top: 2,
          bottom: 2,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: checked,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
