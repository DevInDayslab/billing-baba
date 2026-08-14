import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/application/pos_cart_state.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/presentation/mobile/widgets/pos_item_card.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PosCatalogBody extends ConsumerWidget {
  const PosCatalogBody({
    required this.items,
    required this.searchQuery,
    super.key,
  });

  final List<PosItem> items;
  final String searchQuery;

  Future<void> _onRefresh(WidgetRef ref) async {
    await Future.wait([
      ref.read(inventoryItemsProvider.notifier).refresh(),
      ref.read(inventoryCategoriesProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(posCartProvider);
    final theme = Theme.of(context);

    if (items.isEmpty) {
      final hasSearch = searchQuery.trim().isNotEmpty;
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _onRefresh(ref),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: MobileEmptyState(
                title: hasSearch ? 'No matching items' : 'No items yet',
                message: hasSearch
                    ? 'Try a different search term or category.'
                    : 'Add inventory items to start selling from POS.',
                icon: hasSearch
                    ? Icons.search_off_rounded
                    : Icons.inventory_2_outlined,
              ),
            ),
          ],
        ),
      );
    }

    final groups = _groupByCategory(items);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _onRefresh(ref),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          for (final group in groups) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppSpacing.sm,
                ),
                child: Text(
                  '${group.name} (${group.items.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                // Taller cells so price + qty stepper never clip.
                childAspectRatio: 0.58,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = group.items[index];
                  return PosItemCard(
                    item: item,
                    cartQty: _cartQuantityFor(item.id, cartState),
                  );
                },
                childCount: group.items.length,
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        ],
      ),
    );
  }
}

int _cartQuantityFor(String itemId, PosCartState cartState) {
  return cartState.items
      .where((cartItem) => cartItem.item.id == itemId)
      .fold<int>(0, (sum, cartItem) => sum + cartItem.quantity);
}

class _CategoryGroup {
  const _CategoryGroup({required this.name, required this.items});

  final String name;
  final List<PosItem> items;
}

List<_CategoryGroup> _groupByCategory(List<PosItem> items) {
  final groups = <String, List<PosItem>>{};
  final order = <String>[];

  for (final item in items) {
    final key = item.categoryName;
    if (!groups.containsKey(key)) {
      order.add(key);
      groups[key] = [];
    }
    groups[key]!.add(item);
  }

  return order.map((name) {
    final categoryItems = groups[name]!
      ..sort((a, b) {
        if (a.isOutOfStock == b.isOutOfStock) return 0;
        return a.isOutOfStock ? 1 : -1;
      });
    return _CategoryGroup(name: name, items: categoryItems);
  }).toList();
}
