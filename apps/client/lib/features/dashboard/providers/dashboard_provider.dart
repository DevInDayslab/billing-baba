import 'package:billing_baba/features/dashboard/application/dashboard_service.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
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
  Future<DashboardModel> build() async {
    final period = ref.watch(dashboardPeriodFilterProvider);
    return _fetch(period);
  }

  Future<DashboardModel> _fetch(DashboardPeriod period) async {
    final service = await ref.read(dashboardServiceProvider.future);
    return service.fetchDashboard(DashboardQuery(period: period));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(ref.read(dashboardPeriodFilterProvider)),
    );
  }

  Future<void> setPeriod(DashboardPeriod period) async {
    ref.read(dashboardPeriodFilterProvider.notifier).setPeriod(period);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(period));
  }
}
