// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_widget_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DashboardWidgetPreferences)
final dashboardWidgetPreferencesProvider =
    DashboardWidgetPreferencesProvider._();

final class DashboardWidgetPreferencesProvider
    extends
        $NotifierProvider<
          DashboardWidgetPreferences,
          List<DashboardSideWidget>
        > {
  DashboardWidgetPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardWidgetPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardWidgetPreferencesHash();

  @$internal
  @override
  DashboardWidgetPreferences create() => DashboardWidgetPreferences();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DashboardSideWidget> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DashboardSideWidget>>(value),
    );
  }
}

String _$dashboardWidgetPreferencesHash() =>
    r'8c7161c7ec5e6767dd88035271e3df5b0f3c9a4a';

abstract class _$DashboardWidgetPreferences
    extends $Notifier<List<DashboardSideWidget>> {
  List<DashboardSideWidget> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<DashboardSideWidget>, List<DashboardSideWidget>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<DashboardSideWidget>, List<DashboardSideWidget>>,
              List<DashboardSideWidget>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(DashboardActiveTab)
final dashboardActiveTabProvider = DashboardActiveTabProvider._();

final class DashboardActiveTabProvider
    extends $NotifierProvider<DashboardActiveTab, DashboardHomeTab> {
  DashboardActiveTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardActiveTabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardActiveTabHash();

  @$internal
  @override
  DashboardActiveTab create() => DashboardActiveTab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardHomeTab value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardHomeTab>(value),
    );
  }
}

String _$dashboardActiveTabHash() =>
    r'fe63e36da5bc6732565afd9e39d72e7af3bea703';

abstract class _$DashboardActiveTab extends $Notifier<DashboardHomeTab> {
  DashboardHomeTab build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DashboardHomeTab, DashboardHomeTab>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DashboardHomeTab, DashboardHomeTab>,
              DashboardHomeTab,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
