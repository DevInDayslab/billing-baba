// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Deals)
final dealsProvider = DealsProvider._();

final class DealsProvider extends $AsyncNotifierProvider<Deals, List<Deal>> {
  DealsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dealsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dealsHash();

  @$internal
  @override
  Deals create() => Deals();
}

String _$dealsHash() => r'3eb5df9e834311f6978192cb45910fc1a7ef6fba';

abstract class _$Deals extends $AsyncNotifier<List<Deal>> {
  FutureOr<List<Deal>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Deal>>, List<Deal>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Deal>>, List<Deal>>,
              AsyncValue<List<Deal>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredDealsList)
final filteredDealsListProvider = FilteredDealsListProvider._();

final class FilteredDealsListProvider
    extends $FunctionalProvider<List<Deal>, List<Deal>, List<Deal>>
    with $Provider<List<Deal>> {
  FilteredDealsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredDealsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredDealsListHash();

  @$internal
  @override
  $ProviderElement<List<Deal>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Deal> create(Ref ref) {
    return filteredDealsList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Deal> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Deal>>(value),
    );
  }
}

String _$filteredDealsListHash() => r'01985bc6811daef865e4638d98acf1185ed95bf4';

@ProviderFor(dealsByStage)
final dealsByStageProvider = DealsByStageProvider._();

final class DealsByStageProvider
    extends
        $FunctionalProvider<
          Map<DealStage, DealStageSummary>,
          Map<DealStage, DealStageSummary>,
          Map<DealStage, DealStageSummary>
        >
    with $Provider<Map<DealStage, DealStageSummary>> {
  DealsByStageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dealsByStageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dealsByStageHash();

  @$internal
  @override
  $ProviderElement<Map<DealStage, DealStageSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<DealStage, DealStageSummary> create(Ref ref) {
    return dealsByStage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<DealStage, DealStageSummary> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<DealStage, DealStageSummary>>(
        value,
      ),
    );
  }
}

String _$dealsByStageHash() => r'affa170683bb3da777476022d9076047e390e559';
