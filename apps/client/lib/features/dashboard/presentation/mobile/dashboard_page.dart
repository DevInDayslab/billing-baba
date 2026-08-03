import 'package:billing_baba/core/platform/mobile_platform_scope.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_provider.dart';
import 'package:billing_baba/features/dashboard/dashboard_navigation.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_dashboard_mock_data.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_dashboard_balance_cards.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_dashboard_expenses_list_card.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_dashboard_expenses_month_card.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_dashboard_header.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_dashboard_reports_section.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_dashboard_sales_card.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Vyapar-style mobile dashboard (DASHBOARD bottom-nav tab).
class MobileDashboardPage extends ConsumerWidget {
  const MobileDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final period = ref.watch(dashboardPeriodFilterProvider);

    return MobilePlatformScope(
      child: ColoredBox(
        color: AppColors.background,
        child: SafeArea(
          bottom: false,
          child: dashboardAsync.when(
            loading: () => _DashboardBody(
              dashboard: MobileDashboardMockData.dashboard(period: period),
              period: period,
            ),
            error: (_, _) => _DashboardBody(
              dashboard: MobileDashboardMockData.dashboard(period: period),
              period: period,
              onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
            ),
            data: (viewState) => _DashboardBody(
              dashboard: viewState.dashboard,
              period: period,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({
    required this.dashboard,
    required this.period,
    this.isLoading = false,
    this.onRetry,
  });

  final DashboardModel dashboard;
  final DashboardPeriod period;
  final bool isLoading;
  final VoidCallback? onRetry;

  static final _monthLabel = DateFormat('MMMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final growth = MobileDashboardMockData.salesGrowthPercent(
      dashboard.sales.trendPoints,
    );

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: MobileDashboardHeader(
                  onBusinessTap: () => context.push(AppRoutes.businessList),
                  onNotificationTap: () =>
                      context.push(AppRoutes.notifications),
                  onSettingsTap: () => context.push(AppRoutes.settings),
                  notificationBadgeCount: 2,
                ),
              ),
              if (onRetry != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: TextButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry loading live data'),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  MobileBottomNavigation.barHeight + AppSpacing.xl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    MobileDashboardBalanceCards(
                      overview: dashboard.overview,
                      onYoullGetTap: () =>
                          DashboardNavigation.openReceivables(context, ref),
                      onYoullGiveTap: () =>
                          DashboardNavigation.openPayables(context, ref),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MobileDashboardSalesCard(
                      sales: dashboard.sales,
                      period: period,
                      growthPercent: growth,
                      onTap: () =>
                          DashboardNavigation.openTotalSale(context, ref),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MobileDashboardExpensesMonthCard(
                      amount: dashboard.finance.expenses,
                      monthLabel: _monthLabel.format(DateTime.now()),
                      onTap: () => context.go(AppRoutes.purchaseExpenses),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MobileDashboardReportsSection(
                      reports: dashboard.quickReports,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MobileDashboardExpensesListCard(
                      items: MobileDashboardMockData.expenseItems,
                      onSeeAllTap: () => context.go(AppRoutes.purchaseExpenses),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x44FFFFFF),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
