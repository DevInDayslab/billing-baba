// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_bills_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PurchaseBillSearchQuery)
final purchaseBillSearchQueryProvider = PurchaseBillSearchQueryProvider._();

final class PurchaseBillSearchQueryProvider
    extends $NotifierProvider<PurchaseBillSearchQuery, String> {
  PurchaseBillSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseBillSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseBillSearchQueryHash();

  @$internal
  @override
  PurchaseBillSearchQuery create() => PurchaseBillSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$purchaseBillSearchQueryHash() =>
    r'2aff2e2cb5790e933cffd0ecd3c750a4df758ac9';

abstract class _$PurchaseBillSearchQuery extends $Notifier<String> {
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

@ProviderFor(PurchaseBills)
final purchaseBillsProvider = PurchaseBillsProvider._();

final class PurchaseBillsProvider
    extends $AsyncNotifierProvider<PurchaseBills, PaginatedPurchaseBills> {
  PurchaseBillsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseBillsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseBillsHash();

  @$internal
  @override
  PurchaseBills create() => PurchaseBills();
}

String _$purchaseBillsHash() => r'2d4a84356fbc1516d2d2257461b266b5ff6ee253';

abstract class _$PurchaseBills extends $AsyncNotifier<PaginatedPurchaseBills> {
  FutureOr<PaginatedPurchaseBills> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PaginatedPurchaseBills>, PaginatedPurchaseBills>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedPurchaseBills>,
                PaginatedPurchaseBills
              >,
              AsyncValue<PaginatedPurchaseBills>,
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
    r'd63e323c069a03015601b097d6b4b2068b4461f8';

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
    r'dcbd683fcfde401cb507ff01b8b92620fa70d431';

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
    r'c7f59306ab02c5e33544d6a2d14dcea075a94edf';

@ProviderFor(purchaseBillPartyOptions)
final purchaseBillPartyOptionsProvider = PurchaseBillPartyOptionsProvider._();

final class PurchaseBillPartyOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  PurchaseBillPartyOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseBillPartyOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseBillPartyOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return purchaseBillPartyOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$purchaseBillPartyOptionsHash() =>
    r'1d898e4d49ee5d2bb30a7b0c683cb3ed0edf2a7b';

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
