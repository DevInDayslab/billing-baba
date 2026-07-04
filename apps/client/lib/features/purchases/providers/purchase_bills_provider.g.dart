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
        isAutoDispose: true,
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
    r'64d6558cd9224b118dfb5aacfa00e96af9791083';

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

String _$purchaseBillsHash() => r'b830c9950f7d7b781307f8a6cf651e1f781f8648';

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
    r'fc5b6d4dde51ef6d473515d01560f47ca318505b';

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
    r'446aaf3db4fee10ddc49a849113d8049657b6f5b';

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
    r'70693f45ba610989f6f6192eff5aba39056b0bae';
