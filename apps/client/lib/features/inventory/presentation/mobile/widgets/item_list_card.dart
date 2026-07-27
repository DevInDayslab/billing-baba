import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

/// Single inventory item card for the mobile items list.
class ItemListCard extends StatelessWidget {
  const ItemListCard({
    required this.item,
    super.key,
    this.categoryName,
    this.onTap,
  });

  final InventoryItem item;
  final String? categoryName;
  final VoidCallback? onTap;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  static const _labelSalePrice = 'Sale Price';
  static const _labelPurchasePrice = 'Purchase Price';
  static const _labelInStock = 'In Stock';
  static const _labelReservedQty = 'Reserved Qty';
  static const _labelAvailableQty = 'Available Qty';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = InventoryStockCalculator.metricsFromItem(item);
    final stockQty = item.quantity;
    final reservedQty = item.reservedQuantity;
    final availableQty = item.availableForSale ?? metrics.availableForSale;
    final showSecondaryRow =
        _hasReservedQty(reservedQty) ||
        _hasAvailableQty(
          availableQty: availableQty,
          stockQty: stockQty,
          reservedQty: reservedQty,
          hasExplicitAvailable: item.availableForSale != null,
        );

    return MobileCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.alternativeItemIds.isNotEmpty) ...[
                      const Gap(AppSpacing.sm),
                      Icon(
                        Icons.inventory_2_outlined,
                        size: AppIconSize.md,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
              if (categoryName != null && categoryName!.trim().isNotEmpty) ...[
                const Gap(AppSpacing.sm),
                _CategoryBadge(label: categoryName!),
              ],
              const Gap(AppSpacing.xs),
              ShareMenuButton(
                child: Icon(
                  Icons.open_in_new_rounded,
                  size: AppIconSize.md,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          _MetricRow(
            children: [
              _MetricCell(
                label: _labelSalePrice,
                value: _formatMoney(item.salePrice),
              ),
              _MetricCell(
                label: _labelPurchasePrice,
                value: _formatMoney(item.purchasePrice),
              ),
              _MetricCell(
                label: _labelInStock,
                value: stockQty == null
                    ? inventoryEmDash
                    : formatQuantityValue(stockQty),
                valueColor: stockQty == null
                    ? AppColors.textSecondary
                    : _inStockColor(stockQty),
                alignEnd: true,
              ),
            ],
          ),
          if (showSecondaryRow) ...[
            const Gap(AppSpacing.sm),
            _MetricRow(
              children: [
                if (_hasReservedQty(reservedQty))
                  _MetricCell(
                    label: _labelReservedQty,
                    value: formatQuantityValue(reservedQty!),
                  ),
                if (_hasAvailableQty(
                  availableQty: availableQty,
                  stockQty: stockQty,
                  reservedQty: reservedQty,
                  hasExplicitAvailable: item.availableForSale != null,
                ))
                  _MetricCell(
                    label: _labelAvailableQty,
                    value: formatQuantityValue(availableQty),
                    alignEnd: true,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static bool _hasReservedQty(double? reservedQty) {
    return reservedQty != null && reservedQty != 0;
  }

  static bool _hasAvailableQty({
    required double availableQty,
    required double? stockQty,
    required double? reservedQty,
    required bool hasExplicitAvailable,
  }) {
    if (hasExplicitAvailable) return true;
    if (reservedQty != null && reservedQty != 0) return true;
    if (stockQty != null) return true;
    return availableQty != 0;
  }

  static Color _inStockColor(double? quantity) {
    if (quantity == null || quantity <= 0) {
      return inventoryNegativeColor;
    }
    return Colors.green.shade600;
  }

  static String _formatMoney(double? value) {
    if (value == null) return inventoryEmDash;
    return _currencyFormat.format(value);
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          letterSpacing: 0.3,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Gap(AppSpacing.sm),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    this.valueColor,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Gap(AppSpacing.xxs),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
