import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_list_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Scrollable list of [ItemListCard] rows for the mobile items screen.
class ItemListView extends StatelessWidget {
  const ItemListView({
    required this.items,
    required this.categoryNamesById,
    super.key,
    this.onRefresh,
    this.onItemTap,
  });

  final List<InventoryItem> items;
  final Map<String, String> categoryNamesById;
  final Future<void> Function()? onRefresh;
  final ValueChanged<InventoryItem>? onItemTap;

  static const _listPadding = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.sm,
    AppSpacing.lg,
    AppSpacing.xl,
  );

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: _listPadding,
      itemCount: items.length,
      separatorBuilder: (_, _) => const Gap(AppSpacing.md),
      itemBuilder: (context, index) => _buildCard(index),
    );
  }

  /// Scrollable sliver variant for use inside [CustomScrollView].
  Widget buildSliver() {
    return SliverPadding(
      padding: _listPadding,
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const Gap(AppSpacing.md),
        itemBuilder: (context, index) => _buildCard(index),
      ),
    );
  }

  Widget _buildCard(int index) {
    final item = items[index];
    return ItemListCard(
      item: item,
      categoryName: categoryNamesById[item.categoryId],
      onTap: onItemTap == null ? null : () => onItemTap!(item),
    );
  }
}
