import 'dart:async';

import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/paginated_inventory_items.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_item_bulk_menu.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_item_workspace.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ServicesTabContent extends ConsumerWidget {
  const ServicesTabContent({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider);
    final pageAsync = ref.watch(inventoryItemsProvider);
    final itemsAsync = pageAsync.itemsOnly;
    final selectedId = ref.watch(selectedServiceIdProvider);
    final searchQuery = ref.watch(serviceSearchQueryProvider);
    final backendSearchQuery = ref.watch(serviceBackendSearchProvider);

    return InventoryItemWorkspace(
      items: services,
      itemsAsync: itemsAsync,
      hasMore: pageAsync.value?.hasMore ?? false,
      isLoadingMore: pageAsync.value?.isLoadingMore ?? false,
      onLoadMore: () => ref.read(inventoryItemsProvider.notifier).loadMore(),
      selectedId: selectedId,
      searchQuery: searchQuery,
      backendSearchQuery: backendSearchQuery,
      detailMode: InventoryDetailHeaderMode.service,
      searchHint: 'Search services',
      addButtonLabel: 'Add Service',
      emptyMessage: 'No services found',
      placeholderMessage: 'Select a service to view ledger',
      primaryColumnLabel: 'SERVICE',
      secondaryColumnLabel: 'SALE PRICE',
      leadingIcon: Icons.handyman_outlined,
      trailingValueBuilder: (item) {
        return item.salePrice != null
            ? _currencyFormat.format(item.salePrice)
            : inventoryEmDash;
      },
      trailingColorBuilder: (_) => null,
      onLocalSearchChanged: (query) {
        ref.read(serviceSearchQueryProvider.notifier).query = query;
      },
      onBackendSearchChanged: (query) {
        ref.read(serviceBackendSearchProvider.notifier).query = query;
      },
      onSelectedIdChanged: (id) {
        ref.read(selectedServiceIdProvider.notifier).selected = id;
      },
      onSelectionChangedSideEffects: (previousId, nextId) {
        ref.read(productTransactionFiltersProvider.notifier).reset();
        ref.read(selectedProductTransactionIdProvider.notifier).select(null);
      },
      onRefresh: () => ref
          .read(inventoryItemsProvider.notifier)
          .refresh(
            searchQuery: ref.read(serviceBackendSearchProvider),
          ),
      onAddPressed: () => unawaited(
        showAddItemDialog(
          context,
          initialType: ItemType.service,
        ),
      ),
      onImportItems: () => context.push(AppRoutes.utilitiesImportItems),
      itemType: ItemType.service,
      onItemDoubleTap: (item) => unawaited(
        showAddItemDialog(
          context,
          initialType: item.type,
          editItem: item,
        ),
      ),
      toolbarMenuItems: buildInventoryItemBulkMenuItems(
        context: context,
        itemType: ItemType.service,
      ),
      onMenuSelected: (value, item) {
        switch (value) {
          case 'Edit':
            unawaited(
              showAddItemDialog(
                context,
                initialType: ItemType.service,
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
      title: const Text('Delete service?'),
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
