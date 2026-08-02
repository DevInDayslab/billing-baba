import 'dart:async';

import 'package:billing_baba/features/dashboard/application/dashboard_service.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_view_state.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
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
      unawaited(_refreshInBackground(period, hadCache: true));
      return cached;
    }
    return service.fetchDashboard(query);
  }

  Future<void> _refreshInBackground(
    DashboardPeriod period, {
    required bool hadCache,
  }) async {
    try {
      final service = await ref.read(dashboardServiceProvider.future);
      final fresh = await service.fetchDashboard(
        DashboardQuery(period: period),
      );
      if (!ref.mounted) return;
      state = AsyncData(
        hadCache ? fresh.copyWith(isRefreshing: false) : fresh,
      );
    } on Object {
      // Keep showing cached snapshot when background refresh fails.
      if (!ref.mounted || !hadCache) return;
      final current = state.value;
      if (current != null && current.isCachedSnapshot) {
        state = AsyncData(current.copyWith(isRefreshing: false));
      }
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
      state = AsyncData(cached.copyWith(isRefreshing: true));
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
    return service.fetchDashboard(DashboardQuery(period: period));
  }
}
