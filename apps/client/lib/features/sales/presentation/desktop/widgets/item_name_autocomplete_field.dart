import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/application/item_alternatives_index_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/paginated_inventory_items.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/pricing/application/item_api_tier_prices_provider.dart';
import 'package:billing_baba/features/pricing/application/local_item_tier_prices_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

SaleItemOption saleItemOptionFromInventory(
  InventoryItem item, {
  Map<String, double> tierPrices = const {},
  bool isAlternativeSuggestion = false,
}) {
  return SaleItemOption(
    id: item.id,
    name: item.name,
    salePrice: item.salePrice ?? 0,
    purchasePrice: item.purchasePrice ?? 0,
    mfgCost: item.purchasePrice ?? 0,
    stock: InventoryStockCalculator.metricsFromItem(item).availableForSale,
    unit: item.baseUnitShortName,
    hsn: item.hsnCode,
    itemCode: item.barcode,
    sku: item.barcode,
    barcode: item.barcode,
    tierPrices: tierPrices,
    defaultTaxPercent: item.defaultTaxRate ?? 0,
    isAlternativeSuggestion: isAlternativeSuggestion,
  );
}

String saleItemDefaultUnit(SaleItemOption item) {
  final unit = item.unit?.trim();
  if (unit == null || unit.isEmpty || unit == 'NONE') return 'PCS';
  return unit;
}

const _maxDropdownItems = 150;
const _overlayMinHeight = 240.0;

/// Item name field with autocomplete overlay on focus.
class ItemNameAutocompleteField extends ConsumerStatefulWidget {
  const ItemNameAutocompleteField({
    required this.value,
    required this.onChanged,
    required this.onItemSelected,
    this.onAfterItemSelected,
    this.borderless = false,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<SaleItemOption> onItemSelected;
  final VoidCallback? onAfterItemSelected;
  final bool borderless;

  @override
  ConsumerState<ItemNameAutocompleteField> createState() =>
      ItemNameAutocompleteFieldState();
}

class ItemNameAutocompleteFieldState
    extends ConsumerState<ItemNameAutocompleteField> {
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  late final TextEditingController _controller;
  var _waitingForItems = false;

  static final _priceFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(ItemNameAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void closeMenu() => _removeOverlay();

  Future<void> _openAddItemDialog() async {
    _removeOverlay();
    final created = await showAddItemDialog(context);
    if (!mounted || created == null) return;

    await ref.read(localItemTierPricesProvider.notifier).ensureInitialized();
    if (!mounted) return;

    final resolved =
        ref.read(inventoryItemListProvider).firstWhereOrNull(
          (item) => item.id == created.id,
        ) ??
        created;
    final catalogItem = saleItemOptionFromInventory(
      resolved,
      tierPrices: ref.read(localItemTierPricesProvider)[resolved.id] ?? const {},
    );
    _controller.text = catalogItem.name;
    widget.onChanged(catalogItem.name);
    widget.onItemSelected(catalogItem);
    widget.onAfterItemSelected?.call();
    _focusNode.unfocus();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();

      final itemsAsync = ref.read(inventoryItemsProvider).itemsOnly;
      if (!itemsAsync.hasValue || (itemsAsync.value?.isEmpty ?? true)) {
        setState(() => _waitingForItems = true);
        unawaited(
          ref.read(inventoryItemsProvider.notifier).refresh().whenComplete(() {
            if (!mounted) return;
            setState(() => _waitingForItems = false);
            _overlayEntry?.markNeedsBuild();
          }),
        );
      }
    }
  }

  bool _shouldShowItemsLoading(AsyncValue<List<InventoryItem>> itemsAsync) {
    return _waitingForItems || !itemsAsync.hasValue || itemsAsync.isLoading;
  }

  Widget _buildLoadingPanel(double width) {
    return SizedBox(
      width: width < 420 ? 420 : width,
      height: _overlayMinHeight,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildOverlayScaffold({
    required double triggerWidth,
    required Widget child,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _removeOverlay();
              _focusNode.unfocus();
            },
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 38),
          child: Material(
            elevation: 4,
            shadowColor: Colors.black26,
            borderRadius: AppRadius.mdBorder,
            clipBehavior: Clip.antiAlias,
            color: AppColors.surface,
            child: child,
          ),
        ),
      ],
    );
  }

