import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/adjust_stock_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_primary_button.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_transactions_table.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Right-panel inventory ledger workspace for the selected item.
class ProductDetailPanel extends ConsumerWidget {
  const ProductDetailPanel({
    required this.itemId,
    required this.fallbackItem,
    super.key,
  });

  final String itemId;
  final InventoryItem fallbackItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(productDetailProvider(itemId));
    final displayItem = detailAsync.value ?? fallbackItem;
    final stockSummary = ref.watch(productStockSummaryProvider(itemId));
    final unitLabel = displayItem.baseUnitShortName ?? 'pcs';

    return Column(
      key: ValueKey(itemId),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LedgerItemContextHeader(
          item: displayItem,
          stockSummary: stockSummary,
          onAdjustStock: () =>
              showAdjustStockDialog(context, item: displayItem),
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: InventoryTransactionsTable(
            itemId: itemId,
            unitLabel: unitLabel,
          ),
        ),
      ],
    );
  }
}

class _LedgerItemContextHeader extends StatelessWidget {
  const _LedgerItemContextHeader({
    required this.item,
    required this.stockSummary,
    required this.onAdjustStock,
  });

  final InventoryItem item;
  final ProductStockSummary stockSummary;
  final VoidCallback onAdjustStock;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              InventorySecondaryButton(
                label: 'Adjust Stock',
                onPressed: onAdjustStock,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LedgerMetaLine(
                      label: 'Sale Price',
                      value: item.salePrice != null
                          ? '${_currencyFormat.format(item.salePrice)} (incl)'
                          : inventoryEmDash,
                    ),
                    _LedgerMetaLine(
                      label: 'Purchase Price',
                      value: item.purchasePrice != null
                          ? '${_currencyFormat.format(item.purchasePrice)} (excl)'
                          : inventoryEmDash,
                    ),
                    _LedgerMetaLine(
                      label: 'Available for Sale',
                      value: stockSummary.availableStock != null
                          ? formatQuantityValue(stockSummary.availableStock!)
                          : inventoryEmDash,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LedgerMetaLine(
                      label: 'Stock Quantity',
                      value: item.quantity != null
                          ? formatQuantityValue(item.quantity!)
                          : inventoryEmDash,
                      valueColor: listQuantityColor(
                        item.quantity,
                        reorderLevel: item.reorderLevel,
                      ),
                    ),
                    _LedgerMetaLine(
                      label: 'Stock Value',
                      value: stockSummary.stockValue != null &&
                              stockSummary.stockValue! > 0
                          ? _currencyFormat.format(stockSummary.stockValue)
                          : inventoryEmDash,
                    ),
                    _LedgerMetaLine(
                      label: 'Reserved Quantity',
                      value: stockSummary.reservedStock != null
                          ? formatQuantityValue(stockSummary.reservedStock!)
                          : inventoryEmDash,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LedgerMetaLine extends StatelessWidget {
  const _LedgerMetaLine({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, height: 1.35),
          children: [
            TextSpan(
              text: '${label.toUpperCase()}: ',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
