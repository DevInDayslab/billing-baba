import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/app_error.dart';
import 'package:billing_baba/core/widgets/app_loader.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_error_mapper.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_inventory_section.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_overview_section.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_quick_reports_section.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_recent_transactions_section.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_sales_section.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/dashboard/providers/dashboard_provider.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:billing_baba/features/parties/providers/parties_selection_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _maxContentWidth = 1400.0;
  static const _desktopBreakpoint = 1200.0;
  static const _laptopBreakpoint = 992.0;
  static const _tabletBreakpoint = 768.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final period = ref.watch(dashboardPeriodFilterProvider);

    return ColoredBox(
      color: AppColors.background,
      child: dashboardAsync.when(
        loading: () => const AppLoader(message: 'Loading dashboard…'),
        error: (error, _) => AppError(
          message: DashboardErrorMapper.messageFor(error),
          onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
        ),
        data: (dashboard) => RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isDesktop = width >= _desktopBreakpoint;
              final isLaptop =
                  width >= _laptopBreakpoint && width < _desktopBreakpoint;
              final isTablet =
                  width >= _tabletBreakpoint && width < _laptopBreakpoint;
              final isMobile = width < _tabletBreakpoint;

              void onPeriodChanged(DashboardPeriod value) =>
                  ref.read(dashboardProvider.notifier).setPeriod(value);

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(DashboardSpacing.sectionGap),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _maxContentWidth,
                    ),
                    child: Column(
                      children: [
                        DashboardOverviewSection(
                          overview: dashboard.overview,
                          finance: dashboard.finance,
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
                        const SizedBox(height: DashboardSpacing.sectionGap),
                        if (isDesktop)
                          _DesktopChartsRow(
                            dashboard: dashboard,
                            period: period,
                            onPeriodChanged: onPeriodChanged,
                          )
                        else if (isLaptop)
                          _LaptopChartsSection(
                            dashboard: dashboard,
                            period: period,
                            onPeriodChanged: onPeriodChanged,
                          )
                        else
                          _StackedChartsSection(
                            dashboard: dashboard,
                            period: period,
                            onPeriodChanged: onPeriodChanged,
                          ),
                        const SizedBox(height: DashboardSpacing.sectionGap),
                        if (isDesktop || isLaptop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: DashboardRecentTransactionsSection(
                                  transactions: dashboard.recentTransactions,
                                ),
                              ),
                              const SizedBox(
                                width: DashboardSpacing.widgetGap,
                              ),
                              Expanded(
                                flex: 3,
                                child: DashboardQuickReportsSection(
                                  reports: dashboard.quickReports,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          DashboardRecentTransactionsSection(
                            transactions: dashboard.recentTransactions,
                          ),
                          if (isTablet || isMobile) ...[
                            const SizedBox(
                              height: DashboardSpacing.sectionGap,
                            ),
                            DashboardQuickReportsSection(
                              reports: dashboard.quickReports,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
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

class _DesktopChartsRow extends StatelessWidget {
  const _DesktopChartsRow({
    required this.dashboard,
    required this.period,
    required this.onPeriodChanged,
  });

  final DashboardModel dashboard;
  final DashboardPeriod period;
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: DashboardSalesSection(
            sales: dashboard.sales,
            period: period,
            onPeriodChanged: onPeriodChanged,
          ),
        ),
        const SizedBox(width: DashboardSpacing.widgetGap),
        Expanded(
          flex: 4,
          child: DashboardPurchasesCard(
            purchases: dashboard.purchases,
            period: period,
            onPeriodChanged: onPeriodChanged,
          ),
        ),
        const SizedBox(width: DashboardSpacing.widgetGap),
        Expanded(
          flex: 3,
          child: DashboardInventorySection(inventory: dashboard.inventory),
        ),
      ],
    );
  }
}

class _LaptopChartsSection extends StatelessWidget {
  const _LaptopChartsSection({
    required this.dashboard,
    required this.period,
    required this.onPeriodChanged,
  });

  final DashboardModel dashboard;
  final DashboardPeriod period;
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumn = constraints.maxWidth >= 720;

        if (twoColumn) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DashboardSalesSection(
                      sales: dashboard.sales,
                      period: period,
                      onPeriodChanged: onPeriodChanged,
                    ),
                  ),
                  const SizedBox(width: DashboardSpacing.widgetGap),
                  Expanded(
                    child: DashboardPurchasesCard(
                      purchases: dashboard.purchases,
                      period: period,
                      onPeriodChanged: onPeriodChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DashboardSpacing.widgetGap),
              DashboardInventorySection(inventory: dashboard.inventory),
            ],
          );
        }

        return _StackedChartsSection(
          dashboard: dashboard,
          period: period,
          onPeriodChanged: onPeriodChanged,
        );
      },
    );
  }
}

class _StackedChartsSection extends StatelessWidget {
  const _StackedChartsSection({
    required this.dashboard,
    required this.period,
    required this.onPeriodChanged,
  });

  final DashboardModel dashboard;
  final DashboardPeriod period;
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardSalesSection(
          sales: dashboard.sales,
          period: period,
          onPeriodChanged: onPeriodChanged,
        ),
        const SizedBox(height: DashboardSpacing.widgetGap),
        DashboardPurchasesCard(
          purchases: dashboard.purchases,
          period: period,
          onPeriodChanged: onPeriodChanged,
        ),
        const SizedBox(height: DashboardSpacing.widgetGap),
        DashboardInventorySection(inventory: dashboard.inventory),
      ],
    );
  }
}
