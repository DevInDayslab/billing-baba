import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Mobile metrics card mirroring the desktop item detail header.
///
/// Shows the item name and the first four metrics. Secondary fields
/// (stock value, reserved qty, last update, etc.) sit under a collapsed
/// "More details" section that toggles open on tap.
class MobileItemDetailMetrics extends StatefulWidget {
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

  @override
  State<MobileItemDetailMetrics> createState() =>
      _MobileItemDetailMetricsState();
}

class _MobileItemDetailMetricsState extends State<MobileItemDetailMetrics> {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  var _detailsExpanded = false;

  void _toggleDetails() {
    setState(() => _detailsExpanded = !_detailsExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final metrics =
        widget.stockMetrics ?? InventoryStockCalculator.metricsFromItem(item);
    final isProduct = widget.mode == InventoryDetailHeaderMode.product;

    final primaryMetrics = isProduct
        ? [
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
          ]
        : [
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
              value: displayOrDash(widget.categoryName),
            ),
          ];

    final secondaryMetrics = isProduct
        ? [
            _MetricTile(
              label: 'Stock Value',
              value:
                  widget.stockSummary?.stockValue != null &&
                      widget.stockSummary!.stockValue! > 0
                  ? _currencyFormat.format(widget.stockSummary!.stockValue)
                  : inventoryEmDash,
            ),
            _MetricTile(
              label: 'Reserved Quantity',
              value: metrics.reservedQuantity > 0
                  ? formatQuantityValue(metrics.reservedQuantity)
                  : inventoryEmDash,
            ),
          ]
        : [
            _MetricTile(
              label: 'Unit',
              value: displayOrDash(item.baseUnitShortName),
            ),
          ];

    final secondaryRows = <Widget>[
      if (isProduct && widget.latestStockUpdate != null) ...[
        _DetailRow(
          label: 'Last Stock Update',
          value: DateFormat(
            'dd MMM yyyy, hh:mm a',
          ).format(widget.latestStockUpdate!.updatedAt.toLocal()),
        ),
        _DetailRow(
          label: 'Updated By',
          value: displayOrDash(widget.latestStockUpdate!.updatedByName),
        ),
        _DetailRow(
          label: 'Last Change',
          value: widget.latestStockUpdate!.changeDescription,
        ),
      ],
      if (!isProduct && (item.description?.trim().isNotEmpty ?? false))
        _DetailRow(
          label: 'Description',
          value: item.description!.trim(),
        ),
    ];

    final hasSecondary =
        secondaryMetrics.isNotEmpty || secondaryRows.isNotEmpty;

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
          _MetricGrid(children: primaryMetrics),
          if (hasSecondary) ...[
            const Gap(AppSpacing.sm),
            _MoreDetailsToggle(
              expanded: _detailsExpanded,
              onTap: _toggleDetails,
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (secondaryMetrics.isNotEmpty)
                      _MetricGrid(children: secondaryMetrics),
                    if (secondaryRows.isNotEmpty) ...[
                      if (secondaryMetrics.isNotEmpty) ...[
                        const Gap(AppSpacing.md),
                        const Divider(height: 1),
                        const Gap(AppSpacing.md),
                      ],
                      ...secondaryRows,
                    ],
                  ],
                ),
              ),
              crossFadeState: _detailsExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
              sizeCurve: Curves.easeInOut,
            ),
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

class _MoreDetailsToggle extends StatelessWidget {
  const _MoreDetailsToggle({
    required this.expanded,
    required this.onTap,
  });

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  expanded ? 'Hide details' : 'More details',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  LucideIcons.chevronDown,
                  size: AppIconSize.md,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
