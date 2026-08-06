import 'package:billing_baba/features/dashboard/application/dashboard_provider.dart';
import 'package:billing_baba/features/dashboard/dashboard_navigation.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_financial_assets_row.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_home_quick_actions.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_home_todays_business_carousel.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_money_cards.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Business Overview tab — matches home mockup section order.
class MobileHomeBusinessOverviewTab extends ConsumerWidget {
  const MobileHomeBusinessOverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AppError(
        message: error.toString(),
        onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
      ),
      data: (viewState) {
        final dashboard = viewState.dashboard;

        return RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: MobileHomeQuickActions()),
              const SliverToBoxAdapter(
                child: MobileHomeTodaysBusinessCarousel(),
              ),
              SliverToBoxAdapter(
                child: MobileMoneyCards(
                  overview: dashboard.overview,
                  onYoullGetTap: () =>
                      DashboardNavigation.openReceivables(context, ref),
                  onYoullGiveTap: () =>
                      DashboardNavigation.openPayables(context, ref),
                  onHeaderTap: () =>
                      DashboardNavigation.openReceivables(context, ref),
                ),
              ),
              SliverToBoxAdapter(
                child: MobileFinancialAssetsRow(dashboard: dashboard),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MobileBottomNavigation.contentBottomPadding(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
