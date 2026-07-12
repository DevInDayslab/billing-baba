import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_async_list.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_highlighted_text.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_items_filter_trigger.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_primary_button.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/product_detail_panel.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _inventoryListRowHeight = 44.0;
const _hoverPreviewDelay = Duration(milliseconds: 120);

class ProductsTabContent extends ConsumerStatefulWidget {
  const ProductsTabContent({super.key});

  @override
  ConsumerState<ProductsTabContent> createState() => _ProductsTabContentState();
}

class _ProductsTabContentState extends ConsumerState<ProductsTabContent> {
  final FocusNode _listFocusNode = FocusNode();
  int _focusedIndex = 0;
  int _searchResetToken = 0;

  /// Detail panel target — updated by hover (delayed) and click (immediate).
  String? _previewId;
  Timer? _hoverTimer;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _listFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(productSearchQueryProvider.notifier).query = query;
    setState(() => _focusedIndex = 0);
  }

  void _onSearchDebounced(String query) {
    final trimmed = query.trim();
    ref.read(productBackendSearchProvider.notifier).query = trimmed;
    unawaited(
      ref
          .read(inventoryItemsProvider.notifier)
          .refresh(searchQuery: trimmed.isEmpty ? null : trimmed),
    );
  }

  void _clearSearch() {
    ref.read(productSearchQueryProvider.notifier).query = '';
    ref.read(productBackendSearchProvider.notifier).query = '';
    unawaited(ref.read(inventoryItemsProvider.notifier).refresh());
    setState(() {
      _focusedIndex = 0;
      _searchResetToken++;
    });
  }

  void _schedulePreview(String id) {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(_hoverPreviewDelay, () {
      if (!mounted || _previewId == id) return;
      setState(() => _previewId = id);
    });
  }

  void _setPreviewImmediate(String id) {
    _hoverTimer?.cancel();
    if (_previewId == id) return;
    setState(() => _previewId = id);
  }

  void _moveFocus(int delta, List<InventoryItem> products) {
    if (products.isEmpty) return;
    setState(() {
      _focusedIndex = (_focusedIndex + delta).clamp(0, products.length - 1);
    });
    final item = products[_focusedIndex];
    _setPreviewImmediate(item.id);
    ref.read(selectedProductIdProvider.notifier).selected = item.id;
  }

  void _selectFocused(List<InventoryItem> products) {
    if (products.isEmpty) return;
    final item = products[_focusedIndex.clamp(0, products.length - 1)];
    _selectItem(item.id);
    _listFocusNode.requestFocus();
  }

  void _selectItem(String id) {
    final selectedId = ref.read(selectedProductIdProvider);
    if (selectedId != id) {
      ref.read(productTransactionFiltersProvider.notifier).reset();
      ref.read(selectedProductTransactionIdProvider.notifier).select(null);
    }
    _setPreviewImmediate(id);
    ref.read(selectedProductIdProvider.notifier).selected = id;
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
    final searchQuery = ref.watch(productSearchQueryProvider);

    final detailId = _previewId ?? selectedId;

    if (selectedId != null && products.isNotEmpty) {
      final selectedIndex = products.indexWhere((item) => item.id == selectedId);
      if (selectedIndex >= 0 && selectedIndex != _focusedIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _focusedIndex = selectedIndex);
        });
      }
    }

    final detailItem = detailId == null
        ? null
        : products.where((item) => item.id == detailId).firstOrNull;

    return InventorySplitLayout(
      listPanel: Focus(
        focusNode: _listFocusNode,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowDown:
              _moveFocus(1, products);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowUp:
              _moveFocus(-1, products);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.enter:
              _selectFocused(products);
              return KeyEventResult.handled;
            default:
              return KeyEventResult.ignored;
          }
        },
        child: _ProductsListPanel(
          products: products,
          itemsAsync: itemsAsync,
          selectedId: selectedId,
          focusedIndex: _focusedIndex,
          searchQuery: searchQuery,
          searchFieldKey: ValueKey(_searchResetToken),
          onSearchChanged: _onSearchChanged,
          onSearchDebounced: _onSearchDebounced,
          onSearchEscape: _clearSearch,
          onArrowDown: () => _moveFocus(1, products),
          onArrowUp: () => _moveFocus(-1, products),
          onEnter: () => _selectFocused(products),
          onRefresh: () => ref.read(inventoryItemsProvider.notifier).refresh(
                searchQuery: ref.read(productBackendSearchProvider),
              ),
          onItemHover: _schedulePreview,
          onItemSelected: _selectItem,
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
      ),
      detailPanel: detailId == null || detailItem == null
          ? const InventoryDetailPlaceholder(
              message: 'Select an item to view ledger',
            )
          : ProductDetailPanel(
              itemId: detailId,
              fallbackItem: detailItem,
            ),
    );
  }
}

