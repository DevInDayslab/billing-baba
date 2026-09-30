import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_list_image_warmup.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_async_list.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_item_list_tile.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_items_filter_trigger.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_panel_toolbar.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Canonical Inventory left panel — Products/Services share this layout.
class InventoryLeftPanel extends ConsumerWidget {
  const InventoryLeftPanel({
    required this.items,
    required this.itemsAsync,
    required this.selectedId,
    required this.focusedIndex,
    required this.searchQuery,
    required this.searchResetToken,
    required this.searchHint,
    required this.addButtonLabel,
    required this.emptyMessage,
    required this.primaryColumnLabel,
    required this.secondaryColumnLabel,
    required this.trailingValueBuilder,
    required this.trailingColorBuilder,
    required this.onSearchChanged,
    required this.onSearchDebounced,
    required this.onSearchEscape,
    required this.onArrowDown,
    required this.onArrowUp,
    required this.onEnter,
    required this.onRefresh,
    required this.onItemSelected,
    required this.onAddPressed,
    required this.onMenuSelected,
    this.toolbarMenuItems = const [],
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.leadingIcon = Icons.inventory_2_outlined,
    this.showListFilters = true,
    super.key,
  });

  final List<InventoryItem> items;
  final AsyncValue<List<InventoryItem>> itemsAsync;
  final String? selectedId;
  final int focusedIndex;
  final String searchQuery;
  final int searchResetToken;
  final String searchHint;
  final String addButtonLabel;
  final String emptyMessage;
  final String primaryColumnLabel;
  final String secondaryColumnLabel;
  final String Function(InventoryItem item) trailingValueBuilder;
  final Color? Function(InventoryItem item) trailingColorBuilder;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchDebounced;
  final VoidCallback onSearchEscape;
  final VoidCallback onArrowDown;
  final VoidCallback onArrowUp;
  final VoidCallback onEnter;
  final Future<void> Function() onRefresh;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final ValueChanged<String> onItemSelected;
  final VoidCallback onAddPressed;
  final void Function(String value, InventoryItem item) onMenuSelected;
  final List<SalesActionMenuItem> toolbarMenuItems;
  final IconData leadingIcon;
  final bool showListFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: InventoryListPanelToolbar(
            searchResetToken: searchResetToken,
            searchHint: searchHint,
            addButtonLabel: addButtonLabel,
            initialSearchQuery: searchQuery,
            textStyle: saleFieldTextStyle.copyWith(fontSize: 12),
            onSearchChanged: onSearchChanged,
            onSearchDebounced: onSearchDebounced,
            onSearchEscape: onSearchEscape,
            onArrowDown: onArrowDown,
            onArrowUp: onArrowUp,
            onEnter: onEnter,
            onAddPressed: onAddPressed,
            toolbarMenuItems: toolbarMenuItems,
          ),
        ),
        InventoryListHeader(
          height: inventoryListHeaderCompactHeight,
          showColumnSeparators: false,
          labelStyle: InventoryStyles.listPanelCompactHeaderStyle,
          columns: [
            InventoryListColumn(
              label: primaryColumnLabel,
              flex: 3,
              trailing: showListFilters
                  ? InventoryItemsFilterTrigger(
                      compact: true,
                      initialFilters: ref.watch(inventoryItemFiltersProvider),
                      onApply: ref
                          .read(inventoryItemFiltersProvider.notifier)
                          .apply,
                    )
                  : null,
            ),
            InventoryListColumn(
              label: secondaryColumnLabel,
              fixedWidth: inventoryListTrailingColumnWidth,
              alignEnd: true,
            ),
          ],
        ),
        Expanded(
          child: InventoryAsyncList<InventoryItem>(
            asyncValue: itemsAsync,
            items: items,
            showCachedWhileLoading: true,
            estimatedItemExtent: inventoryItemListRowHeight,
            onRefresh: onRefresh,
            onLoadMore: onLoadMore,
            hasMore: hasMore,
            isLoadingMore: isLoadingMore,
            emptyMessage: emptyMessage,
            onPrefetchItems: (window) {
              ref.read(inventoryListImageWarmupProvider).warmItems(window);
            },
            itemBuilder: (context, item, index) {
              return InventoryItemListTile(
                key: ValueKey(item.id),
                item: item,
                title: item.name,
                trailingValue: trailingValueBuilder(item),
                trailingColor: trailingColorBuilder(item),
                isSelected: item.id == selectedId,
                isFocused: index == focusedIndex,
                searchQuery: searchQuery,
                leadingIcon: leadingIcon,
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
