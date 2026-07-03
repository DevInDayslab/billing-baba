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
    extends $NotifierProvider<PurchaseReturns, List<PurchaseReturnModel>> {
  PurchaseReturnsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseReturnsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseReturnsHash();

  @$internal
  @override
  PurchaseReturns create() => PurchaseReturns();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PurchaseReturnModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PurchaseReturnModel>>(value),
    );
  }
}

String _$purchaseReturnsHash() => r'f8ec7ac26a41eca5b283ff5da36f2382597b740b';

abstract class _$PurchaseReturns extends $Notifier<List<PurchaseReturnModel>> {
  List<PurchaseReturnModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<PurchaseReturnModel>, List<PurchaseReturnModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PurchaseReturnModel>, List<PurchaseReturnModel>>,
              List<PurchaseReturnModel>,
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
    r'b3bc8506f74db822812aea852aada62704141eb8';

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

@ProviderFor(allPurchaseReturns)
final allPurchaseReturnsProvider = AllPurchaseReturnsProvider._();

final class AllPurchaseReturnsProvider
    extends
        $FunctionalProvider<
          List<PurchaseReturnModel>,
          List<PurchaseReturnModel>,
          List<PurchaseReturnModel>
        >
    with $Provider<List<PurchaseReturnModel>> {
  AllPurchaseReturnsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allPurchaseReturnsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allPurchaseReturnsHash();

  @$internal
  @override
  $ProviderElement<List<PurchaseReturnModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PurchaseReturnModel> create(Ref ref) {
    return allPurchaseReturns(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PurchaseReturnModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PurchaseReturnModel>>(value),
    );
  }
}

String _$allPurchaseReturnsHash() =>
    r'e672fe1e5a57f9a512bee037d126028a0dbfdb3b';

@ProviderFor(filteredPurchaseReturns)
final filteredPurchaseReturnsProvider = FilteredPurchaseReturnsProvider._();

final class FilteredPurchaseReturnsProvider
    extends
        $FunctionalProvider<
          List<PurchaseReturnModel>,
          List<PurchaseReturnModel>,
          List<PurchaseReturnModel>
        >
    with $Provider<List<PurchaseReturnModel>> {
  FilteredPurchaseReturnsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredPurchaseReturnsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredPurchaseReturnsHash();

  @$internal
  @override
  $ProviderElement<List<PurchaseReturnModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PurchaseReturnModel> create(Ref ref) {
    return filteredPurchaseReturns(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PurchaseReturnModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PurchaseReturnModel>>(value),
    );
  }
}

String _$filteredPurchaseReturnsHash() =>
    r'9e062ef2252d30fea871a4fa707646a2ffa4b9c3';

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
    r'7641d4274313a4c75d7497ca9fee9d0a2664f732';

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
    r'6153609be82232a27ea25347db0bef8fd297b357';
