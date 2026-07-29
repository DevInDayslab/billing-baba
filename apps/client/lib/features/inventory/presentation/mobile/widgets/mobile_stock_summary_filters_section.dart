import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/application/mobile_stock_summary_models.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/application/mobile_stock_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileStockSummaryFiltersSection extends ConsumerWidget {
  const MobileStockSummaryFiltersSection({
    required this.categoryLabel,
    required this.onFiltersTap,
    super.key,
  });

  final String categoryLabel;
  final VoidCallback onFiltersTap;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(mobileStockSummaryFiltersProvider);
    final notifier = ref.read(mobileStockSummaryFiltersProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: filters.asOnDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                notifier.setAsOnDate(picked);
              }
            },
            borderRadius: AppRadius.smBorder,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: filters.useAsOnDate,
                    onChanged: (value) =>
                        notifier.setUseAsOnDate(value ?? false),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Show stock as on Date: ${_dateFormat.format(filters.asOnDate)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Text(
                'Filters Applied:',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onFiltersTap,
                icon: const Icon(Icons.filter_list_rounded, size: 18),
                label: const Text('Filters'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              _FilterChip(label: 'Item Category - $categoryLabel'),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(label: 'Stock - ${filters.stockFilter.label}'),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(label: 'Status - ${filters.statusFilter.label}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

Future<void> showMobileStockSummaryFiltersSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return Consumer(
        builder: (context, ref, _) {
          final filters = ref.watch(mobileStockSummaryFiltersProvider);
          final notifier = ref.read(mobileStockSummaryFiltersProvider.notifier);
          final categories = ref.watch(categoriesProvider);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Filters',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          notifier.resetFilters();
                          Navigator.of(sheetContext).pop();
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FilterSectionTitle(title: 'Item Category'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _SelectableChip(
                        label: 'All',
                        selected: filters.categoryId == null,
                        onTap: () => notifier.setCategoryId(null),
                      ),
                      for (final InventoryCategory category in categories)
                        if (!category.isUncategorized)
                          _SelectableChip(
                            label: category.name,
                            selected: filters.categoryId == category.id,
                            onTap: () => notifier.setCategoryId(category.id),
                          ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _FilterSectionTitle(title: 'Stock'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final filter in MobileStockSummaryStockFilter.values)
                        _SelectableChip(
                          label: filter.label,
                          selected: filters.stockFilter == filter,
                          onTap: () => notifier.setStockFilter(filter),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _FilterSectionTitle(title: 'Status'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final filter
                          in MobileStockSummaryStatusFilter.values)
                        _SelectableChip(
                          label: filter.label,
                          selected: filters.statusFilter == filter,
                          onTap: () => notifier.setStatusFilter(filter),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _FilterSectionTitle extends StatelessWidget {
  const _FilterSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: const Color(0xFFE8F4FD),
      side: BorderSide(
        color: selected ? const Color(0xFF90CAF9) : const Color(0xFFE0E0E0),
      ),
    );
  }
}
