import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

SaleItemOption saleItemOptionFromInventory(InventoryItem item) {
  return SaleItemOption(
    id: item.id,
    name: item.name,
    salePrice: item.salePrice ?? 0,
    purchasePrice: item.purchasePrice ?? 0,
    mfgCost: item.purchasePrice ?? 0,
    stock: item.availableForSale ?? item.quantity ?? 0,
    unit: item.baseUnitShortName,
    sku: item.hsnCode,
    barcode: item.barcode,
  );
}

String saleItemDefaultUnit(SaleItemOption item) {
  final unit = item.unit?.trim();
  if (unit == null || unit.isEmpty || unit == 'NONE') return 'PCS';
  return unit;
}

/// Item name field with autocomplete overlay on focus.
class ItemNameAutocompleteField extends ConsumerStatefulWidget {
  const ItemNameAutocompleteField({
    required this.value,
    required this.onChanged,
    required this.onItemSelected,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<SaleItemOption> onItemSelected;

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

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  List<SaleItemOption> get _filteredItems {
    final inventory = ref.read(inventoryItemsProvider).value ?? [];
    final options = inventory
        .where((item) => item.type == ItemType.product)
        .map(saleItemOptionFromInventory)
        .toList();

    final query = _controller.text.trim();
    if (query.isEmpty) return options;
    return options.where((item) => item.matchesSearchQuery(query)).toList();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final triggerWidth = renderBox?.size.width ?? 280;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final itemsAsync = ref.watch(inventoryItemsProvider);
        final items = _filteredItems;
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
                child: SizedBox(
                  width: triggerWidth < 420 ? 420 : triggerWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () {
                          _removeOverlay();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Add Item coming soon'),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Text(
                            '+ Add Item',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
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
                      itemsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, _) => const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Failed to load items',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                        data: (_) => ConstrainedBox(
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
                                    final isSelected = item.name == widget.value;
                                    return InkWell(
                                      onTap: () {
                                        _controller.text = item.name;
                                        widget.onChanged(item.name);
                                        widget.onItemSelected(item);
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
                                              child: Text(
                                                item.name,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                  color: isSelected
                                                      ? const Color(0xFFD32F2F)
                                                      : AppColors.textPrimary,
                                                ),
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
                                                _priceFormat.format(item.mfgCost),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: saleFieldTextStyle.copyWith(fontSize: 13),
        decoration: buildSaleFieldDecoration(hint: 'Item Name', compact: true),
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
