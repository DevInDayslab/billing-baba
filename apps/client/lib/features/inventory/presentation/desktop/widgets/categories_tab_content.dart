import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/category_item_sort.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_category_dialog.dart';
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
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/select_items_for_category_dialog.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CategoriesTabContent extends ConsumerStatefulWidget {
  const CategoriesTabContent({super.key});

  @override
  ConsumerState<CategoriesTabContent> createState() =>
      _CategoriesTabContentState();
}

class _CategoriesTabContentState extends ConsumerState<CategoriesTabContent> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(categorySearchQueryProvider.notifier).query = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final trimmed = query.trim();
      ref.read(categoryBackendSearchProvider.notifier).query = trimmed;
      unawaited(
        ref
            .read(inventoryCategoriesProvider.notifier)
            .refresh(searchQuery: trimmed.isEmpty ? null : trimmed),
      );
    });
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    InventoryCategory category,
  ) async {
    if (category.isUncategorized) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('Delete "${category.name}"?'),
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
        .read(inventoryCategoriesProvider.notifier)
        .deleteCategory(category.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ref.read(selectedCategoryIdProvider.notifier).selected =
        uncategorizedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final categoriesAsync = ref.watch(inventoryCategoriesProvider);
    final selectedId = ref.watch(selectedCategoryIdProvider);

    return InventorySplitLayout(
      listPanel: _CategoriesListPanel(
        categories: categories,
        categoriesAsync: categoriesAsync,
        selectedId: selectedId,
        onSearchChanged: _onSearchChanged,
        onRefresh: () => ref
            .read(inventoryCategoriesProvider.notifier)
            .refresh(
              searchQuery: ref.read(categoryBackendSearchProvider),
            ),
        onCategorySelected: (id) =>
            ref.read(selectedCategoryIdProvider.notifier).selected = id,
        onAddCategory: () => showAddCategoryDialog(context),
        onMenuSelected: (value, category) {
          if (category.isUncategorized) return;
          switch (value) {
            case 'Edit':
              unawaited(showAddCategoryDialog(context, editCategory: category));
            case 'Delete':
              unawaited(_confirmDeleteCategory(context, category));
          }
        },
      ),
      detailPanel:
          selectedId != null &&
              categories.any((category) => category.id == selectedId)
          ? _CategoryDetailPanel(
              category: categories.firstWhere(
                (category) => category.id == selectedId,
              ),
            )
          : const InventoryDetailPlaceholder(
              message: 'Select a category to view items',
            ),
    );
  }
}

class _CategoriesListPanel extends StatelessWidget {
  const _CategoriesListPanel({
    required this.categories,
    required this.categoriesAsync,
    required this.selectedId,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onCategorySelected,
    required this.onAddCategory,
    required this.onMenuSelected,
  });

  final List<InventoryCategory> categories;
  final AsyncValue<List<InventoryCategory>> categoriesAsync;
  final String? selectedId;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onAddCategory;
  final void Function(String value, InventoryCategory category) onMenuSelected;

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
                label: 'Add Category',
                onPressed: onAddCategory,
              ),
            ],
          ),
        ),
        Expanded(
          child: InventoryAsyncList<InventoryCategory>(
            asyncValue: categoriesAsync,
            items: categories,
            onRefresh: onRefresh,
            emptyMessage: 'No categories found',
            itemBuilder: (context, category, index) {
              final isSelected = category.id == selectedId;
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
                          onTap: () => onCategorySelected(category.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                _CategoryItemCountBadge(
                                  count: category.itemCount,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!category.isUncategorized)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: InventoryListRowMenu(
                            onSelected: (value) =>
                                onMenuSelected(value, category),
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

class _CategoryDetailPanel extends ConsumerWidget {
  const _CategoryDetailPanel({required this.category});

  final InventoryCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(categoryItemsProvider(category.id));
    final itemsAsync = ref.watch(inventoryItemsProvider);
    final searchQuery = ref.watch(categoryItemSearchQueryProvider);
    final sort = ref.watch(categoryItemSortProvider);
    final sortNotifier = ref.read(categoryItemSortProvider.notifier);
    final filters = ref.watch(categoryItemFiltersProvider);
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
                            category.name.toUpperCase(),
                            style: InventoryStyles.panelTitleStyle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _CategoryItemCountBadge(count: category.itemCount),
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
                      label: 'Move To This Category',
                      onPressed: () => showSelectItemsForCategoryDialog(
                        context,
                        targetCategoryId: category.id,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    InventorySearchField(
                      hint: 'Search',
                      onChanged: (query) =>
                          ref
                                  .read(
                                    categoryItemSearchQueryProvider.notifier,
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
                    .read(categoryItemFiltersProvider.notifier)
                    .apply,
              ),
              items: items,
              itemsAsync: itemsAsync,
              onRefresh: () =>
                  ref.read(inventoryItemsProvider.notifier).refresh(),
              emptyMessage: 'No items in category',
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

class _CategoryItemCountBadge extends StatelessWidget {
  const _CategoryItemCountBadge({required this.count});

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