class _ProductsListPanel extends StatelessWidget {
  const _ProductsListPanel({
    required this.products,
    required this.itemsAsync,
    required this.selectedId,
    required this.focusedIndex,
    required this.searchQuery,
    required this.searchFieldKey,
    required this.onSearchChanged,
    required this.onSearchDebounced,
    required this.onSearchEscape,
    required this.onArrowDown,
    required this.onArrowUp,
    required this.onEnter,
    required this.onRefresh,
    required this.onItemHover,
    required this.onItemSelected,
    required this.onAddItem,
    required this.onMenuSelected,
  });

  final List<InventoryItem> products;
  final AsyncValue<List<InventoryItem>> itemsAsync;
  final String? selectedId;
  final int focusedIndex;
  final String searchQuery;
  final Key searchFieldKey;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchDebounced;
  final VoidCallback onSearchEscape;
  final VoidCallback onArrowDown;
  final VoidCallback onArrowUp;
  final VoidCallback onEnter;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onItemHover;
  final ValueChanged<String> onItemSelected;
  final VoidCallback onAddItem;
  final void Function(String value, InventoryItem item) onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InventorySearchField(
                key: searchFieldKey,
                hint: 'Search products',
                initialValue: searchQuery,
                debounceDuration: const Duration(milliseconds: 300),
                onChanged: onSearchChanged,
                onDebouncedChanged: onSearchDebounced,
                onEscape: onSearchEscape,
                onArrowDown: onArrowDown,
                onArrowUp: onArrowUp,
                onEnter: onEnter,
              ),
              const SizedBox(height: 12),
              InventoryPrimaryButton(label: 'Add Item', onPressed: onAddItem),
              const SizedBox(height: 14),
            ],
          ),
        ),
        Consumer(
          builder: (context, ref, _) {
            final filters = ref.watch(inventoryItemFiltersProvider);
            return InventoryListHeader(
              columns: [
                InventoryListColumn(
                  label: 'ITEM',
                  flex: 3,
                  trailing: InventoryItemsFilterTrigger(
                    compact: true,
                    initialFilters: filters,
                    onApply:
                        ref.read(inventoryItemFiltersProvider.notifier).apply,
                  ),
                ),
                const InventoryListColumn(label: 'QUANTITY', alignEnd: true),
              ],
            );
          },
        ),
        Expanded(
          child: InventoryAsyncList<InventoryItem>(
            asyncValue: itemsAsync,
            items: products,
            onRefresh: onRefresh,
            emptyMessage: 'No products found',
            itemBuilder: (context, item) {
              final index = products.indexOf(item);
              final isSelected = item.id == selectedId;
              final isFocused = index == focusedIndex;
              return _ProductListTile(
                item: item,
                isSelected: isSelected,
                isFocused: isFocused,
                searchQuery: searchQuery,
                onHover: () => onItemHover(item.id),
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

class _ProductListTile extends StatefulWidget {
  const _ProductListTile({
    required this.item,
    required this.isSelected,
    required this.isFocused,
    required this.searchQuery,
    required this.onHover,
    required this.onTap,
    required this.onMenuSelected,
  });

  final InventoryItem item;
  final bool isSelected;
  final bool isFocused;
  final String searchQuery;
  final VoidCallback onHover;
  final VoidCallback onTap;
  final ValueChanged<String> onMenuSelected;

  @override
  State<_ProductListTile> createState() => _ProductListTileState();
}

class _ProductListTileState extends State<_ProductListTile> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final quantity = widget.item.quantity;
    final quantityColor = listQuantityColor(
      quantity,
      reorderLevel: widget.item.reorderLevel,
    );
    final quantityText =
        quantity != null ? formatQuantityValue(quantity) : inventoryEmDash;

    final backgroundColor = widget.isSelected
        ? inventorySelectedRowColor
        : _isHovered
            ? const Color(0xFFF5F5F5)
            : widget.isFocused
                ? const Color(0xFFFAFAFA)
                : Colors.transparent;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        widget.onHover();
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: _inventoryListRowHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: const Border(bottom: BorderSide(color: inventoryCardBorder)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            hoverColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: InventoryHighlightedText(
                      text: widget.item.name,
                      query: widget.searchQuery,
                      style: InventoryStyles.listCellStyle.copyWith(
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: Text(
                      quantityText,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: quantityColor,
                      ),
                    ),
                  ),
                  InventoryListRowMenu(onSelected: widget.onMenuSelected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
