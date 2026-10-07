import 'dart:async';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_list_image_warmup.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/bulk_items_update_callout.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_async_list.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_bulk_item_dialogs.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_item_list_tile.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_items_filter_trigger.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_panel_toolbar.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Canonical Inventory left panel — Products/Services share this layout.
class InventoryLeftPanel extends ConsumerStatefulWidget {
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
    required this.onImportItems,
    required this.itemType,
    required this.onMenuSelected,
    this.onItemDoubleTap,
    this.onSearchMatchSelected,
    this.toolbarMenuItems = const [],
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.leadingIcon = Icons.inventory_2_outlined,
    this.showListFilters = true,
    this.showBulkItemsUpdateCallout = true,
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
  final ValueChanged<InventoryItem>? onItemDoubleTap;
  final VoidCallback onAddPressed;
  final VoidCallback onImportItems;
  final void Function(String value, InventoryItem item) onMenuSelected;
  final ValueChanged<InventoryItem>? onSearchMatchSelected;
  final List<SalesActionMenuItem> toolbarMenuItems;
  final IconData leadingIcon;
  final bool showListFilters;
  final ItemType itemType;
  final bool showBulkItemsUpdateCallout;

  @override
  ConsumerState<InventoryLeftPanel> createState() => _InventoryLeftPanelState();
}

class _InventoryLeftPanelState extends ConsumerState<InventoryLeftPanel> {
  bool _bulkCalloutVisible = false;
  var _bulkCalloutLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.showBulkItemsUpdateCallout) {
      unawaited(_loadBulkCalloutVisibility());
    }
  }

  Future<void> _loadBulkCalloutVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed =
        prefs.getBool(StorageKeys.bulkItemsUpdateCalloutDismissed) ?? false;
    if (!mounted) return;
    setState(() {
      _bulkCalloutVisible = !dismissed;
      _bulkCalloutLoaded = true;
    });
  }

  Future<void> _dismissBulkCallout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.bulkItemsUpdateCalloutDismissed, true);
    if (!mounted) return;
    setState(() => _bulkCalloutVisible = false);
  }

  Future<void> _openBulkItemsUpdate() async {
    await _dismissBulkCallout();
    if (!mounted) return;
    await showBulkUpdateItemsDialog(
      context,
      itemType: widget.itemType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showCallout =
        widget.showBulkItemsUpdateCallout &&
        _bulkCalloutLoaded &&
        _bulkCalloutVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            showCallout ? AppSpacing.xs : AppSpacing.sm,
          ),
          child: InventoryListPanelToolbar(
            searchResetToken: widget.searchResetToken,
            searchHint: widget.searchHint,
            addButtonLabel: widget.addButtonLabel,
            initialSearchQuery: widget.searchQuery,
            searchMatches: widget.searchQuery.trim().isEmpty
                ? const []
                : widget.items,
            textStyle: saleFieldTextStyle.copyWith(fontSize: 12),
            onSearchChanged: widget.onSearchChanged,
            onSearchDebounced: widget.onSearchDebounced,
            onSearchEscape: widget.onSearchEscape,
            onArrowDown: widget.onArrowDown,
            onArrowUp: widget.onArrowUp,
            onEnter: widget.onEnter,
            onAddPressed: widget.onAddPressed,
            onImportItems: widget.onImportItems,
            onSearchMatchSelected: widget.onSearchMatchSelected,
            toolbarMenuItems: widget.toolbarMenuItems,
          ),
        ),
        if (showCallout)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              0,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: BulkItemsUpdateCallout(
              onClose: _dismissBulkCallout,
              onOpen: () => unawaited(_openBulkItemsUpdate()),
            ),
          ),
        InventoryListHeader(
          height: inventoryListHeaderCompactHeight,
          showColumnSeparators: false,
          labelStyle: InventoryStyles.listPanelCompactHeaderStyle,
          columns: [
            InventoryListColumn(
              label: widget.primaryColumnLabel,
              flex: inventoryListPrimaryColumnFlex,
              trailing: widget.showListFilters
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
              label: widget.secondaryColumnLabel,
              fixedWidth: inventoryListQtyColumnMaxWidth,
              alignEnd: true,
            ),
          ],
        ),
        Expanded(
          child: InventoryAsyncList<InventoryItem>(
            asyncValue: widget.itemsAsync,
            items: widget.items,
            showCachedWhileLoading: true,
            estimatedItemExtent: inventoryItemListRowHeight,
            onRefresh: widget.onRefresh,
            onLoadMore: widget.onLoadMore,
            hasMore: widget.hasMore,
            isLoadingMore: widget.isLoadingMore,
            emptyMessage: widget.emptyMessage,
            onPrefetchItems: (window) {
              ref.read(inventoryListImageWarmupProvider).warmItems(window);
            },
            itemBuilder: (context, item, index) {
              return InventoryItemListTile(
                key: ValueKey(item.id),
                item: item,
                title: item.name,
                trailingValue: widget.trailingValueBuilder(item),
                trailingColor: widget.trailingColorBuilder(item),
                isSelected: item.id == widget.selectedId,
                isFocused: index == widget.focusedIndex,
                searchQuery: widget.searchQuery,
                leadingIcon: widget.leadingIcon,
                onTap: () => widget.onItemSelected(item.id),
                onDoubleTap: widget.onItemDoubleTap == null
                    ? null
                    : () => widget.onItemDoubleTap!(item),
                onMenuSelected: (value) => widget.onMenuSelected(value, item),
              );
            },
          ),
        ),
      ],
    );
  }
}
