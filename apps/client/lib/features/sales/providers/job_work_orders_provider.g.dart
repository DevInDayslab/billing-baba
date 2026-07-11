// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_work_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
