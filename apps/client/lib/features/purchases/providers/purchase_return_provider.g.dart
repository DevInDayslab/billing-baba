// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_return_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PurchaseReturns)
final purchaseReturnsProvider = PurchaseReturnsProvider._();

final class PurchaseReturnsProvider
    extends $AsyncNotifierProvider<PurchaseReturns, PaginatedPurchaseReturns> {
  PurchaseReturnsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseReturnsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseReturnsHash();

  @$internal
  @override
  PurchaseReturns create() => PurchaseReturns();
}

String _$purchaseReturnsHash() => r'bbf2d9e5be05cc4495e736f6bdc4abf5dc1f0900';

abstract class _$PurchaseReturns
    extends $AsyncNotifier<PaginatedPurchaseReturns> {
  FutureOr<PaginatedPurchaseReturns> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedPurchaseReturns>,
              PaginatedPurchaseReturns
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedPurchaseReturns>,
                PaginatedPurchaseReturns
              >,
              AsyncValue<PaginatedPurchaseReturns>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PurchaseReturnFilters)
final purchaseReturnFiltersProvider = PurchaseReturnFiltersProvider._();

final class PurchaseReturnFiltersProvider
    extends
        $NotifierProvider<PurchaseReturnFilters, PurchaseReturnFiltersState> {
  PurchaseReturnFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseReturnFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseReturnFiltersHash();

  @$internal
  @override
  PurchaseReturnFilters create() => PurchaseReturnFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseReturnFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseReturnFiltersState>(value),
    );
  }
}

String _$purchaseReturnFiltersHash() =>
    r'aa104bf003c391e4a34814d4aefae2200d55ce86';

abstract class _$PurchaseReturnFilters
    extends $Notifier<PurchaseReturnFiltersState> {
  PurchaseReturnFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<PurchaseReturnFiltersState, PurchaseReturnFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                PurchaseReturnFiltersState,
                PurchaseReturnFiltersState
              >,
              PurchaseReturnFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(paginatedPurchaseReturns)
final paginatedPurchaseReturnsProvider = PaginatedPurchaseReturnsProvider._();

final class PaginatedPurchaseReturnsProvider
    extends
        $FunctionalProvider<
          PaginatedPurchaseReturns,
          PaginatedPurchaseReturns,
          PaginatedPurchaseReturns
        >
    with $Provider<PaginatedPurchaseReturns> {
  PaginatedPurchaseReturnsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedPurchaseReturnsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedPurchaseReturnsHash();

  @$internal
  @override
  $ProviderElement<PaginatedPurchaseReturns> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedPurchaseReturns create(Ref ref) {
    return paginatedPurchaseReturns(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedPurchaseReturns value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedPurchaseReturns>(value),
    );
  }
}

String _$paginatedPurchaseReturnsHash() =>
    r'1a75dd2c68cc65fd928925520a1b080208975166';

@ProviderFor(purchaseReturnSummary)
final purchaseReturnSummaryProvider = PurchaseReturnSummaryProvider._();

final class PurchaseReturnSummaryProvider
    extends
        $FunctionalProvider<
          PurchaseReturnSummaryData,
          PurchaseReturnSummaryData,
          PurchaseReturnSummaryData
        >
    with $Provider<PurchaseReturnSummaryData> {
  PurchaseReturnSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseReturnSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseReturnSummaryHash();

  @$internal
  @override
  $ProviderElement<PurchaseReturnSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PurchaseReturnSummaryData create(Ref ref) {
    return purchaseReturnSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseReturnSummaryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseReturnSummaryData>(value),
    );
  }
}

String _$purchaseReturnSummaryHash() =>
    r'db5ea80db6e309f7ed417cf21c666e735e7b6389';
