import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/application/mobile_stock_summary_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MobileStockSummaryMetricsBanner extends StatelessWidget {
  const MobileStockSummaryMetricsBanner({
    required this.metrics,
    super.key,
  });

  final MobileStockSummaryMetrics metrics;

  static final _currencyFormat = NumberFormat('#,##0', 'en_IN');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F4FD), Color(0xFFF5FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: const Color(0xFFD6EAF8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricTile(
              label: 'No. of Items',
              value: '${metrics.itemCount}',
            ),
          ),
          Expanded(
            child: _MetricTile(
              label: 'Low Stock Items',
              value: '${metrics.lowStockCount}',
              valueColor: const Color(0xFFD32F2F),
            ),
          ),
          Expanded(
            child: _MetricTile(
              label: 'Stock Value',
              value: '₹ ${_currencyFormat.format(metrics.totalStockValue)}',
            ),
          ),
        ],
      ),
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
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
