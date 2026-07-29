import 'dart:async';

import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_list_image_warmup.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/paginated_inventory_items.dart';
import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_item_workspace.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsTabContent extends ConsumerWidget {
  const ProductsTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final pageAsync = ref.watch(inventoryItemsProvider);
    final itemsAsync = pageAsync.itemsOnly;
    final selectedId = ref.watch(selectedProductIdProvider);
    final searchQuery = ref.watch(productSearchQueryProvider);
    final backendSearchQuery = ref.watch(productBackendSearchProvider);

    return InventoryItemWorkspace(
      items: products,
      itemsAsync: itemsAsync,
      hasMore: pageAsync.value?.hasMore ?? false,
      isLoadingMore: pageAsync.value?.isLoadingMore ?? false,
      onLoadMore: () => ref.read(inventoryItemsProvider.notifier).loadMore(),
      selectedId: selectedId,
      searchQuery: searchQuery,
      backendSearchQuery: backendSearchQuery,
      detailMode: InventoryDetailHeaderMode.product,
      searchHint: 'Search products',
      addButtonLabel: 'Add Item',
      emptyMessage: 'No products found',
      placeholderMessage: 'Select an item to view ledger',
      primaryColumnLabel: 'ITEM',
      secondaryColumnLabel: 'QUANTITY',
      trailingValueBuilder: (item) {
        final metrics = InventoryStockCalculator.metricsFromItem(item);
        return formatQuantityValue(metrics.physicalQuantity);
      },
      trailingColorBuilder: (item) {
        final metrics = InventoryStockCalculator.metricsFromItem(item);
        return listQuantityColor(
          metrics.physicalQuantity,
          reorderLevel: item.reorderLevel,
        );
      },
      onLocalSearchChanged: (query) {
        ref.read(productSearchQueryProvider.notifier).query = query;
      },
      onBackendSearchChanged: (query) {
        ref.read(productBackendSearchProvider.notifier).query = query;
      },
      onSelectedIdChanged: (id) {
        ref.read(selectedProductIdProvider.notifier).selected = id;
      },
      onSelectionChangedSideEffects: (previousId, nextId) {
        ref.read(productTransactionFiltersProvider.notifier).reset();
        ref.read(selectedProductTransactionIdProvider.notifier).select(null);
        final items = ref.read(inventoryItemListProvider);
        final item = items.where((entry) => entry.id == nextId).firstOrNull;
        if (item != null) {
          ref.read(inventoryListImageWarmupProvider).warmItem(item);
        }
      },
      onRefresh: () => ref
          .read(inventoryItemsProvider.notifier)
          .refresh(
            searchQuery: ref.read(productBackendSearchProvider),
          ),
      onAddPressed: () => unawaited(showAddItemDialog(context)),
      onMenuSelected: (value, item) {
        switch (value) {
          case 'Edit':
            unawaited(
              showAddItemDialog(
                context,
                initialType: item.type,
                editItem: item,
              ),
            );
          case 'Delete':
            unawaited(_confirmDelete(context, ref, item));
        }
      },
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  InventoryItem item,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete item?'),
      content: Text('Delete "${item.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final error = await ref
      .read(inventoryItemsProvider.notifier)
      .deleteItem(item.id);
  if (!context.mounted) return;
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}
