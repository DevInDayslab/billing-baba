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

  static const _chartHeight = 180.0;

  @override
  Widget build(BuildContext context) {
    return DashboardMetricCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Sales',
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
          const SizedBox(height: DashboardSpacing.titleToValue),
          Text(
            _currencyFormat.format(sales.totalAmount),
            style: DashboardTypography.mainValue,
          ),
          const SizedBox(height: DashboardSpacing.valueToContent),
          SizedBox(
            height: _chartHeight,
            child: DashboardTrendChart(
              points: sales.trendPoints,
              lineColor: AppColors.primary,
            ),
          ),
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
    return DashboardMetricCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: DashboardSpacing.titleToValue),
          Text(
            _currencyFormat.format(purchases.totalAmount),
            style: DashboardTypography.mainValue,
          ),
          const SizedBox(height: DashboardSpacing.valueToContent),
          SizedBox(
            height: DashboardSalesSection._chartHeight,
            child: DashboardTrendChart(
              points: purchases.trendPoints,
              lineColor: DashboardColors.outgoing,
            ),
          ),
        ],
      ),
    );
  }
}
