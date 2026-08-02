import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_items_provider.dart';
import 'package:billing_baba/features/pos/presentation/mobile/widgets/pos_add_category_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PosCategoryRail extends ConsumerWidget {
  const PosCategoryRail({
    required this.selectedCategoryId,
    required this.onCategorySelected,
    super.key,
  });

  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  static const double width = 80;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(posCategoriesProvider);
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: categories.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryRailTile(
              label: 'All',
              selected: selectedCategoryId == null,
              onTap: () => onCategorySelected(null),
              theme: theme,
            );
          }

          if (index == categories.length + 1) {
            return _CategoryRailTile(
              label: '+ Add',
              selected: false,
              onTap: () => showPosAddCategorySheet(context),
              theme: theme,
            );
          }

          final category = categories[index - 1];
          return _CategoryRailTile(
            label: category.name,
            selected: selectedCategoryId == category.id,
            onTap: () => onCategorySelected(category.id),
            theme: theme,
          );
        },
      ),
    );
  }
}

class _CategoryRailTile extends StatelessWidget {
  const _CategoryRailTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.md,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
              color: selected ? AppColors.primary : AppColors.textPrimary,
              height: 1.25,
            ),
          ),
        ),
      ),
    );
  }
}
