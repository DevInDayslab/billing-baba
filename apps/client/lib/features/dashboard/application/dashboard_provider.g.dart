// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DashboardPeriodFilter)
final dashboardPeriodFilterProvider = DashboardPeriodFilterProvider._();

final class DashboardPeriodFilterProvider
    extends $NotifierProvider<DashboardPeriodFilter, DashboardPeriod> {
  DashboardPeriodFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardPeriodFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardPeriodFilterHash();

  @$internal
  @override
  DashboardPeriodFilter create() => DashboardPeriodFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardPeriod value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardPeriod>(value),
    );
  }
}

String _$dashboardPeriodFilterHash() =>
    r'cae4f4aa90e65b03978b6e331f924b13b5583115';

abstract class _$DashboardPeriodFilter extends $Notifier<DashboardPeriod> {
  DashboardPeriod build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DashboardPeriod, DashboardPeriod>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DashboardPeriod, DashboardPeriod>,
              DashboardPeriod,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Dashboard)
final dashboardProvider = DashboardProvider._();

final class DashboardProvider
    extends $AsyncNotifierProvider<Dashboard, DashboardViewState> {
  DashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardHash();

  @$internal
  @override
  Dashboard create() => Dashboard();
}

String _$dashboardHash() => r'825abb9da8c21539382b3fe8545354b88560c840';

abstract class _$Dashboard extends $AsyncNotifier<DashboardViewState> {
  FutureOr<DashboardViewState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<DashboardViewState>, DashboardViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DashboardViewState>, DashboardViewState>,
              AsyncValue<DashboardViewState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
