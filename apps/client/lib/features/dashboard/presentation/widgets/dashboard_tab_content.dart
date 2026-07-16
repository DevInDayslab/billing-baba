import 'package:billing_baba/core/layout/dashboard_layout.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/widgets/app_error.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_error_mapper.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_chart_todo_row.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_overview_section.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_reports_row.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_side_widget_column.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_skeleton.dart';
import 'package:billing_baba/features/dashboard/providers/dashboard_provider.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:billing_baba/features/parties/providers/parties_selection_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardTabContent extends ConsumerWidget {
  const DashboardTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final period = ref.watch(dashboardPeriodFilterProvider);

    return dashboardAsync.when(
      loading: () => const _DashboardGridShell(child: DashboardSkeleton()),
      error: (error, _) => AppError(
        message: DashboardErrorMapper.messageFor(error),
        onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
      ),
      data: (dashboard) => _DashboardGridShell(
        child: _DashboardGrid(
          dashboard: dashboard,
          period: period,
          onPeriodChanged: (value) =>
              ref.read(dashboardProvider.notifier).setPeriod(value),
          onReceivableTap: () => _openParties(
            context,
            ref,
            PartyListFilter.toReceive,
          ),
          onPayableTap: () => _openParties(
            context,
            ref,
            PartyListFilter.toPay,
          ),
        ),
      ),
    );
  }

  void _openParties(
    BuildContext context,
    WidgetRef ref,
    PartyListFilter filter,
  ) {
    ref.read(partyListFilterProvider.notifier).filter = filter;
    ref.read(partySearchQueryProvider.notifier).query = '';
    ref.read(selectedPartyIdProvider.notifier).selected = null;
    context.go(AppRoutes.partyDetails);
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
  });

  final DashboardModel dashboard;
  final DashboardPeriod period;
  final ValueChanged<DashboardPeriod> onPeriodChanged;
  final VoidCallback onReceivableTap;
  final VoidCallback onPayableTap;

  @override
  Widget build(BuildContext context) {
    final metrics = DashboardLayoutScope.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: metrics.mainWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: metrics.kpiRowHeight,
                child: DashboardOverviewSection(
                  overview: dashboard.overview,
                  onReceivableTap: onReceivableTap,
                  onPayableTap: onPayableTap,
                ),
              ),
              SizedBox(height: metrics.gap),
              SizedBox(
                height: metrics.chartRowHeight,
                child: DashboardChartTodoRow(
                  dashboard: dashboard,
                  period: period,
                  onPeriodChanged: onPeriodChanged,
                ),
              ),
              SizedBox(height: metrics.gap),
              SizedBox(
                height: metrics.reportsRowHeight,
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
    );
  }
}
