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

String _$purchaseReturnsHash() => r'eca0ac5ba55fcb86867bd6cf1b2a3008bebd036e';

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
    r'a3978ad611835848fec58c73b47876b30bcbff31';

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
    r'de7dcd48121f0000d20a564df06710a27f631100';

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
    r'ec04bc6405a6ce76deb3dda26abecc2c58c02dcf';

@ProviderFor(purchaseReturnPartyOptions)
final purchaseReturnPartyOptionsProvider =
    PurchaseReturnPartyOptionsProvider._();

final class PurchaseReturnPartyOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  PurchaseReturnPartyOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseReturnPartyOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseReturnPartyOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return purchaseReturnPartyOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$purchaseReturnPartyOptionsHash() =>
    r'0d4bca43f8d22e48cb3623a8cc612e7a86396f9d';

@ProviderFor(purchaseReturnCategoryOptions)
final purchaseReturnCategoryOptionsProvider =
    PurchaseReturnCategoryOptionsProvider._();

final class PurchaseReturnCategoryOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  PurchaseReturnCategoryOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseReturnCategoryOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseReturnCategoryOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return purchaseReturnCategoryOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$purchaseReturnCategoryOptionsHash() =>
    r'9a44373b922eaf64d2f5157f421ef638cb0efa03';

@ProviderFor(purchaseReturnTypeOptions)
final purchaseReturnTypeOptionsProvider = PurchaseReturnTypeOptionsProvider._();

final class PurchaseReturnTypeOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  PurchaseReturnTypeOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseReturnTypeOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseReturnTypeOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return purchaseReturnTypeOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$purchaseReturnTypeOptionsHash() =>
    r'3e34edc563cff96d540c44ee01f7edf695ae5480';

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
