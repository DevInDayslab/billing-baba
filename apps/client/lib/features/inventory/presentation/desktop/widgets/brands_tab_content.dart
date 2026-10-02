import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_brands_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/brand_model.dart';
import 'package:billing_baba/features/inventory/models/category_item_sort.dart';
import 'package:billing_baba/features/inventory/models/paginated_inventory_items.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_brand_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_async_list.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_detail_list_tile.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_highlighted_text.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_item_list_table.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_primary_button.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/select_items_for_brand_dialog.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BrandsTabContent extends ConsumerStatefulWidget {
  const BrandsTabContent({super.key});

  @override
  ConsumerState<BrandsTabContent> createState() =>
      _BrandsTabContentState();
}

class _BrandsTabContentState extends ConsumerState<BrandsTabContent> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(brandSearchQueryProvider.notifier).query = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final trimmed = query.trim();
      ref.read(brandBackendSearchProvider.notifier).query = trimmed;
      unawaited(
        ref
            .read(inventoryBrandsProvider.notifier)
            .refresh(searchQuery: trimmed.isEmpty ? null : trimmed),
      );
    });
  }

  Future<void> _confirmDeleteBrand(
    BuildContext context,
    BrandModel brand,
  ) async {
    if (brand.isUnbranded) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete brand?'),
        content: Text('Delete "${brand.name}"?'),
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
        .read(inventoryBrandsProvider.notifier)
        .deleteBrand(brand.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ref.read(selectedBrandIdProvider.notifier).selected = unbrandedBrandId;
  }

  @override
  Widget build(BuildContext context) {
    final brands = ref.watch(brandsProvider);
    final brandsAsync = ref.watch(inventoryBrandsProvider);
    final selectedId = ref.watch(selectedBrandIdProvider);

    return InventorySplitLayout(
      listPanel: _BrandsListPanel(
        brands: brands,
        brandsAsync: brandsAsync,
        selectedId: selectedId,
        onSearchChanged: _onSearchChanged,
        onRefresh: () => ref
            .read(inventoryBrandsProvider.notifier)
            .refresh(
              searchQuery: ref.read(brandBackendSearchProvider),
            ),
        onBrandSelected: (id) =>
            ref.read(selectedBrandIdProvider.notifier).selected = id,
        onAddBrand: () => showAddBrandDialog(context),
        onMenuSelected: (value, brand) {
          if (brand.isUnbranded) return;
          switch (value) {
            case 'Edit':
              unawaited(showAddBrandDialog(context, editBrand: brand));
            case 'Delete':
              unawaited(_confirmDeleteBrand(context, brand));
          }
        },
      ),
      detailPanel:
          selectedId != null && brands.any((brand) => brand.id == selectedId)
          ? _BrandDetailPanel(
              brand: brands.firstWhere(
                (brand) => brand.id == selectedId,
              ),
            )
          : const InventoryDetailPlaceholder(
              message: 'Select a brand to view items',
            ),
    );
  }
}

class _BrandsListPanel extends StatelessWidget {
  const _BrandsListPanel({
    required this.brands,
    required this.brandsAsync,
    required this.selectedId,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onBrandSelected,
    required this.onAddBrand,
    required this.onMenuSelected,
  });

