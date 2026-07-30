// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leads_selection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedLeadId)
final selectedLeadIdProvider = SelectedLeadIdProvider._();

final class SelectedLeadIdProvider
    extends $NotifierProvider<SelectedLeadId, String?> {
  SelectedLeadIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedLeadIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedLeadIdHash();

  @$internal
  @override
  SelectedLeadId create() => SelectedLeadId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedLeadIdHash() => r'ff8525da0ad75c0ea1958cde7423923a1dd0a973';

abstract class _$SelectedLeadId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedLeadIds)
final selectedLeadIdsProvider = SelectedLeadIdsProvider._();

final class SelectedLeadIdsProvider
    extends $NotifierProvider<SelectedLeadIds, Set<String>> {
  SelectedLeadIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedLeadIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedLeadIdsHash();

  @$internal
  @override
  SelectedLeadIds create() => SelectedLeadIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$selectedLeadIdsHash() => r'062c2749b664292a4878605a221acad46bd2abb6';

abstract class _$SelectedLeadIds extends $Notifier<Set<String>> {
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

@ProviderFor(LeadSearchQuery)
final leadSearchQueryProvider = LeadSearchQueryProvider._();

final class LeadSearchQueryProvider
    extends $NotifierProvider<LeadSearchQuery, String> {
  LeadSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leadSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leadSearchQueryHash();

  @$internal
  @override
  LeadSearchQuery create() => LeadSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$leadSearchQueryHash() => r'18e49c089491dd3336367ab30c64ede66f3cba85';

abstract class _$LeadSearchQuery extends $Notifier<String> {
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

@ProviderFor(LeadFilters)
final leadFiltersProvider = LeadFiltersProvider._();

final class LeadFiltersProvider
    extends $NotifierProvider<LeadFilters, LeadFiltersState> {
  LeadFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leadFiltersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leadFiltersHash();

  @$internal
  @override
  LeadFilters create() => LeadFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LeadFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LeadFiltersState>(value),
    );
  }
}

String _$leadFiltersHash() => r'065dbdf365870bae7c992ca0591ea461f903a353';

abstract class _$LeadFilters extends $Notifier<LeadFiltersState> {
  LeadFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LeadFiltersState, LeadFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LeadFiltersState, LeadFiltersState>,
              LeadFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
