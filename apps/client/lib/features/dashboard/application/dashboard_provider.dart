import 'package:billing_baba/core/network/offline_utils.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_service.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

final dashboardUsingCacheProvider =
    NotifierProvider<DashboardUsingCacheNotifier, bool>(
      DashboardUsingCacheNotifier.new,
    );

class DashboardUsingCacheNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setValue(bool value) => state = value;
}

@Riverpod(keepAlive: true)
class DashboardPeriodFilter extends _$DashboardPeriodFilter {
  @override
  DashboardPeriod build() => DashboardPeriod.thisMonth;

  void setPeriod(DashboardPeriod period) => state = period;
}

@Riverpod(keepAlive: true)
class Dashboard extends _$Dashboard {
  DashboardModel? _cached;

  @override
  Future<DashboardModel> build() async {
    final period = ref.watch(dashboardPeriodFilterProvider);
    return _fetch(period);
  }

  Future<DashboardModel> _fetch(DashboardPeriod period) async {
    try {
      final service = await ref.read(dashboardServiceProvider.future);
      final result = await service.fetchDashboard(DashboardQuery(period: period));
      _cached = result;
      ref.read(dashboardUsingCacheProvider.notifier).setValue(false);
      return result;
    } catch (error) {
      if (_cached != null && isOfflineError(error)) {
        ref.read(dashboardUsingCacheProvider.notifier).setValue(true);
        return _cached!;
      }
      ref.read(dashboardUsingCacheProvider.notifier).setValue(false);
      rethrow;
    }
  }

  Future<void> refresh() async {
    final previous = state.value ?? _cached;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(ref.read(dashboardPeriodFilterProvider)),
    );
    if (state.hasError && previous != null && isOfflineError(state.error)) {
      ref.read(dashboardUsingCacheProvider.notifier).setValue(true);
      state = AsyncData(previous);
    }
  }

  Future<void> setPeriod(DashboardPeriod period) async {
    ref.read(dashboardPeriodFilterProvider.notifier).setPeriod(period);
    final previous = state.value ?? _cached;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(period));
    if (state.hasError && previous != null && isOfflineError(state.error)) {
      ref.read(dashboardUsingCacheProvider.notifier).setValue(true);
      state = AsyncData(previous);
    }
  }
}