  final List<BrandModel> brands;
  final AsyncValue<List<BrandModel>> brandsAsync;
  final String? selectedId;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onBrandSelected;
  final VoidCallback onAddBrand;
  final void Function(String value, BrandModel brand) onMenuSelected;

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
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: AppSpacing.sm),
              InventoryPrimaryButton(
                label: 'Add Brand',
                onPressed: onAddBrand,
              ),
            ],
          ),
        ),
        Expanded(
          child: InventoryAsyncList<BrandModel>(
            asyncValue: brandsAsync,
            items: brands,
            onRefresh: onRefresh,
            emptyMessage: 'No brands found',
            itemBuilder: (context, brand, index) {
              final isSelected = brand.id == selectedId;
              return Material(
                color: isSelected
                    ? inventorySelectedRowColor
                    : Colors.transparent,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: inventoryCardBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => onBrandSelected(brand.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    brand.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                _BrandItemCountBadge(
                                  count: brand.itemCount,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!brand.isUnbranded)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: InventoryListRowMenu(
                            onSelected: (value) =>
                                onMenuSelected(value, brand),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BrandDetailPanel extends ConsumerWidget {
  const _BrandDetailPanel({required this.brand});

  final BrandModel brand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(brandItemsProvider(brand.id));
    final itemsAsync = ref.watch(inventoryItemsProvider).itemsOnly;
    final searchQuery = ref.watch(brandItemSearchQueryProvider);
    final sort = ref.watch(brandItemSortProvider);
    final sortNotifier = ref.read(brandItemSortProvider.notifier);
    final filters = ref.watch(brandItemFiltersProvider);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: AppEllipsisText(
                            brand.name.toUpperCase(),
                            style: InventoryStyles.panelTitleStyle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _BrandItemCountBadge(count: brand.itemCount),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'ITEMS',
                      style: InventoryStyles.listHeaderStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InventorySecondaryButton(
                      label: 'Move To This Brand',
                      onPressed: () => showSelectItemsForBrandDialog(
                        context,
                        targetBrandId: brand.id,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    InventorySearchField(
                      hint: 'Search',
                      onChanged: (query) =>
                          ref
                                  .read(
                                    brandItemSearchQueryProvider.notifier,
                                  )
                                  .query =
                              query,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: InventoryItemListTable(
              includeTrailingSpace: false,
              columns: buildInventoryItemListColumns(
                specs: [
                  InventoryItemListColumnSpec(
                    label: 'NAME',
                    flex: 3,
                    sortable: true,
                    isSorted:
                        sort.column == CategoryItemSortColumn.name &&
                        sort.direction != CategoryItemSortDirection.none,
                    sortAscending:
                        sort.direction == CategoryItemSortDirection.ascending,
                    onSort: () =>
                        sortNotifier.toggle(CategoryItemSortColumn.name),
                  ),
                  InventoryItemListColumnSpec(
                    label: 'QUANTITY',
                    sortable: true,
                    isSorted:
                        sort.column == CategoryItemSortColumn.quantity &&
                        sort.direction != CategoryItemSortDirection.none,
                    sortAscending:
                        sort.direction == CategoryItemSortDirection.ascending,
                    onSort: () =>
                        sortNotifier.toggle(CategoryItemSortColumn.quantity),
                  ),
                  InventoryItemListColumnSpec(
                    label: 'STOCK VALUE',
                    alignEnd: true,
                    sortable: true,
                    isSorted:
                        sort.column == CategoryItemSortColumn.stockValue &&
                        sort.direction != CategoryItemSortDirection.none,
                    sortAscending:
                        sort.direction == CategoryItemSortDirection.ascending,
                    onSort: () =>
                        sortNotifier.toggle(CategoryItemSortColumn.stockValue),
                  ),
                ],
                filters: filters,
                onFilterApply: ref
                    .read(brandItemFiltersProvider.notifier)
                    .apply,
              ),
              items: items,
              itemsAsync: itemsAsync,
              onRefresh: () =>
                  ref.read(inventoryItemsProvider.notifier).refresh(),
              emptyMessage: 'No items in brand',
              itemBuilder: (context, item, index) {
                final quantity = item.quantity;
                final quantityText = quantity != null
                    ? formatQuantityValue(quantity)
                    : inventoryEmDash;
                final stockValueText = item.stockValue != null
                    ? currency.format(item.stockValue)
                    : inventoryEmDash;

                return InventoryDetailListTile(
                  index: index,
                  flexValues: const [3, 1, 1],
                  alignEnds: const [false, false, true],
                  cells: [
                    InventoryHighlightedText(
                      text: item.name,
                      query: searchQuery,
                      style: InventoryStyles.listCellStyle.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InventoryListValueText(
                      value: quantityText,
                      color: listQuantityColor(
                        quantity,
                        reorderLevel: item.reorderLevel,
                      ),
                    ),
                    InventoryListValueText(
                      value: stockValueText,
                      color: inventoryPositiveColor,
                      textAlign: TextAlign.right,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandItemCountBadge extends StatelessWidget {
  const _BrandItemCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
