import 'package:billing_baba/features/dashboard/application/dashboard_error_mapper.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_provider.dart';
import 'package:billing_baba/features/dashboard/dashboard_navigation.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_chart_todo_row.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_offline_banner.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_overview_section.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_reports_row.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_side_widget_column.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_skeleton.dart';
import 'package:billing_baba/shared/layout/dashboard_layout.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardTabContent extends ConsumerWidget {
  const DashboardTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final period = ref.watch(dashboardPeriodFilterProvider);

    return dashboardAsync.when(
      loading: () => const _DashboardGridShell(child: DashboardSkeleton()),
      error: (error, _) {
        final message = DashboardErrorMapper.messageFor(error);
        final isOfflineNoCache =
            error is DashboardException && error.code == 'OFFLINE';
        return AppError(
          message: message,
          onRetry: isOfflineNoCache
              ? null
              : () => ref.read(dashboardProvider.notifier).refresh(),
        );
      },
      data: (viewState) => _DashboardGridShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (viewState.isCachedSnapshot)
              DashboardOfflineBanner(
                snapshotSavedAt: viewState.snapshotSavedAt,
                isRefreshing: viewState.isRefreshing,
              ),
            Expanded(
              child: _DashboardGrid(
                dashboard: viewState.dashboard,
                period: period,
                onPeriodChanged: (value) =>
                    ref.read(dashboardProvider.notifier).setPeriod(value),
                onReceivableTap: () =>
                    DashboardNavigation.openReceivables(context, ref),
                onPayableTap: () =>
                    DashboardNavigation.openPayables(context, ref),
                onSaleTap: () =>
                    DashboardNavigation.openTotalSale(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardGridShell extends StatelessWidget {
  const _DashboardGridShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = DashboardLayout.metricsFrom(constraints);
        return DashboardLayoutScope(
          metrics: metrics,
          child: Padding(
            padding: metrics.pagePadding,
            child: SizedBox(
              width: metrics.contentWidth,
              height: metrics.contentHeight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid({
    required this.dashboard,
    required this.period,
    required this.onPeriodChanged,
    required this.onReceivableTap,
    required this.onPayableTap,
    required this.onSaleTap,
  });

  final DashboardModel dashboard;
  final DashboardPeriod period;
  final ValueChanged<DashboardPeriod> onPeriodChanged;
  final VoidCallback onReceivableTap;
  final VoidCallback onPayableTap;
  final VoidCallback onSaleTap;

  @override
  Widget build(BuildContext context) {
    final metrics = DashboardLayoutScope.of(context);

    final kpiHeight = metrics.kpiRowHeight < DashboardLayout.kpiRowMinHeight
        ? DashboardLayout.kpiRowMinHeight
        : metrics.kpiRowHeight;
    final chartHeight =
        metrics.chartRowHeight < DashboardLayout.chartCardMinHeight
        ? DashboardLayout.chartCardMinHeight
        : metrics.chartRowHeight;
    final reportsHeight =
        metrics.reportsRowHeight < DashboardLayout.reportsRowMinHeight
        ? DashboardLayout.reportsRowMinHeight
        : metrics.reportsRowHeight;
    final gridHeight =
        kpiHeight + metrics.gap + chartHeight + metrics.gap + reportsHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bodyHeight = gridHeight > constraints.maxHeight
            ? gridHeight
            : constraints.maxHeight;

        return SingleChildScrollView(
          child: SizedBox(
            height: bodyHeight,
            width: constraints.maxWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: metrics.mainWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: kpiHeight,
                        child: DashboardOverviewSection(
                          overview: dashboard.overview,
                          onReceivableTap: onReceivableTap,
                          onPayableTap: onPayableTap,
                        ),
                      ),
                      SizedBox(height: metrics.gap),
                      SizedBox(
                        height: chartHeight,
                        child: DashboardChartTodoRow(
                          dashboard: dashboard,
                          period: period,
                          onPeriodChanged: onPeriodChanged,
                          onSaleTap: onSaleTap,
                        ),
                      ),
                      SizedBox(height: metrics.gap),
                      SizedBox(
                        height: reportsHeight,
                        child: DashboardReportsRow(
                          reports: dashboard.quickReports,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: metrics.gap),
                SizedBox(
                  width: metrics.sideWidth,
                  child: DashboardSideWidgetColumn(
                    dashboard: dashboard,
                    period: period,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
