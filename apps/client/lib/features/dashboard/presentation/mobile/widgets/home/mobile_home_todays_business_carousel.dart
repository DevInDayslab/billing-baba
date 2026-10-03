import 'dart:async';

import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_provider.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_trend_chart.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Manual-swipe carousel: Total Sales · Total Purchase · Total Profit.
class MobileHomeTodaysBusinessCarousel extends ConsumerStatefulWidget {
  const MobileHomeTodaysBusinessCarousel({super.key});

  @override
  ConsumerState<MobileHomeTodaysBusinessCarousel> createState() =>
      _MobileHomeTodaysBusinessCarouselState();
}

class _MobileHomeTodaysBusinessCarouselState
    extends ConsumerState<MobileHomeTodaysBusinessCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static const List<DashboardPeriod> _periodOptions = [
    DashboardPeriod.today,
    DashboardPeriod.thisWeek,
    DashboardPeriod.thisMonth,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickPeriod() async {
    final current = ref.read(dashboardPeriodFilterProvider);
    final selected = await showMobileOptionSheet<DashboardPeriod>(
      context: context,
      title: 'Period',
      selected: current,
      options: [
        for (final period in _periodOptions)
          MobileOption(value: period, label: period.label),
      ],
    );
    if (selected == null || !mounted) return;
    await ref.read(dashboardProvider.notifier).setPeriod(selected);
  }

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(dashboardPeriodFilterProvider);
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      loading: () => const _CarouselShell(
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => _CarouselShell(
        child: AppError(
          message: OfflineUiMessages.messageFor(error),
          onRetry: () =>
              unawaited(ref.read(dashboardProvider.notifier).refresh()),
        ),
      ),
      data: (state) => _CarouselContent(
        dashboard: state.dashboard,
        pageController: _pageController,
        currentPage: _currentPage,
        period: period,
        onPageChanged: (index) => setState(() => _currentPage = index),
        onPickPeriod: _pickPeriod,
      ),
    );
  }
}

class _CarouselShell extends StatelessWidget {
  const _CarouselShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardBorder,
          border: Border.all(color: AppColors.chipBorder),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}

class _CarouselContent extends StatelessWidget {
  const _CarouselContent({
    required this.dashboard,
    required this.pageController,
    required this.currentPage,
    required this.period,
    required this.onPageChanged,
    required this.onPickPeriod,
  });

  final DashboardModel dashboard;
  final PageController pageController;
  final int currentPage;
  final DashboardPeriod period;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onPickPeriod;

  double get _profit =>
      dashboard.sales.totalAmount -
      dashboard.purchases.totalAmount -
      dashboard.finance.expenses;

  String get _sectionTitle => switch (period) {
    DashboardPeriod.today => "Today's Business",
    DashboardPeriod.thisWeek => "This Week's Business",
    DashboardPeriod.thisMonth => "This Month's Business",
    _ => '${period.label} Business',
  };

  String get _comparisonLabel => switch (period) {
    DashboardPeriod.today => 'vs yesterday',
    DashboardPeriod.thisWeek => 'vs last week',
    DashboardPeriod.thisMonth => 'vs last month',
    _ => 'vs previous period',
  };

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final profitTrend = _profitTrendPoints(
      dashboard.sales.trendPoints,
      dashboard.purchases.trendPoints,
    );
    final pages = [
      _CarouselPageData(
        title: 'Total Sales',
        amount: dashboard.sales.totalAmount,
        trendPoints: dashboard.sales.trendPoints,
        icon: LucideIcons.chartColumn,
      ),
      _CarouselPageData(
        title: 'Total Purchase',
        amount: dashboard.purchases.totalAmount,
        trendPoints: dashboard.purchases.trendPoints,
        icon: LucideIcons.shoppingBag,
      ),
      _CarouselPageData(
        title: 'Total Profit',
        amount: _profit,
        trendPoints: profitTrend,
        icon: LucideIcons.trendingUp,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardBorder,
          border: Border.all(color: AppColors.chipBorder),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _sectionTitle,
                    style: AppTypography.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPickPeriod,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.chipInactive,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            period.label,
                            style: AppTypography.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Icon(
                            LucideIcons.chevronDown,
                            size: 16,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 140,
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  final growth = _growthPercent(page.trendPoints);
                  final chartPoints = _chartDisplayPoints(
                    page.trendPoints,
                    period,
                  );

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: AppColors.tabActiveTint,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(page.icon, color: primary, size: 24),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              page.title,
                              style: AppTypography.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _MobileHomeTodaysBusinessCarouselState._currency
                                  .format(page.amount),
                              style: AppTypography.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                                height: 1.05,
                              ),
                              maxLines: 2,
                              softWrap: true,
                            ),
                            if (growth != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${growth >= 0 ? '▲' : '▼'} ${growth.abs().toStringAsFixed(1)}% $_comparisonLabel',
                                style: AppTypography.inter(
                                  fontSize: 10.5,
                                  color: growth >= 0
                                      ? AppColors.success
                                      : AppColors.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        flex: 14,
                        child: RepaintBoundary(
                          child: DashboardTrendChart(
                            points: chartPoints,
                            lineColor: primary,
                            period: period,
                            minimal: true,
                            emptyMessage: '',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                final active = index == currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: active ? primary : AppColors.chipBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  static List<DashboardTrendPointModel> _profitTrendPoints(
    List<DashboardTrendPointModel> sales,
    List<DashboardTrendPointModel> purchases,
  ) {
    if (sales.isEmpty) return const [];
    if (purchases.isEmpty) return sales;

    final purchaseByDate = {
      for (final point in purchases) point.date: point.amount,
    };

    return sales
        .map(
          (point) => DashboardTrendPointModel(
            date: point.date,
            amount: point.amount - (purchaseByDate[point.date] ?? 0),
          ),
        )
        .toList();
  }

  static double? _growthPercent(List<DashboardTrendPointModel> points) {
    if (points.length < 2) return null;
    final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));
    final prev = sorted[sorted.length - 2].amount;
    final last = sorted.last.amount;
    if (prev == 0) return null;
    return ((last - prev) / prev) * 100;
  }

  /// Ensures the chart always has enough points to render, even with no data.
  static List<DashboardTrendPointModel> _chartDisplayPoints(
    List<DashboardTrendPointModel> points,
    DashboardPeriod period,
  ) {
    if (points.length >= 2) return points;

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    if (period == DashboardPeriod.today) {
      const hours = [6, 9, 12, 15, 18, 21];
      return List.generate(hours.length, (index) {
        final date = DateTime(
          normalizedToday.year,
          normalizedToday.month,
          normalizedToday.day,
          hours[index],
        );
        if (points.length == 1 && index == hours.length - 1) {
          return points.first;
        }
        return DashboardTrendPointModel(date: date, amount: 0);
      });
    }

    final slotCount = switch (period) {
      DashboardPeriod.thisWeek => 7,
      DashboardPeriod.thisMonth => 7,
      _ => 7,
    };

    return List.generate(slotCount, (index) {
      final date = normalizedToday.subtract(
        Duration(days: slotCount - 1 - index),
      );
      if (points.length == 1 && index == slotCount - 1) {
        return points.first;
      }
      return DashboardTrendPointModel(date: date, amount: 0);
    });
  }
}

class _CarouselPageData {
  const _CarouselPageData({
    required this.title,
    required this.amount,
    required this.trendPoints,
    required this.icon,
  });

  final String title;
  final double amount;
  final List<DashboardTrendPointModel> trendPoints;
  final IconData icon;
}
