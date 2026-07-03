// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_bills_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PurchaseBills)
final purchaseBillsProvider = PurchaseBillsProvider._();

final class PurchaseBillsProvider
    extends $NotifierProvider<PurchaseBills, List<PurchaseBillModel>> {
  PurchaseBillsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseBillsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseBillsHash();

  @$internal
  @override
  PurchaseBills create() => PurchaseBills();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PurchaseBillModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PurchaseBillModel>>(value),
    );
  }
}

String _$purchaseBillsHash() => r'c05bdd71318e342c054103b8ac516a9c57dc8b76';

abstract class _$PurchaseBills extends $Notifier<List<PurchaseBillModel>> {
  List<PurchaseBillModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<PurchaseBillModel>, List<PurchaseBillModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PurchaseBillModel>, List<PurchaseBillModel>>,
              List<PurchaseBillModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PurchaseBillFilters)
final purchaseBillFiltersProvider = PurchaseBillFiltersProvider._();

final class PurchaseBillFiltersProvider
    extends $NotifierProvider<PurchaseBillFilters, PurchaseBillFiltersState> {
  PurchaseBillFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseBillFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseBillFiltersHash();

  @$internal
  @override
  PurchaseBillFilters create() => PurchaseBillFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseBillFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseBillFiltersState>(value),
    );
  }
}

String _$purchaseBillFiltersHash() =>
    r'eebf8c41dbbf6c80c0ac5d3aa890b5117ca1b1c6';

abstract class _$PurchaseBillFilters
    extends $Notifier<PurchaseBillFiltersState> {
  PurchaseBillFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<PurchaseBillFiltersState, PurchaseBillFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PurchaseBillFiltersState, PurchaseBillFiltersState>,
              PurchaseBillFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredPurchaseBills)
final filteredPurchaseBillsProvider = FilteredPurchaseBillsProvider._();

final class FilteredPurchaseBillsProvider
    extends
        $FunctionalProvider<
          List<PurchaseBillModel>,
          List<PurchaseBillModel>,
          List<PurchaseBillModel>
        >
    with $Provider<List<PurchaseBillModel>> {
  FilteredPurchaseBillsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredPurchaseBillsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredPurchaseBillsHash();

  @$internal
  @override
  $ProviderElement<List<PurchaseBillModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PurchaseBillModel> create(Ref ref) {
    return filteredPurchaseBills(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PurchaseBillModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PurchaseBillModel>>(value),
    );
  }
}

String _$filteredPurchaseBillsHash() =>
    r'0b15a30d5082b01d0c95ae6b437e0199009e63c5';

@ProviderFor(paginatedPurchaseBills)
final paginatedPurchaseBillsProvider = PaginatedPurchaseBillsProvider._();

final class PaginatedPurchaseBillsProvider
    extends
        $FunctionalProvider<
          PaginatedPurchaseBills,
          PaginatedPurchaseBills,
          PaginatedPurchaseBills
        >
    with $Provider<PaginatedPurchaseBills> {
  PaginatedPurchaseBillsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedPurchaseBillsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedPurchaseBillsHash();

  @$internal
  @override
  $ProviderElement<PaginatedPurchaseBills> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedPurchaseBills create(Ref ref) {
    return paginatedPurchaseBills(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedPurchaseBills value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedPurchaseBills>(value),
    );
  }
}

String _$paginatedPurchaseBillsHash() =>
    r'7ef6dcddd81fbc79cd03b5779f109467b44411d6';

@ProviderFor(purchaseBillSummary)
final purchaseBillSummaryProvider = PurchaseBillSummaryProvider._();

final class PurchaseBillSummaryProvider
    extends
        $FunctionalProvider<
          PurchaseBillSummaryData,
          PurchaseBillSummaryData,
          PurchaseBillSummaryData
        >
    with $Provider<PurchaseBillSummaryData> {
  PurchaseBillSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseBillSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseBillSummaryHash();

  @$internal
  @override
  $ProviderElement<PurchaseBillSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PurchaseBillSummaryData create(Ref ref) {
    return purchaseBillSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseBillSummaryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseBillSummaryData>(value),
    );
  }
}

String _$purchaseBillSummaryHash() =>
    r'f87e89e2d879886392c9631cf6ec5d67c220512c';
