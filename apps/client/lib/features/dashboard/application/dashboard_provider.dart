import 'dart:async';

import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_service.dart';
import 'package:billing_baba/features/dashboard/application/local_business_metrics_provider.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model_merger.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_view_state.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@Riverpod(keepAlive: true)
class DashboardPeriodFilter extends _$DashboardPeriodFilter {
  @override
  DashboardPeriod build() => DashboardPeriod.thisMonth;

  void setPeriod(DashboardPeriod period) => state = period;
}

@Riverpod(keepAlive: true)
class Dashboard extends _$Dashboard {
  @override
  Future<DashboardViewState> build() async {
    final period = ref.watch(dashboardPeriodFilterProvider);
    return _load(period);
  }

  Future<DashboardViewState> _load(DashboardPeriod period) async {
    final service = await ref.read(dashboardServiceProvider.future);
    final query = DashboardQuery(period: period);
    final cached = service.readCachedViewState(query);
    if (cached != null) {
      final initial = await _mergeLocalMetrics(
        cached.copyWith(isRefreshing: true),
        period,
      );
      unawaited(_refreshInBackground(period, hadCache: true));
      return initial;
    }
    return _mergeLocalMetrics(await service.fetchDashboard(query), period);
  }

  Future<void> _refreshInBackground(
    DashboardPeriod period, {
    required bool hadCache,
  }) async {
    try {
      final service = await ref.read(dashboardServiceProvider.future);
      final fresh = await _mergeLocalMetrics(
        await service.fetchDashboard(DashboardQuery(period: period)),
        period,
      );
      if (!ref.mounted) return;
      state = AsyncData(
        hadCache ? fresh.copyWith(isRefreshing: false) : fresh,
      );
    } on Object catch (error) {
      if (!ref.mounted || !hadCache) return;
      final current = state.value;
      if (current == null) return;

      if (!OfflineUiMessages.isOfflineError(error)) {
        state = AsyncData(current.copyWith(isRefreshing: false));
        return;
      }

      // Network/server unreachable — keep last synced numbers and show offline UX.
      state = AsyncData(
        current.copyWith(
          isCachedSnapshot: true,
          isRefreshing: false,
        ),
      );
    }
  }

  Future<void> refresh() async {
    final period = ref.read(dashboardPeriodFilterProvider);
    final previous = state.value;
    if (previous?.isCachedSnapshot == true) {
      state = AsyncData(previous!.copyWith(isRefreshing: true));
    } else {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() => _loadFresh(period));
  }

  Future<void> setPeriod(DashboardPeriod period) async {
    ref.read(dashboardPeriodFilterProvider.notifier).setPeriod(period);
    final previous = state.value;
    final service = await ref.read(dashboardServiceProvider.future);
    final cached = service.readCachedViewState(DashboardQuery(period: period));
    if (cached != null) {
      state = AsyncData(
        await _mergeLocalMetrics(
          cached.copyWith(isRefreshing: true, isCachedSnapshot: false),
          period,
        ),
      );
      unawaited(_refreshInBackground(period, hadCache: true));
      return;
    }
    if (previous == null) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() => _loadFresh(period));
  }

  Future<DashboardViewState> _loadFresh(DashboardPeriod period) async {
    final service = await ref.read(dashboardServiceProvider.future);
    final viewState = await service.fetchDashboard(DashboardQuery(period: period));
    return _mergeLocalMetrics(viewState, period);
  }

  Future<DashboardViewState> _mergeLocalMetrics(
    DashboardViewState viewState,
    DashboardPeriod period,
  ) async {
    final metricsService = await ref.read(
      localBusinessMetricsServiceProvider.future,
    );
    final query = DashboardQuery(period: period);
    final localOverview = await metricsService.loadOutstandingOverview();
    final localPeriod = await metricsService.loadPeriodMetrics(query);
    final inventoryItems = ref.read(inventoryItemListProvider);
    return viewState.copyWith(
      dashboard: DashboardModelMerger.merge(
        remote: viewState.dashboard,
        localOverview: localOverview,
        localPeriod: localPeriod,
        inventoryItems: inventoryItems,
        metrics: metricsService,
      ),
    );
  }

  void seedCached(DashboardViewState cached) {
    state = AsyncData(cached);
  }
}
