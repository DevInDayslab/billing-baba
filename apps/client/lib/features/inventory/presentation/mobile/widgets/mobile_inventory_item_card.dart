import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Vyapar-style item card with tags, pricing, and stock metrics.
class MobileInventoryItemCard extends StatefulWidget {
  const MobileInventoryItemCard({
    required this.item,
    super.key,
    this.onShareTap,
    this.onTap,
    this.initiallyExpanded = false,
  });

  final InventoryItem item;
  final VoidCallback? onShareTap;
  final VoidCallback? onTap;
  final bool initiallyExpanded;

  @override
  State<MobileInventoryItemCard> createState() =>
      _MobileInventoryItemCardState();
}

class _MobileInventoryItemCardState extends State<MobileInventoryItemCard> {
  static final _priceFormat = NumberFormat('#,##0.##', 'en_IN');
  late var _isExpanded = widget.initiallyExpanded;

  String _formatPrice(double? value) {
    if (value == null) return '₹ 0';
    return '₹ ${_priceFormat.format(value)}';
  }

  List<String> get _tags {
    if (widget.item.searchKeywords.isNotEmpty) {
      return widget.item.searchKeywords.take(3).toList();
    }
    final parts = widget.item.name.split(' ');
    if (parts.length <= 1) return const [];
    return parts.skip(1).take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final stockColor = listQuantityColor(
      item.quantity,
      reorderLevel: item.reorderLevel,
    );
    final reserved = item.reservedQuantity;
    final available = item.availableForSale ?? item.quantity;
    final showExpanded =
        _isExpanded && (reserved != null || available != item.quantity);

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          for (final tag in _tags) _TagChip(label: tag),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onShareTap,
                icon: const Icon(Icons.share_outlined, size: 20),
                color: AppColors.textSecondary,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MetricColumn(
                  label: 'Sale Price',
                  value: _formatPrice(item.salePrice),
                ),
              ),
              Expanded(
                child: _MetricColumn(
                  label: 'Purchase Price',
                  value: _formatPrice(item.purchasePrice),
                ),
              ),
              Expanded(
                child: _MetricColumn(
                  label: 'In Stock',
                  value: formatQuantityValue(item.quantity ?? 0),
                  valueColor: stockColor,
                ),
              ),
            ],
          ),
          if (showExpanded) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
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
                const Expanded(child: SizedBox.shrink()),
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
