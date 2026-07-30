// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardService)
final dashboardServiceProvider = DashboardServiceProvider._();

final class DashboardServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardService>,
          DashboardService,
          FutureOr<DashboardService>
        >
    with $FutureModifier<DashboardService>, $FutureProvider<DashboardService> {
  DashboardServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardServiceHash();

  @$internal
  @override
  $FutureProviderElement<DashboardService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardService> create(Ref ref) {
    return dashboardService(ref);
  }
}

String _$dashboardServiceHash() => r'bc0fc8769c1f1c0289082835c39a7e7779133e0d';
