// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_fa_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PurchaseFaSearchQuery)
final purchaseFaSearchQueryProvider = PurchaseFaSearchQueryProvider._();

final class PurchaseFaSearchQueryProvider
    extends $NotifierProvider<PurchaseFaSearchQuery, String> {
  PurchaseFaSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseFaSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseFaSearchQueryHash();

  @$internal
  @override
  PurchaseFaSearchQuery create() => PurchaseFaSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$purchaseFaSearchQueryHash() =>
    r'd44b4f0add5a1cbdd1290996e1adb40edf98c016';

abstract class _$PurchaseFaSearchQuery extends $Notifier<String> {
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

@ProviderFor(PurchaseFa)
final purchaseFaProvider = PurchaseFaProvider._();

final class PurchaseFaProvider
    extends $AsyncNotifierProvider<PurchaseFa, PaginatedPurchaseFaRecords> {
  PurchaseFaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseFaProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseFaHash();

  @$internal
  @override
  PurchaseFa create() => PurchaseFa();
}

String _$purchaseFaHash() => r'fdea263540fa0e118f9c2682718e8c43016c8b36';

abstract class _$PurchaseFa extends $AsyncNotifier<PaginatedPurchaseFaRecords> {
  FutureOr<PaginatedPurchaseFaRecords> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedPurchaseFaRecords>,
              PaginatedPurchaseFaRecords
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedPurchaseFaRecords>,
                PaginatedPurchaseFaRecords
              >,
              AsyncValue<PaginatedPurchaseFaRecords>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PurchaseFaFilters)
final purchaseFaFiltersProvider = PurchaseFaFiltersProvider._();

final class PurchaseFaFiltersProvider
    extends $NotifierProvider<PurchaseFaFilters, PurchaseFaFiltersState> {
  PurchaseFaFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseFaFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseFaFiltersHash();

  @$internal
  @override
  PurchaseFaFilters create() => PurchaseFaFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseFaFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseFaFiltersState>(value),
    );
  }
}

String _$purchaseFaFiltersHash() => r'cbf0a65252c7a343c86fa2fdc5c3633540f1b77e';

abstract class _$PurchaseFaFilters extends $Notifier<PurchaseFaFiltersState> {
  PurchaseFaFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<PurchaseFaFiltersState, PurchaseFaFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PurchaseFaFiltersState, PurchaseFaFiltersState>,
              PurchaseFaFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredPurchaseFaRecords)
final filteredPurchaseFaRecordsProvider = FilteredPurchaseFaRecordsProvider._();

final class FilteredPurchaseFaRecordsProvider
    extends
        $FunctionalProvider<
          List<PurchaseFaModel>,
          List<PurchaseFaModel>,
          List<PurchaseFaModel>
        >
    with $Provider<List<PurchaseFaModel>> {
  FilteredPurchaseFaRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredPurchaseFaRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredPurchaseFaRecordsHash();

  @$internal
  @override
  $ProviderElement<List<PurchaseFaModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PurchaseFaModel> create(Ref ref) {
    return filteredPurchaseFaRecords(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PurchaseFaModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PurchaseFaModel>>(value),
    );
  }
}

String _$filteredPurchaseFaRecordsHash() =>
    r'0842f71678278be9d6a5d1e3d7afb3f60786d556';

@ProviderFor(paginatedPurchaseFaRecords)
final paginatedPurchaseFaRecordsProvider =
    PaginatedPurchaseFaRecordsProvider._();

final class PaginatedPurchaseFaRecordsProvider
    extends
        $FunctionalProvider<
          PaginatedPurchaseFaRecords,
          PaginatedPurchaseFaRecords,
          PaginatedPurchaseFaRecords
        >
    with $Provider<PaginatedPurchaseFaRecords> {
  PaginatedPurchaseFaRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedPurchaseFaRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedPurchaseFaRecordsHash();

  @$internal
  @override
  $ProviderElement<PaginatedPurchaseFaRecords> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedPurchaseFaRecords create(Ref ref) {
    return paginatedPurchaseFaRecords(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedPurchaseFaRecords value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedPurchaseFaRecords>(value),
    );
  }
}

String _$paginatedPurchaseFaRecordsHash() =>
    r'eaf2421168f3a152471c695c47fea60912e6cc0c';

@ProviderFor(purchaseFaPartyOptions)
final purchaseFaPartyOptionsProvider = PurchaseFaPartyOptionsProvider._();

final class PurchaseFaPartyOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  PurchaseFaPartyOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseFaPartyOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseFaPartyOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return purchaseFaPartyOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$purchaseFaPartyOptionsHash() =>
    r'48483168095a1db4fad2dccf8859751846f49035';

@ProviderFor(purchaseFaSummary)
final purchaseFaSummaryProvider = PurchaseFaSummaryProvider._();

final class PurchaseFaSummaryProvider
    extends
        $FunctionalProvider<
          PurchaseFaSummaryData,
          PurchaseFaSummaryData,
          PurchaseFaSummaryData
        >
    with $Provider<PurchaseFaSummaryData> {
  PurchaseFaSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseFaSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseFaSummaryHash();

  @$internal
  @override
  $ProviderElement<PurchaseFaSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PurchaseFaSummaryData create(Ref ref) {
    return purchaseFaSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseFaSummaryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseFaSummaryData>(value),
    );
  }
}

String _$purchaseFaSummaryHash() => r'08f1a9159fdb01cb673515cf20126f56ea311261';
