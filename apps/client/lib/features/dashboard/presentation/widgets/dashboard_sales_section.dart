import 'package:billing_baba/core/layout/dashboard_layout.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_metric_card.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_period_selector.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_trend_chart.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardSalesSection extends StatelessWidget {
  const DashboardSalesSection({
    required this.sales,
    required this.period,
    required this.onPeriodChanged,
    super.key,
  });

  final DashboardSalesModel sales;
  final DashboardPeriod period;
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final metrics = DashboardLayoutScope.of(context);

    return DashboardMetricCard(
      padding: metrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Sale',
                  style: DashboardTypography.cardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DashboardPeriodSelector(
                period: period,
                onChanged: onPeriodChanged,
              ),
            ],
          ),
          SizedBox(height: metrics.gap * 0.5),
          Text(
            _currencyFormat.format(sales.totalAmount),
            style: DashboardTypography.chartValue,
          ),
          SizedBox(height: metrics.gap * 0.5),
          Expanded(
            flex: (DashboardLayout.chartAreaHeightRatio * 100).round(),
            child: DashboardTrendChart(
              points: sales.trendPoints,
              lineColor: AppColors.primary,
              minimal: true,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class DashboardPurchasesCard extends StatelessWidget {
  const DashboardPurchasesCard({
    required this.purchases,
    required this.period,
    required this.onPeriodChanged,
    super.key,
  });

  final DashboardPurchasesModel purchases;
  final DashboardPeriod period;
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final metrics = DashboardLayoutScope.of(context);

    return DashboardMetricCard(
      padding: metrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Purchases',
                  style: DashboardTypography.cardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DashboardPeriodSelector(
                period: period,
                onChanged: onPeriodChanged,
              ),
            ],
          ),
          SizedBox(height: metrics.gap * 0.5),
          Text(
            _currencyFormat.format(purchases.totalAmount),
            style: DashboardTypography.chartValue,
          ),
          SizedBox(height: metrics.gap * 0.5),
          Expanded(
            flex: (DashboardLayout.chartAreaHeightRatio * 100).round(),
            child: DashboardTrendChart(
              points: purchases.trendPoints,
              lineColor: DashboardColors.outgoing,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
