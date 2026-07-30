import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

/// Mobile metrics card mirroring the desktop item detail header.
class MobileItemDetailMetrics extends StatelessWidget {
  const MobileItemDetailMetrics({
    required this.item,
    required this.mode,
    this.stockMetrics,
    this.stockSummary,
    this.latestStockUpdate,
    this.categoryName,
    super.key,
  });

  final InventoryItem item;
  final InventoryDetailHeaderMode mode;
  final ItemStockMetrics? stockMetrics;
  final ProductStockSummary? stockSummary;
  final LatestStockUpdate? latestStockUpdate;
  final String? categoryName;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = stockMetrics ?? InventoryStockCalculator.metricsFromItem(item);

    return MobileCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(AppSpacing.md),
          if (mode == InventoryDetailHeaderMode.product) ...[
            _MetricGrid(
              children: [
                _MetricTile(
                  label: 'Sale Price',
                  value: _formatMoney(item.salePrice, suffix: ' (incl)'),
                ),
                _MetricTile(
                  label: 'Purchase Price',
                  value: _formatMoney(item.purchasePrice, suffix: ' (excl)'),
                ),
                _MetricTile(
                  label: 'Available for Sale',
                  value: formatQuantityValue(metrics.availableForSale),
                ),
                _MetricTile(
                  label: 'Stock Quantity',
                  value: formatQuantityValue(metrics.physicalQuantity),
                  valueColor: listQuantityColor(
                    metrics.physicalQuantity,
                    reorderLevel: item.reorderLevel,
                  ),
                ),
                _MetricTile(
                  label: 'Stock Value',
                  value: stockSummary?.stockValue != null &&
                          stockSummary!.stockValue! > 0
                      ? _currencyFormat.format(stockSummary!.stockValue)
                      : inventoryEmDash,
                ),
                _MetricTile(
                  label: 'Reserved Quantity',
                  value: metrics.reservedQuantity > 0
                      ? formatQuantityValue(metrics.reservedQuantity)
                      : inventoryEmDash,
                ),
              ],
            ),
            if (latestStockUpdate != null) ...[
              const Gap(AppSpacing.md),
              const Divider(height: 1),
              const Gap(AppSpacing.md),
              _DetailRow(
                label: 'Last Stock Update',
                value: DateFormat('dd MMM yyyy, hh:mm a')
                    .format(latestStockUpdate!.updatedAt.toLocal()),
              ),
              _DetailRow(
                label: 'Updated By',
                value: displayOrDash(latestStockUpdate!.updatedByName),
              ),
              _DetailRow(
                label: 'Last Change',
                value: latestStockUpdate!.changeDescription,
              ),
            ],
          ] else ...[
            _MetricGrid(
              children: [
                _MetricTile(
                  label: 'Sale Price',
                  value: _formatMoney(item.salePrice, suffix: ' (incl)'),
                ),
                _MetricTile(
                  label: 'Purchase Price',
                  value: _formatMoney(item.purchasePrice, suffix: ' (excl)'),
                ),
                _MetricTile(
                  label: 'HSN',
                  value: displayOrDash(item.hsnCode),
                ),
                _MetricTile(
                  label: 'Category',
                  value: displayOrDash(categoryName),
                ),
                _MetricTile(
                  label: 'Unit',
                  value: displayOrDash(item.baseUnitShortName),
                ),
              ],
            ),
            if ((item.description?.trim().isNotEmpty ?? false)) ...[
              const Gap(AppSpacing.md),
              const Divider(height: 1),
              const Gap(AppSpacing.sm),
              _DetailRow(
                label: 'Description',
                value: item.description!.trim(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _formatMoney(double? value, {String suffix = ''}) {
    if (value == null) return inventoryEmDash;
    return '${_currencyFormat.format(value)}$suffix';
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.md,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const Gap(AppSpacing.xxs),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
