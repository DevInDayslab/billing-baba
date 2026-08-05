import 'package:billing_baba/core/platform/mobile_platform_scope.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_provider.dart';
import 'package:billing_baba/features/dashboard/dashboard_navigation.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_app_header.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_dashboard_balance_cards.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_dashboard_expenses_month_card.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_dashboard_reports_section.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_dashboard_sales_card.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Mobile dashboard analytics (reachable from reports hub / deep links).
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AppError(
              message: error.toString(),
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
  });

  final DashboardModel dashboard;
  final DashboardPeriod period;

  static final _monthLabel = DateFormat('MMMM yyyy');

  static double _salesGrowthPercent(List<DashboardTrendPointModel> points) {
    if (points.length < 2) return 0;
    final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));
    final prev = sorted[sorted.length - 2].amount;
    final last = sorted.last.amount;
    if (prev == 0) return 0;
    return ((last - prev) / prev) * 100;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final growth = _salesGrowthPercent(dashboard.sales.trendPoints);

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: MobileAppHeader(
              showWelcome: false,
              onBusinessTap: () => context.push(AppRoutes.businessList),
              onNotificationTap: () => context.push(AppRoutes.notifications),
              onSettingsTap: () => context.push(AppRoutes.settings),
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
                  onTap: () => DashboardNavigation.openTotalSale(context, ref),
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
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
