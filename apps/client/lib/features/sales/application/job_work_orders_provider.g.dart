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
    r'10689bbfa47937f2a9682ccfb86290919326e7c9';

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

String _$jobWorkOutFiltersHash() => r'690b293ef2d99b7fe0e7d2b4e2d9eb9356e6e3c8';

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
    r'bf0b637218b1e9bd2dca9ab8622971c11d14f374';

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

String _$jobWorkOrdersListHash() => r'1034a8913493c3dbbb6a58a954050c648af862fb';

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
