import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Opens a searchable item picker backed by [inventoryItemsProvider].
Future<InventoryItem?> showMobileItemPickerSheet({
  required BuildContext context,
  required WidgetRef ref,
  String title = 'Select Item',
  bool showSalePrice = true,
}) {
  // Warm catalog in the background only when empty — avoid rebuilding the list
  // under the user's finger while the sheet is open.
  final existing = ref.read(inventoryItemsProvider).value;
  if (existing == null || existing.items.isEmpty) {
    unawaited(ref.read(inventoryItemsProvider.notifier).refresh());
  }

  return showMobileBottomSheet<InventoryItem>(
    context: context,
    title: title,
    heightFraction: 0.72,
    scrollBody: false,
    builder: (sheetContext) => _MobileItemPickerBody(
      showSalePrice: showSalePrice,
      sheetContext: sheetContext,
    ),
  );
}

class _MobileItemPickerBody extends ConsumerStatefulWidget {
  const _MobileItemPickerBody({
    required this.showSalePrice,
    required this.sheetContext,
  });

  final bool showSalePrice;
  final BuildContext sheetContext;

  @override
  ConsumerState<_MobileItemPickerBody> createState() =>
      _MobileItemPickerBodyState();
}

class _MobileItemPickerBodyState extends ConsumerState<_MobileItemPickerBody> {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  late final TextEditingController _searchController;
  var _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InventoryItem> _filtered(List<InventoryItem> items) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((item) {
      final searchable = [
        item.name,
        item.barcode ?? '',
        item.hsnCode ?? '',
        item.baseUnitShortName ?? '',
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  String _priceLabel(InventoryItem item) {
    final price = widget.showSalePrice ? item.salePrice : item.purchasePrice;
    if (price == null) return '—';
    return _currencyFormat.format(price);
  }

  String _stockLabel(InventoryItem item) {
    final stock = InventoryStockCalculator.metricsFromItem(
      item,
    ).availableForSale;
    final unit = item.baseUnitShortName?.trim();
    final unitSuffix =
        unit == null || unit.isEmpty || unit == 'NONE' ? '' : ' $unit';
    return '${stock.toStringAsFixed(stock == stock.roundToDouble() ? 0 : 2)}'
        '$unitSuffix';
  }

  void _selectItem(InventoryItem item) {
    // Sheet is shown with useRootNavigator: true — pop that same navigator
    // so the Future from showModalBottomSheet receives the selected item.
    Navigator.of(widget.sheetContext, rootNavigator: true).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(inventoryItemsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search item',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            isDense: true,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: itemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      InventoryErrorMapper.messageFor(error),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => unawaited(
                        ref.read(inventoryItemsProvider.notifier).refresh(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (page) {
              final filtered = _filtered(page.items);
              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    page.items.isEmpty
                        ? 'No items found. Add items in Inventory first.'
                        : 'No items match your search.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: AppColors.textSecondary.withValues(alpha: 0.12),
                ),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Stock: ${_stockLabel(item)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      _priceLabel(item),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    onTap: () => _selectItem(item),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
