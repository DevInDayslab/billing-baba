import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_primary_button.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/product_detail_panel.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsTabContent extends ConsumerWidget {
  const ProductsTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final selectedId = ref.watch(selectedProductIdProvider);

    return InventorySplitLayout(
      listPanel: _ProductsListPanel(
        products: products,
        selectedId: selectedId,
        onSearchChanged: (query) =>
            ref.read(productSearchQueryProvider.notifier).update(query),
        onItemSelected: (id) =>
            ref.read(selectedProductIdProvider.notifier).select(id),
        onAddItem: () => showAddItemDialog(
          context,
        ),
      ),
      detailPanel: selectedId == null
          ? const InventoryDetailPlaceholder(
              message: 'Select an item to view details',
            )
          : ProductDetailPanel(
              item: products.firstWhere((item) => item.id == selectedId),
            ),
    );
  }
}

class _ProductsListPanel extends StatelessWidget {
  const _ProductsListPanel({
    required this.products,
    required this.selectedId,
    required this.onSearchChanged,
    required this.onItemSelected,
    required this.onAddItem,
  });

  final List<InventoryItem> products;
  final String? selectedId;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onItemSelected;
  final VoidCallback onAddItem;

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
                      showDropdown: true,
                      onPressed: onAddItem,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  InventoryPopupMenuButton<String>(
                    onSelected: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$value coming soon')),
                      );
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'Bulk Inactive',
                        child: Text('Bulk Inactive'),
                      ),
                      PopupMenuItem(
                        value: 'Bulk Active',
                        child: Text('Bulk Active'),
                      ),
                      PopupMenuItem(
                        value: 'Bulk Assign Code',
                        child: Text('Bulk Assign Code'),
                      ),
                      PopupMenuItem(
                        value: 'Assign Units',
                        child: Text('Assign Units'),
                      ),
                      PopupMenuItem(
                        value: 'Bulk Update Items',
                        child: Text('Bulk Update Items'),
                      ),
                    ],
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: inventoryCardBorder),
                        color: Colors.white,
                      ),
                      child: const SizedBox(
                        width: inventoryButtonHeight,
                        height: inventoryButtonHeight,
                        child: Icon(
                          Icons.more_vert,
                          size: 18,
                          color: Color(0xFF616161),
                        ),
                      ),
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
          child: products.isEmpty
              ? const InventoryListEmptyState(message: 'No items found')
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final item = products[index];
                    final isSelected = item.id == selectedId;
                    return _ProductListTile(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => onItemSelected(item.id),
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
  });

  final InventoryItem item;
  final bool isSelected;
  final VoidCallback onTap;

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
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: InventoryListRowMenu(),
            ),
          ],
        ),
      ),
    );
  }
}
