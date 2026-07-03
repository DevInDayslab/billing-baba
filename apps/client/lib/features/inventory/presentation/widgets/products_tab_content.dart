import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_async_list.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_primary_button.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/product_detail_panel.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsTabContent extends ConsumerStatefulWidget {
  const ProductsTabContent({super.key});

  @override
  ConsumerState<ProductsTabContent> createState() => _ProductsTabContentState();
}

class _ProductsTabContentState extends ConsumerState<ProductsTabContent> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(productSearchQueryProvider.notifier).query = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final trimmed = query.trim();
      ref.read(productBackendSearchProvider.notifier).query = trimmed;
      unawaited(
        ref
            .read(inventoryItemsProvider.notifier)
            .refresh(searchQuery: trimmed.isEmpty ? null : trimmed),
      );
    });
  }

  Future<void> _confirmDelete(BuildContext context, InventoryItem item) async {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final itemsAsync = ref.watch(inventoryItemsProvider);
    final selectedId = ref.watch(selectedProductIdProvider);

    return InventorySplitLayout(
      listPanel: _ProductsListPanel(
        products: products,
        itemsAsync: itemsAsync,
        selectedId: selectedId,
        onSearchChanged: _onSearchChanged,
        onRefresh: () => ref.read(inventoryItemsProvider.notifier).refresh(
          searchQuery: ref.read(productBackendSearchProvider),
        ),
        onItemSelected: (id) =>
            ref.read(selectedProductIdProvider.notifier).selected = id,
        onAddItem: () => showAddItemDialog(context),
        onMenuSelected: (value, item) {
          switch (value) {
            case 'Edit':
              showAddItemDialog(
                context,
                initialType: item.type,
                editItem: item,
              );
            case 'Delete':
              unawaited(_confirmDelete(context, item));
          }
        },
      ),
      detailPanel: selectedId == null
          ? const InventoryDetailPlaceholder(
              message: 'Select an item to view details',
            )
          : products.any((item) => item.id == selectedId)
          ? ProductDetailPanel(
              item: products.firstWhere((item) => item.id == selectedId),
            )
          : const InventoryDetailPlaceholder(
              message: 'Select an item to view details',
            ),
    );
  }
}

class _ProductsListPanel extends StatelessWidget {
  const _ProductsListPanel({
    required this.products,
    required this.itemsAsync,
    required this.selectedId,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onItemSelected,
    required this.onAddItem,
    required this.onMenuSelected,
  });

  final List<InventoryItem> products;
  final AsyncValue<List<InventoryItem>> itemsAsync;
  final String? selectedId;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onItemSelected;
  final VoidCallback onAddItem;
  final void Function(String value, InventoryItem item) onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              InventorySearchField(
                hint: 'Search',
                showSettings: true,
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: InventoryPrimaryButton(
                      label: 'Add Item',
                      onPressed: onAddItem,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const InventoryListHeader(
          columns: [
            InventoryListColumn(label: 'ITEM'),
            InventoryListColumn(label: 'QUANTITY', showFilter: true),
          ],
        ),
        Expanded(
          child: InventoryAsyncList<InventoryItem>(
            asyncValue: itemsAsync,
            items: products,
            onRefresh: onRefresh,
            itemBuilder: (context, item) {
              final isSelected = item.id == selectedId;
              return _ProductListTile(
                item: item,
                isSelected: isSelected,
                onTap: () => onItemSelected(item.id),
                onMenuSelected: (value) => onMenuSelected(value, item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.onMenuSelected,
  });

  final InventoryItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<String> onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final quantity = item.quantity;
    final quantityColor = quantity != null && quantity < 0
        ? inventoryNegativeColor
        : quantity != null && quantity > 0
        ? inventoryPositiveColor
        : AppColors.textPrimary;

    return Material(
      color: isSelected ? inventorySelectedRowColor : Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: inventoryCardBorder)),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          quantity?.toString() ?? '-',
                          style: TextStyle(fontSize: 13, color: quantityColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: InventoryListRowMenu(onSelected: onMenuSelected),
            ),
          ],
        ),
      ),
    );
  }
}