  List<SaleItemOption> _buildItemOptions(List<InventoryItem> inventory) {
    final query = _controller.text.trim();
    final Iterable<InventoryItem> rankedItems;
    if (query.isEmpty) {
      rankedItems = inventory;
    } else {
      rankedItems = ref
          .read(inventorySearchEngineProvider)
          .searchItems(inventory, query: query);
    }

    final rankedList = rankedItems.take(_maxDropdownItems).toList();
    final options = [
      for (final item in rankedList)
        saleItemOptionFromInventory(item),
    ];

    if (query.isEmpty) return options;

    final alternativesIndex =
        ref.read(itemAlternativesIndexProvider).value ?? const {};
    final inventoryById = {for (final item in inventory) item.id: item};
    final existingIds = options.map((option) => option.id).toSet();
    final alternativeIds = <String>{};

    for (final item in rankedList.take(5)) {
      final linked = alternativesIndex[item.id] ?? const [];
      alternativeIds.addAll(linked);
    }

    for (final alternativeId in alternativeIds) {
      if (existingIds.contains(alternativeId)) continue;
      final item = inventoryById[alternativeId];
      if (item == null) continue;
      options.add(
        saleItemOptionFromInventory(
          item,
          isAlternativeSuggestion: true,
        ),
      );
      existingIds.add(alternativeId);
      if (options.length >= _maxDropdownItems) break;
    }

    return options;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final triggerWidth = renderBox?.size.width ?? 280;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final itemsAsync = ref.watch(inventoryItemsProvider).itemsOnly;
        final panelWidth = triggerWidth < 420 ? 420.0 : triggerWidth;

        if (_shouldShowItemsLoading(itemsAsync)) {
          return _buildOverlayScaffold(
            triggerWidth: triggerWidth,
            child: _buildLoadingPanel(panelWidth),
          );
        }

        return itemsAsync.when(
          loading: () => _buildOverlayScaffold(
            triggerWidth: triggerWidth,
            child: _buildLoadingPanel(panelWidth),
          ),
          error: (error, _) => _buildOverlayScaffold(
            triggerWidth: triggerWidth,
            child: SizedBox(
              width: panelWidth,
              height: _overlayMinHeight,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Failed to load items',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),
          data: (inventory) {
            final items = _buildItemOptions(inventory);
            return _buildOverlayScaffold(
              triggerWidth: triggerWidth,
              child: SizedBox(
                width: panelWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'ITEM',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'SALE PRICE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'PURCHASE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'MFG COST',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'STOCK',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: items.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('No items found'),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final item = items[index];
                                      final isSelected =
                                          item.name == widget.value;
                                      return InkWell(
                                        onTap: () async {
                                          await ref
                                              .read(
                                                itemApiTierPricesProvider
                                                    .notifier,
                                              )
                                              .preloadForItemIds([item.id]);
                                          await ref
                                              .read(
                                                localItemTierPricesProvider
                                                    .notifier,
                                              )
                                              .ensureInitialized();
                                          if (!mounted) return;

                                          final localStore = ref.read(
                                            localItemTierPricesProvider,
                                          );
                                          final apiStore = ref.read(
                                            itemApiTierPricesProvider,
                                          );
                                          final resolved =
                                              saleItemOptionFromInventory(
                                                inventory.firstWhere(
                                                  (entry) =>
                                                      entry.id == item.id,
                                                  orElse: () => InventoryItem(
                                                    id: item.id,
                                                    name: item.name,
                                                    type: ItemType.product,
                                                    salePrice: item.salePrice,
                                                    purchasePrice:
                                                        item.purchasePrice,
                                                    defaultTaxRate:
                                                        item.defaultTaxPercent,
                                                  ),
                                                ),
                                                tierPrices:
                                                    mergedTierPricesForItem(
                                                      apiStore: apiStore,
                                                      localStore: localStore,
                                                      itemId: item.id,
                                                    ),
                                                isAlternativeSuggestion:
                                                    item.isAlternativeSuggestion,
                                              );
                                          _controller.text = resolved.name;
                                          widget.onChanged(resolved.name);
                                          widget.onItemSelected(resolved);
                                          _removeOverlay();
                                          _focusNode.unfocus();
                                        },
                                        hoverColor: const Color(0xFFF5F5F5),
                                        child: Container(
                                          color: isSelected
                                              ? const Color(
                                                  0xFFD32F2F,
                                                ).withValues(alpha: 0.06)
                                              : null,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.name,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFFD32F2F,
                                                              )
                                                            : AppColors
                                                                .textPrimary,
                                                      ),
                                                    ),
                                                    if (item
                                                        .isAlternativeSuggestion)
                                                      const Text(
                                                        'Alternative',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: AppColors
                                                              .textSecondary,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  _priceFormat.format(
                                                    item.salePrice,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  _priceFormat.format(
                                                    item.purchasePrice,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  _priceFormat.format(
                                                    item.mfgCost,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '${item.stock.toInt()}',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            leading: const Icon(
                              Icons.add,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            title: const Text(
                              '+ Add Item',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: _openAddItemDialog,
                          ),
                        ],
                      ),
                ),
              );
          },
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(inventoryItemsProvider, (_, _) {
      _overlayEntry?.markNeedsBuild();
    });

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: saleFieldTextStyle.copyWith(fontSize: 13),
        decoration: buildSaleFieldDecoration(
          hint: 'Item Name',
          compact: true,
          borderless: widget.borderless,
        ),
        onChanged: (value) {
          widget.onChanged(value);
          _overlayEntry?.markNeedsBuild();
        },
        onTap: () {
          if (_overlayEntry == null) _showOverlay();
        },
      ),
    );
  }
}
