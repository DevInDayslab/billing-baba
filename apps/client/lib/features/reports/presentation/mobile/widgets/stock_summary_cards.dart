import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/stock_summary_display_row.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_scaffold.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

/// Summary stat cards for the mobile stock summary screen.
class StockSummaryStatCards extends StatelessWidget {
  const StockSummaryStatCards({
    required this.itemCount,
    required this.lowStockCount,
    required this.stockValue,
    super.key,
  });

  final int itemCount;
  final int lowStockCount;
  final double stockValue;

  @override
  Widget build(BuildContext context) {
    return MobileReportMetricsBand(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'No. of Items',
                value: '$itemCount',
              ),
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: _StatCard(
                label: 'Low Stock Items',
                value: '$lowStockCount',
                valueColor: MobileReportTheme.negative,
              ),
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: _StatCard(
                label: 'Stock Value',
                value: _formatCompactValue(stockValue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCompactValue(double value) {
    if (value >= 10000000) {
      return '₹ ${(value / 10000000).toStringAsFixed(2)} Cr';
    }
    if (value >= 100000) {
      return '₹ ${(value / 100000).toStringAsFixed(2)} L';
    }
    return formatReportCurrency(value);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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

    return MobileCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md + 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
          const Gap(AppSpacing.sm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single stock summary row card for the mobile list.
class StockSummaryRowCard extends StatelessWidget {
  const StockSummaryRowCard({
    required this.row,
    super.key,
  });

  final StockSummaryDisplayRow row;

  static final _qtyFormat = NumberFormat('#,##0.0', 'en_IN');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (row.hasCategory || row.hasQuantityBreakdown) {
      return _DetailedCard(row: row, theme: theme.textTheme);
    }

    return MobileCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.itemName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(AppSpacing.sm),
          Text(
            'Stock Value: ${_currencyFormat.format(row.stockValue)}'
            '  •  Stock Qty: ${_qtyFormat.format(row.stockQty)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailedCard extends StatelessWidget {
  const _DetailedCard({required this.row, required this.theme});

  final StockSummaryDisplayRow row;
  final TextTheme theme;

  @override
  Widget build(BuildContext context) {
    return MobileCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(
                  row.itemName,
                  style: theme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (row.categoryName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    row.categoryName!,
                    style: theme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(AppSpacing.md),
          Text(
            'Stock Value: ${StockSummaryRowCard._currencyFormat.format(row.stockValue)}',
            style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          if (row.hasQuantityBreakdown) ...[
            const Gap(AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _QtyColumn(
                    label: 'Stock Qty',
                    value: StockSummaryRowCard._qtyFormat.format(row.stockQty),
                  ),
                ),
                Expanded(
                  child: _QtyColumn(
                    label: 'Reserved Qty',
                    value: StockSummaryRowCard._qtyFormat.format(
                      row.reservedQty ?? 0,
                    ),
                  ),
                ),
                Expanded(
                  child: _QtyColumn(
                    label: 'Available Qty',
                    value: StockSummaryRowCard._qtyFormat.format(
                      row.availableQty ?? row.stockQty,
                    ),
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

class _QtyColumn extends StatelessWidget {
  const _QtyColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Gap(AppSpacing.xs),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
