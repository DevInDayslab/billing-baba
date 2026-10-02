import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_brands_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/models/inventory_item_filters.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Multi-select inventory item filter sheet with exclusive raw-material pairs.
Future<InventoryItemFiltersState?> showMobileInventoryItemFilterSheet({
  required BuildContext context,
  required InventoryItemFiltersState initial,
}) {
  return showMobileBottomSheet<InventoryItemFiltersState>(
    context: context,
    heightFraction: 0.78,
    scrollBody: false,
    titleWidget: const _FilterSheetHeader(),
    builder: (sheetContext) {
      return _InventoryItemFilterBody(
        initial: initial,
        onApply: (value) => Navigator.of(sheetContext).pop(value),
      );
    },
  );
}

class _FilterSheetHeader extends StatelessWidget {
  const _FilterSheetHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Filter Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Divider(
          height: 1,
          thickness: 1,
          color: AppColors.textSecondary.withValues(alpha: 0.15),
        ),
      ],
    );
  }
}

class _InventoryItemFilterBody extends ConsumerStatefulWidget {
  const _InventoryItemFilterBody({
    required this.initial,
    required this.onApply,
  });

  final InventoryItemFiltersState initial;
  final ValueChanged<InventoryItemFiltersState> onApply;

  @override
  ConsumerState<_InventoryItemFilterBody> createState() =>
      _InventoryItemFilterBodyState();
}

class _InventoryItemFilterBodyState
    extends ConsumerState<_InventoryItemFilterBody> {
  static const _applyRed = Color(0xFFE53935);
  static const _clearBackground = Color(0xFFF5F5F5);

  late Set<InventoryItemFilterOption> _selection;
  late Set<String> _brandIds;
  late Set<String> _categoryIds;

  @override
  void initState() {
    super.initState();
    _selection = Set<InventoryItemFilterOption>.from(widget.initial.selected);
    _brandIds = Set<String>.from(widget.initial.brandIds);
    _categoryIds = Set<String>.from(widget.initial.categoryIds);
  }

  void _toggle(InventoryItemFilterOption option) {
    setState(() {
      if (_selection.contains(option)) {
        _selection.remove(option);
        return;
      }

      _selection.add(option);
      if (option == InventoryItemFilterOption.showRawMaterialsOnly) {
        _selection.remove(InventoryItemFilterOption.hideRawMaterials);
      } else if (option == InventoryItemFilterOption.hideRawMaterials) {
        _selection.remove(InventoryItemFilterOption.showRawMaterialsOnly);
      }
    });
  }

  void _toggleId(Set<String> target, String id) {
    setState(() {
      if (target.contains(id)) {
        target.remove(id);
      } else {
        target.add(id);
      }
    });
  }

  void _clear() {
    setState(() {
      _selection.clear();
      _brandIds.clear();
      _categoryIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brands = ref.watch(inventoryBrandsProvider).value ?? const [];
    final categories =
        ref
            .watch(inventoryCategoriesProvider)
            .value
            ?.where((c) => !c.isUncategorized)
            .toList() ??
        const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final option in inventoryListFilterOptions) ...[
                _FilterRow(
                  label: option.label,
                  selected: _selection.contains(option),
                  onTap: () => _toggle(option),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.textSecondary.withValues(alpha: 0.12),
                ),
              ],
              if (categories.isNotEmpty) ...[
                const _SectionLabel('Categories'),
                for (final category in categories)
                  _FilterRow(
                    label: category.name,
                    selected: _categoryIds.contains(category.id),
                    onTap: () => _toggleId(_categoryIds, category.id),
                  ),
              ],
              if (brands.isNotEmpty) ...[
                const _SectionLabel('Brands'),
                for (final brand in brands)
                  _FilterRow(
                    label: brand.name,
                    selected: _brandIds.contains(brand.id),
                    onTap: () => _toggleId(_brandIds, brand.id),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clear,
                style: OutlinedButton.styleFrom(
                  backgroundColor: _clearBackground,
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide.none,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Clear',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: () => widget.onApply(
                  InventoryItemFiltersState(
                    selected: Set.unmodifiable(_selection),
                    brandIds: Set.unmodifiable(_brandIds),
                    categoryIds: Set.unmodifiable(_categoryIds),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _applyRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _FilterCheckbox(value: selected, onChanged: (_) => onTap()),
          ],
        ),
      ),
    );
  }
}

class _FilterCheckbox extends StatelessWidget {
  const _FilterCheckbox({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
