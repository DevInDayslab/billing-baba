// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_fa_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PurchaseFaRecords)
final purchaseFaRecordsProvider = PurchaseFaRecordsProvider._();

final class PurchaseFaRecordsProvider
    extends $NotifierProvider<PurchaseFaRecords, List<PurchaseFaModel>> {
  PurchaseFaRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseFaRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseFaRecordsHash();

  @$internal
  @override
  PurchaseFaRecords create() => PurchaseFaRecords();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PurchaseFaModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PurchaseFaModel>>(value),
    );
  }
}

String _$purchaseFaRecordsHash() => r'f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0';

abstract class _$PurchaseFaRecords extends $Notifier<List<PurchaseFaModel>> {
  List<PurchaseFaModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<PurchaseFaModel>, List<PurchaseFaModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PurchaseFaModel>, List<PurchaseFaModel>>,
              List<PurchaseFaModel>,
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

String _$purchaseFaFiltersHash() =>
    r'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0';

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
final filteredPurchaseFaRecordsProvider =
    FilteredPurchaseFaRecordsProvider._();

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
    r'b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1';

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
    r'c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2';
