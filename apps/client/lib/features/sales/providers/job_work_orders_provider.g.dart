// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_work_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(JobWorkOutSearchQuery)
final jobWorkOutSearchQueryProvider = JobWorkOutSearchQueryProvider._();

final class JobWorkOutSearchQueryProvider
    extends $NotifierProvider<JobWorkOutSearchQuery, String> {
  JobWorkOutSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jobWorkOutSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jobWorkOutSearchQueryHash();

  @$internal
  @override
  JobWorkOutSearchQuery create() => JobWorkOutSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$jobWorkOutSearchQueryHash() =>
    r'8f2a1c4d9e7b3a6f5c0d8e1b2a4f6c9d0e3b5a7f';

abstract class _$JobWorkOutSearchQuery extends $Notifier<String> {
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

@ProviderFor(JobWorkOutFilters)
final jobWorkOutFiltersProvider = JobWorkOutFiltersProvider._();

final class JobWorkOutFiltersProvider
    extends $NotifierProvider<JobWorkOutFilters, JobWorkOutFiltersState> {
  JobWorkOutFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jobWorkOutFiltersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jobWorkOutFiltersHash();

  @$internal
  @override
  JobWorkOutFilters create() => JobWorkOutFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JobWorkOutFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JobWorkOutFiltersState>(value),
    );
  }
}

String _$jobWorkOutFiltersHash() =>
    r'1a3b5c7d9e0f2a4b6c8d0e2f4a6b8c0d2e4f6a8b';

abstract class _$JobWorkOutFilters extends $Notifier<JobWorkOutFiltersState> {
  JobWorkOutFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<JobWorkOutFiltersState, JobWorkOutFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<JobWorkOutFiltersState, JobWorkOutFiltersState>,
              JobWorkOutFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredJobWorkOrders)
final filteredJobWorkOrdersProvider = FilteredJobWorkOrdersProvider._();

final class FilteredJobWorkOrdersProvider
    extends
        $FunctionalProvider<
          List<JobWorkOrderListItem>,
          List<JobWorkOrderListItem>,
          List<JobWorkOrderListItem>
        >
    with $Provider<List<JobWorkOrderListItem>> {
  FilteredJobWorkOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredJobWorkOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredJobWorkOrdersHash();

  @$internal
  @override
  $ProviderElement<List<JobWorkOrderListItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<JobWorkOrderListItem> create(Ref ref) {
    return filteredJobWorkOrders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<JobWorkOrderListItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<JobWorkOrderListItem>>(value),
    );
  }
}

String _$filteredJobWorkOrdersHash() =>
    r'2b4c6d8e0f1a3b5c7d9e1f3a5b7c9d1e3f5a7b9c';

@ProviderFor(JobWorkOrdersList)
final jobWorkOrdersListProvider = JobWorkOrdersListProvider._();

final class JobWorkOrdersListProvider
    extends $AsyncNotifierProvider<JobWorkOrdersList, PaginatedJobWorkOrders> {
  JobWorkOrdersListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jobWorkOrdersListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jobWorkOrdersListHash();

  @$internal
  @override
  JobWorkOrdersList create() => JobWorkOrdersList();
}

String _$jobWorkOrdersListHash() => r'b71be0e80e31541f4474849f4736d09cd3fbffb9';

abstract class _$JobWorkOrdersList
    extends $AsyncNotifier<PaginatedJobWorkOrders> {
  FutureOr<PaginatedJobWorkOrders> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PaginatedJobWorkOrders>, PaginatedJobWorkOrders>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedJobWorkOrders>,
                PaginatedJobWorkOrders
              >,
              AsyncValue<PaginatedJobWorkOrders>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
