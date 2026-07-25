// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deals_selection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DealsViewModeState)
final dealsViewModeStateProvider = DealsViewModeStateProvider._();

final class DealsViewModeStateProvider
    extends $NotifierProvider<DealsViewModeState, DealsViewMode> {
  DealsViewModeStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dealsViewModeStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dealsViewModeStateHash();

  @$internal
  @override
  DealsViewModeState create() => DealsViewModeState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DealsViewMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DealsViewMode>(value),
    );
  }
}

String _$dealsViewModeStateHash() =>
    r'ee18bba18554cfa77ce32938720b8a7fe62a446c';

abstract class _$DealsViewModeState extends $Notifier<DealsViewMode> {
  DealsViewMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DealsViewMode, DealsViewMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DealsViewMode, DealsViewMode>,
              DealsViewMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedDealIds)
final selectedDealIdsProvider = SelectedDealIdsProvider._();

final class SelectedDealIdsProvider
    extends $NotifierProvider<SelectedDealIds, Set<String>> {
  SelectedDealIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDealIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDealIdsHash();

  @$internal
  @override
  SelectedDealIds create() => SelectedDealIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$selectedDealIdsHash() => r'30c6b5e1ffd9b2735f55da53ea6de5f0b7b0279b';

abstract class _$SelectedDealIds extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(DealSearchQuery)
final dealSearchQueryProvider = DealSearchQueryProvider._();

final class DealSearchQueryProvider
    extends $NotifierProvider<DealSearchQuery, String> {
  DealSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dealSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dealSearchQueryHash();

  @$internal
  @override
  DealSearchQuery create() => DealSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$dealSearchQueryHash() => r'deee33a19633390ba57e95ac22f1f839193e6a37';

abstract class _$DealSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(DealFilters)
final dealFiltersProvider = DealFiltersProvider._();

final class DealFiltersProvider
    extends $NotifierProvider<DealFilters, DealFiltersState> {
  DealFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dealFiltersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dealFiltersHash();

  @$internal
  @override
  DealFilters create() => DealFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DealFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DealFiltersState>(value),
    );
  }
}

String _$dealFiltersHash() => r'afc446e1ec50427782bfd30e41bb56a3205e8617';

abstract class _$DealFilters extends $Notifier<DealFiltersState> {
  DealFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DealFiltersState, DealFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DealFiltersState, DealFiltersState>,
              DealFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(DealFilterPanelOpen)
final dealFilterPanelOpenProvider = DealFilterPanelOpenProvider._();

final class DealFilterPanelOpenProvider
    extends $NotifierProvider<DealFilterPanelOpen, bool> {
  DealFilterPanelOpenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dealFilterPanelOpenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dealFilterPanelOpenHash();

  @$internal
  @override
  DealFilterPanelOpen create() => DealFilterPanelOpen();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$dealFilterPanelOpenHash() =>
    r'edd10dd1b24a3179b96141a2658d506cb9f92257';

abstract class _$DealFilterPanelOpen extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
