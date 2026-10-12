import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/paginated_inventory_items.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_item_detail_panel.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_left_panel.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_panel_sort.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared Products/Services workspace: list selection + split layout.
class InventoryItemWorkspace extends ConsumerStatefulWidget {
  const InventoryItemWorkspace({
    required this.items,
    required this.itemsAsync,
    required this.selectedId,
    required this.searchQuery,
    required this.backendSearchQuery,
    required this.detailMode,
    required this.searchHint,
    required this.addButtonLabel,
    required this.emptyMessage,
    required this.placeholderMessage,
    required this.primaryColumnLabel,
    required this.secondaryColumnLabel,
    required this.trailingValueBuilder,
    required this.trailingColorBuilder,
    required this.onLocalSearchChanged,
    required this.onBackendSearchChanged,
    required this.onSelectedIdChanged,
    required this.onSelectionChangedSideEffects,
    required this.onRefresh,
    required this.onAddPressed,
    required this.onImportItems,
    required this.itemType,
    required this.onMenuSelected,
    this.onItemDoubleTap,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.leadingIcon = Icons.inventory_2_outlined,
    this.showListFilters = true,
    this.toolbarMenuItems = const [],
    super.key,
  });

  final List<InventoryItem> items;
  final AsyncValue<List<InventoryItem>> itemsAsync;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final String? selectedId;
  final String searchQuery;
  final String backendSearchQuery;
  final InventoryDetailHeaderMode detailMode;
  final String searchHint;
  final String addButtonLabel;
  final String emptyMessage;
  final String placeholderMessage;
  final String primaryColumnLabel;
  final String secondaryColumnLabel;
  final String Function(InventoryItem item) trailingValueBuilder;
  final Color? Function(InventoryItem item) trailingColorBuilder;
  final ValueChanged<String> onLocalSearchChanged;
  final ValueChanged<String> onBackendSearchChanged;
  final ValueChanged<String> onSelectedIdChanged;
  final void Function(String previousId, String nextId)
  onSelectionChangedSideEffects;
  final Future<void> Function() onRefresh;
  final VoidCallback onAddPressed;
  final VoidCallback onImportItems;
  final ItemType itemType;
  final void Function(String value, InventoryItem item) onMenuSelected;
  final ValueChanged<InventoryItem>? onItemDoubleTap;
  final IconData leadingIcon;
  final bool showListFilters;
  final List<SalesActionMenuItem> toolbarMenuItems;

  @override
  ConsumerState<InventoryItemWorkspace> createState() =>
      _InventoryItemWorkspaceState();
}

class _InventoryItemWorkspaceState
    extends ConsumerState<InventoryItemWorkspace> {
  final FocusNode _listFocusNode = FocusNode();
  int _focusedIndex = 0;
  int _searchResetToken = 0;
  InventoryListPanelQtySort _qtySort = const InventoryListPanelQtySort();

  @override
  void dispose() {
    _listFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    widget.onLocalSearchChanged(query);
    setState(() => _focusedIndex = 0);
  }

  void _onSearchDebounced(String query) {
    // Inventory search is fully client-side; avoid API pre-filtering that
    // drops items before the local token engine can rank them.
  }

  void _clearSearch() {
    widget.onLocalSearchChanged('');
    setState(() {
      _focusedIndex = 0;
      _searchResetToken++;
    });
  }

  void _toggleQtySort() {
    setState(() {
      _qtySort = _qtySort.cycle();
      _syncFocusedIndexToSelection(
        sortInventoryListPanelItems(widget.items, _qtySort),
      );
    });
  }

  void _syncFocusedIndexToSelection(List<InventoryItem> items) {
    final selectedId = widget.selectedId;
    if (selectedId == null) return;
    final index = items.indexWhere((item) => item.id == selectedId);
    if (index >= 0) _focusedIndex = index;
  }

  void _moveFocus(int delta) {
    final items = sortInventoryListPanelItems(widget.items, _qtySort);
    if (items.isEmpty) return;
    setState(() {
      _focusedIndex = (_focusedIndex + delta).clamp(0, items.length - 1);
    });
    final item = items[_focusedIndex];
    widget.onSelectedIdChanged(item.id);
  }

  void _selectFocused() {
    final items = sortInventoryListPanelItems(widget.items, _qtySort);
    if (items.isEmpty) return;
    final item = items[_focusedIndex.clamp(0, items.length - 1)];
    _selectItem(item.id);
    _listFocusNode.requestFocus();
  }

  void _selectItem(String id) {
    final previous = widget.selectedId;
    if (previous != id) {
      widget.onSelectionChangedSideEffects(previous ?? '', id);
    }
    widget.onSelectedIdChanged(id);
  }

  @override
  Widget build(BuildContext context) {
    final items = sortInventoryListPanelItems(widget.items, _qtySort);
    final selectedId = widget.selectedId;

    if (selectedId != null && items.isNotEmpty) {
      final selectedIndex = items.indexWhere((item) => item.id == selectedId);
      if (selectedIndex >= 0 && selectedIndex != _focusedIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _focusedIndex = selectedIndex);
        });
      }
    }

    final detailItem = selectedId == null
        ? null
        : items.where((item) => item.id == selectedId).firstOrNull;

    return InventorySplitLayout(
      listPanel: Focus(
        focusNode: _listFocusNode,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowDown:
              _moveFocus(1);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowUp:
              _moveFocus(-1);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.enter:
              _selectFocused();
              return KeyEventResult.handled;
            default:
              return KeyEventResult.ignored;
          }
        },
        child: InventoryLeftPanel(
          items: items,
          itemsAsync: widget.itemsAsync,
          selectedId: selectedId,
          focusedIndex: _focusedIndex,
          searchQuery: widget.searchQuery,
          searchResetToken: _searchResetToken,
          searchHint: widget.searchHint,
          addButtonLabel: widget.addButtonLabel,
          emptyMessage: widget.emptyMessage,
          primaryColumnLabel: widget.primaryColumnLabel,
          secondaryColumnLabel: widget.secondaryColumnLabel,
          trailingValueBuilder: widget.trailingValueBuilder,
          trailingColorBuilder: widget.trailingColorBuilder,
          leadingIcon: widget.leadingIcon,
          showListFilters: widget.showListFilters,
          onSearchChanged: _onSearchChanged,
          onSearchDebounced: _onSearchDebounced,
          onSearchEscape: _clearSearch,
          onArrowDown: () => _moveFocus(1),
          onArrowUp: () => _moveFocus(-1),
          onEnter: _selectFocused,
          onRefresh: widget.onRefresh,
          onLoadMore: widget.onLoadMore,
          hasMore: widget.hasMore,
          isLoadingMore: widget.isLoadingMore,
          onItemSelected: _selectItem,
          onSearchMatchSelected: (item) => _selectItem(item.id),
          onItemDoubleTap: widget.onItemDoubleTap,
          onAddPressed: widget.onAddPressed,
          onImportItems: widget.onImportItems,
          itemType: widget.itemType,
          onMenuSelected: widget.onMenuSelected,
          toolbarMenuItems: widget.toolbarMenuItems,
          qtySort: _qtySort,
          onQtySortToggle: _toggleQtySort,
        ),
      ),
      detailPanel: selectedId == null || detailItem == null
          ? InventoryDetailPlaceholder(message: widget.placeholderMessage)
          : InventoryItemDetailPanel(
              itemId: selectedId,
              fallbackItem: detailItem,
              mode: widget.detailMode,
            ),
    );
  }
}
