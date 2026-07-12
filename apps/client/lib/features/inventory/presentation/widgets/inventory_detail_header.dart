import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_primary_button.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum InventoryDetailHeaderMode { product, service }

/// Shared Products/Services detail header — same chrome, mode-specific fields.
class InventoryDetailHeader extends StatelessWidget {
  const InventoryDetailHeader({
    required this.item,
    required this.mode,
    this.stockSummary,
    this.categoryName,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final InventoryItem item;
  final InventoryDetailHeaderMode mode;
  final ProductStockSummary? stockSummary;
  final String? categoryName;
  final String? actionLabel;
  final VoidCallback? onAction;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final left = _leftLines();
    final right = _rightLines();

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
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: AppSpacing.sm),
                InventorySecondaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                ),
              ],
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
                    for (final line in left)
                      InventoryDetailMetaLine(
                        label: line.label,
                        value: line.value,
                        valueColor: line.valueColor,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in right)
                      InventoryDetailMetaLine(
                        label: line.label,
                        value: line.value,
                        valueColor: line.valueColor,
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

  List<_MetaData> _leftLines() {
    if (mode == InventoryDetailHeaderMode.service) {
      return [
        _MetaData(
          label: 'Sale Price',
          value: item.salePrice != null
              ? '${_currencyFormat.format(item.salePrice)} (incl)'
              : inventoryEmDash,
        ),
        _MetaData(
          label: 'Purchase Price',
          value: item.purchasePrice != null
              ? '${_currencyFormat.format(item.purchasePrice)} (excl)'
              : inventoryEmDash,
        ),
        _MetaData(
          label: 'HSN',
          value: (item.hsnCode?.trim().isNotEmpty ?? false)
              ? item.hsnCode!
              : inventoryEmDash,
        ),
      ];
    }

    final summary = stockSummary;
    return [
      _MetaData(
        label: 'Sale Price',
        value: item.salePrice != null
            ? '${_currencyFormat.format(item.salePrice)} (incl)'
            : inventoryEmDash,
      ),
      _MetaData(
        label: 'Purchase Price',
        value: item.purchasePrice != null
            ? '${_currencyFormat.format(item.purchasePrice)} (excl)'
            : inventoryEmDash,
      ),
      _MetaData(
        label: 'Available for Sale',
        value: summary?.availableStock != null
            ? formatQuantityValue(summary!.availableStock!)
            : inventoryEmDash,
      ),
    ];
  }

  List<_MetaData> _rightLines() {
    if (mode == InventoryDetailHeaderMode.service) {
      final description = item.description?.trim();
      return [
        _MetaData(
          label: 'Category',
          value: (categoryName?.trim().isNotEmpty ?? false)
              ? categoryName!
              : inventoryEmDash,
        ),
        _MetaData(
          label: 'Unit',
          value: (item.baseUnitShortName?.trim().isNotEmpty ?? false)
              ? item.baseUnitShortName!
              : inventoryEmDash,
        ),
        _MetaData(
          label: 'Description',
          value: (description != null && description.isNotEmpty)
              ? description
              : inventoryEmDash,
        ),
      ];
    }

    final summary = stockSummary;
    return [
      _MetaData(
        label: 'Stock Quantity',
        value: item.quantity != null
            ? formatQuantityValue(item.quantity!)
            : inventoryEmDash,
        valueColor: listQuantityColor(
          item.quantity,
          reorderLevel: item.reorderLevel,
        ),
      ),
      _MetaData(
        label: 'Stock Value',
        value: summary?.stockValue != null && summary!.stockValue! > 0
            ? _currencyFormat.format(summary.stockValue)
            : inventoryEmDash,
      ),
      _MetaData(
        label: 'Reserved Quantity',
        value: summary?.reservedStock != null
            ? formatQuantityValue(summary!.reservedStock!)
            : inventoryEmDash,
      ),
    ];
  }
}

class InventoryDetailMetaLine extends StatelessWidget {
  const InventoryDetailMetaLine({
    required this.label,
    required this.value,
    this.valueColor,
    super.key,
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

class _MetaData {
  const _MetaData({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
}
