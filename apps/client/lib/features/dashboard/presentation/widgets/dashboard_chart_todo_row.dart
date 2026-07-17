import 'package:billing_baba/core/layout/dashboard_layout.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_sales_section.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_todo_widget.dart';
import 'package:flutter/material.dart';

class DashboardChartTodoRow extends StatelessWidget {
  const DashboardChartTodoRow({
    required this.dashboard,
    required this.period,
    required this.onPeriodChanged,
    this.onSaleTap,
    super.key,
  });

  final DashboardModel dashboard;
  final DashboardPeriod period;
  final ValueChanged<DashboardPeriod> onPeriodChanged;
  final VoidCallback? onSaleTap;

  @override
  Widget build(BuildContext context) {
    final metrics = DashboardLayoutScope.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: metrics.chartColumnFlex,
          child: DashboardSalesSection(
            sales: dashboard.sales,
            period: period,
            onPeriodChanged: onPeriodChanged,
            onTap: onSaleTap,
          ),
        ),
        SizedBox(width: metrics.gap),
        Expanded(
          flex: metrics.todoColumnFlex,
          child: const DashboardTodoWidget(),
        ),
      ],
    );
  }
}
