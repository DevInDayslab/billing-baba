import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Compact hover tooltip for inventory list rows — no side effects on selection.
class InventoryItemHoverCard extends StatelessWidget {
  const InventoryItemHoverCard({
    required this.item,
    this.categoryName,
    super.key,
  });

  final InventoryItem item;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final unit = item.baseUnitShortName ?? 'pcs';

    return Material(
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(6),
      color: Colors.white,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: inventoryCardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            _HoverRow(
              label: 'Stock',
              value: formatQuantity(item.quantity, unit),
              valueColor: listQuantityColor(
                item.quantity,
                reorderLevel: item.reorderLevel,
              ),
            ),
            if (item.salePrice != null)
              _HoverRow(
                label: 'Sale',
                value: currency.format(item.salePrice),
              ),
            if (item.purchasePrice != null)
              _HoverRow(
                label: 'Purchase',
                value: currency.format(item.purchasePrice),
              ),
            if (categoryName != null)
              _HoverRow(label: 'Category', value: categoryName!),
          ],
        ),
      ),
    );
  }
}

class _HoverRow extends StatelessWidget {
  const _HoverRow({
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
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
