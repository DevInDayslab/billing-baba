import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_primary_button.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
          initialType: ItemType.product,
        ),
      ),
      detailPanel: selectedId == null
          ? const InventoryDetailPlaceholder(
              message: 'Select an item to view details',
            )
          : _ProductDetailPanel(
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
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: inventoryCardBorder),
                    ),
                    child: const Icon(Icons.more_vert, size: 18),
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
        : AppColors.textPrimary;

    return Material(
      color: isSelected ? inventorySelectedRowColor : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: inventoryCardBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  quantity?.toString() ?? '-',
                  style: TextStyle(fontSize: 13, color: quantityColor),
                ),
              ),
              const InventoryListRowMenu(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductDetailPanel extends StatelessWidget {
  const _ProductDetailPanel({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name.toUpperCase(), style: InventoryStyles.panelTitleStyle),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(label: 'Quantity', value: item.quantity?.toString() ?? '-'),
          _DetailRow(
            label: 'Sale Price',
            value: item.salePrice != null
                ? currency.format(item.salePrice)
                : '-',
          ),
          _DetailRow(
            label: 'Stock Value',
            value: item.stockValue != null
                ? currency.format(item.stockValue)
                : '-',
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
