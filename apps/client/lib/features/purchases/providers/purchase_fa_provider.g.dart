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
        isAutoDispose: true,
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
    r'21db573d4df21078e544ba09e484a1fa0cd02715';

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

String _$purchaseFaHash() => r'ca9f078072664dacf224b89ae5e3ce78b10d114a';

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

String _$purchaseFaFiltersHash() => r'80a898e9e20370e47f5d9ba893bb573506734451';

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
    r'1ef19aff6dc55a0dba456a128b1bdb54d5b904b6';

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

String _$purchaseFaSummaryHash() => r'c6da5118a3a812fab7f7b3d80648d4f8fef3d3af';
