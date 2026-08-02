import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/application/mobile_stock_summary_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MobileStockSummaryItemCard extends StatefulWidget {
  const MobileStockSummaryItemCard({
    required this.row,
    super.key,
    this.initiallyExpanded = false,
    this.onTap,
  });

  final MobileStockSummaryRow row;
  final bool initiallyExpanded;
  final VoidCallback? onTap;

  @override
  State<MobileStockSummaryItemCard> createState() =>
      _MobileStockSummaryItemCardState();
}

class _MobileStockSummaryItemCardState
    extends State<MobileStockSummaryItemCard> {
  static final _currencyFormat = NumberFormat('#,##0', 'en_IN');
  late var _isExpanded = widget.initiallyExpanded;

  String _formatCurrency(double value) => '₹ ${_currencyFormat.format(value)}';

  List<String> get _tags {
    final keywords = widget.row.item.searchKeywords;
    if (keywords.isNotEmpty) return keywords.take(2).toList();
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.row.item;
    final reserved = item.reservedQuantity;
    final available = item.availableForSale ?? item.quantity;
    final showExpandedMetrics =
        _isExpanded &&
        (reserved != null ||
            (available != null && available != widget.row.stockQty));

    return MobileCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {
        widget.onTap?.call();
        if (reserved != null || item.availableForSale != null) {
          setState(() => _isExpanded = !_isExpanded);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (_tags.isNotEmpty)
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    for (final tag in _tags) _TagChip(label: tag),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Stock Value: ${_formatCurrency(widget.row.stockValue)}'
            '  •  Stock Qty: ${formatQuantityValue(widget.row.stockQty)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: widget.row.isLowStock
                  ? inventoryLowStockColor
                  : AppColors.textSecondary,
              fontWeight: widget.row.isLowStock
                  ? FontWeight.w600
                  : FontWeight.w400,
              height: 1.4,
            ),
          ),
          if (showExpandedMetrics) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _MetricColumn(
                    label: 'Stock Qty',
                    value: formatQuantityValue(widget.row.stockQty),
                  ),
                ),
                Expanded(
                  child: _MetricColumn(
                    label: 'Reserved Qty',
                    value: formatQuantityValue(reserved ?? 0),
                  ),
                ),
                Expanded(
                  child: _MetricColumn(
                    label: 'Available Qty',
                    value: formatQuantityValue(available ?? 0),
                    valueColor: inventoryPositiveColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1565C0),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
