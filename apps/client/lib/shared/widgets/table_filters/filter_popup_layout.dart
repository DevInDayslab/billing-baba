import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_widgets.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_theme.dart';
import 'package:flutter/material.dart';

/// Canonical filter popover layout: Title → Operator → Input(s) → Actions.
class FilterPopoverLayout extends StatelessWidget {
  const FilterPopoverLayout({
    required this.title,
    required this.operator,
    required this.input,
    required this.onClear,
    required this.onApply,
    this.width = TableFilterTheme.popoverWidth,
    this.applyEnabled = true,
    super.key,
  });

  final String title;
  final Widget operator;
  final Widget input;
  final VoidCallback onClear;
  final VoidCallback onApply;
  final double width;
  final bool applyEnabled;

  @override
  Widget build(BuildContext context) {
    return FilterPopoverShell(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          operator,
          const SizedBox(height: AppSpacing.md),
          input,
          const SizedBox(height: AppSpacing.md),
          FilterActionButtons(
            onClear: onClear,
            onApply: onApply,
            applyEnabled: applyEnabled,
          ),
        ],
      ),
    );
  }
}

/// Operator section label + dropdown row.
class FilterOperatorSection<T> extends StatelessWidget {
  const FilterOperatorSection({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    super.key,
  });

  final T value;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterOperatorDropdown<T>(
      value: value,
      items: items,
      labelBuilder: labelBuilder,
      onChanged: onChanged,
    );
  }
}
