import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/stock_summary_mobile_filters.dart';
import 'package:flutter/material.dart';

/// Category option shown in the stock summary filter sheet.
class StockSummaryCategoryOption {
  const StockSummaryCategoryOption({
    required this.id,
    required this.label,
  });

  final String? id;
  final String label;
}

/// Opens the two-column stock summary filter bottom sheet.
Future<StockSummaryMobileFilters?> showStockSummaryFilterSheet({
  required BuildContext context,
  required StockSummaryMobileFilters initial,
  required List<StockSummaryCategoryOption> categories,
}) {
  return showMobileBottomSheet<StockSummaryMobileFilters>(
    context: context,
    maxHeightFraction: 0.72,
    builder: (sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Filters',
                    style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          _StockSummaryFilterBody(
            initial: initial,
            categories: categories,
            sheetContext: sheetContext,
          ),
        ],
      );
    },
  );
}

class _StockSummaryFilterBody extends StatefulWidget {
  const _StockSummaryFilterBody({
    required this.initial,
    required this.categories,
    required this.sheetContext,
  });

  final StockSummaryMobileFilters initial;
  final List<StockSummaryCategoryOption> categories;
  final BuildContext sheetContext;

  @override
  State<_StockSummaryFilterBody> createState() =>
      _StockSummaryFilterBodyState();
}

class _StockSummaryFilterBodyState extends State<_StockSummaryFilterBody> {
  late StockSummaryFilterSection _section;
  late String? _categoryId;
  late String _categoryLabel;
  late StockSummaryStockFilter _stock;
  late StockSummaryStatusFilter _status;

  @override
  void initState() {
    super.initState();
    _section = StockSummaryFilterSection.category;
    _categoryId = widget.initial.categoryId;
    _categoryLabel = widget.initial.categoryLabel;
    _stock = widget.initial.stock;
    _status = widget.initial.status;
  }

  void _reset() {
    setState(() {
      _section = StockSummaryFilterSection.category;
      _categoryId = null;
      _categoryLabel = 'All';
      _stock = StockSummaryStockFilter.all;
      _status = StockSummaryStatusFilter.all;
    });
  }

  void _apply() {
    Navigator.of(widget.sheetContext).pop(
      StockSummaryMobileFilters(
        categoryId: _categoryId,
        categoryLabel: _categoryLabel,
        stock: _stock,
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 280,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FilterSectionNav(
                selected: _section,
                onSelected: (section) => setState(() => _section = section),
              ),
              Expanded(child: _buildOptions()),
            ],
          ),
        ),
        _StockSummaryFilterFooter(onReset: _reset, onApply: _apply),
      ],
    );
  }

  Widget _buildOptions() {
    return switch (_section) {
      StockSummaryFilterSection.category => _RadioOptionList<String?>(
        options: [
          for (final category in widget.categories)
            _RadioOption(
              value: category.id,
              label: category.label,
            ),
        ],
        selected: _categoryId,
        onSelected: (value) {
          final option = widget.categories.firstWhere(
            (category) => category.id == value,
          );
          setState(() {
            _categoryId = value;
            _categoryLabel = option.label;
          });
        },
      ),
      StockSummaryFilterSection.stock => _RadioOptionList<StockSummaryStockFilter>(
        options: [
          for (final option in StockSummaryStockFilter.values)
            _RadioOption(value: option, label: option.label),
        ],
        selected: _stock,
        onSelected: (value) => setState(() => _stock = value),
      ),
      StockSummaryFilterSection.status => _RadioOptionList<StockSummaryStatusFilter>(
        options: [
          for (final option in StockSummaryStatusFilter.values)
            _RadioOption(value: option, label: option.label),
        ],
        selected: _status,
        onSelected: (value) => setState(() => _status = value),
      ),
    };
  }
}

class _FilterSectionNav extends StatelessWidget {
  const _FilterSectionNav({
    required this.selected,
    required this.onSelected,
  });

  final StockSummaryFilterSection selected;
  final ValueChanged<StockSummaryFilterSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 132,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final section in StockSummaryFilterSection.values)
            InkWell(
              onTap: () => onSelected(section),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: selected == section
                      ? AppColors.surface
                      : Colors.transparent,
                  border: selected == section
                      ? const Border(
                          left: BorderSide(color: AppColors.primary, width: 3),
                        )
                      : null,
                ),
                child: Text(
                  section.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: selected == section
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selected == section
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RadioOption<T> {
  const _RadioOption({required this.value, required this.label});

  final T value;
  final String label;
}

class _RadioOptionList<T> extends StatelessWidget {
  const _RadioOptionList({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<_RadioOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: options.length,
      separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFE8EAED)),
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = option.value == selected;

        return InkWell(
          onTap: () => onSelected(option.value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StockSummaryFilterFooter extends StatelessWidget {
  const _StockSummaryFilterFooter({
    required this.onReset,
    required this.onApply,
  });

  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: const Color(0xFFF3F0FF),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBorder,
                ),
              ),
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FilledButton(
              onPressed: onApply,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBorder,
                ),
              ),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
