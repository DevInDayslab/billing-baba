// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_return_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleReturns)
final saleReturnsProvider = SaleReturnsProvider._();

final class SaleReturnsProvider
    extends $AsyncNotifierProvider<SaleReturns, PaginatedSaleInvoices> {
  SaleReturnsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleReturnsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleReturnsHash();

  @$internal
  @override
  SaleReturns create() => SaleReturns();
}

String _$saleReturnsHash() => r'819a0fc62d97be4cb2e5bd6dd9675103ce0cd00c';

abstract class _$SaleReturns extends $AsyncNotifier<PaginatedSaleInvoices> {
  FutureOr<PaginatedSaleInvoices> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PaginatedSaleInvoices>, PaginatedSaleInvoices>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedSaleInvoices>,
                PaginatedSaleInvoices
              >,
              AsyncValue<PaginatedSaleInvoices>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SaleReturnFilters)
final saleReturnFiltersProvider = SaleReturnFiltersProvider._();

final class SaleReturnFiltersProvider
    extends $NotifierProvider<SaleReturnFilters, SaleReturnFiltersState> {
  SaleReturnFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleReturnFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleReturnFiltersHash();

  @$internal
  @override
  SaleReturnFilters create() => SaleReturnFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleReturnFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleReturnFiltersState>(value),
    );
  }
}

String _$saleReturnFiltersHash() => r'971e3f5529109a5a0d2d9eb80ff2f16af567aeed';

abstract class _$SaleReturnFilters extends $Notifier<SaleReturnFiltersState> {
  SaleReturnFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<SaleReturnFiltersState, SaleReturnFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleReturnFiltersState, SaleReturnFiltersState>,
              SaleReturnFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(paginatedSaleReturns)
final paginatedSaleReturnsProvider = PaginatedSaleReturnsProvider._();

final class PaginatedSaleReturnsProvider
    extends
        $FunctionalProvider<
          PaginatedSaleInvoices,
          PaginatedSaleInvoices,
          PaginatedSaleInvoices
        >
    with $Provider<PaginatedSaleInvoices> {
  PaginatedSaleReturnsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedSaleReturnsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedSaleReturnsHash();

  @$internal
  @override
  $ProviderElement<PaginatedSaleInvoices> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedSaleInvoices create(Ref ref) {
    return paginatedSaleReturns(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedSaleInvoices value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedSaleInvoices>(value),
    );
  }
}

String _$paginatedSaleReturnsHash() =>
    r'012402879865f2bd5caf6614e3c1f67e3cb65cbf';

@ProviderFor(saleReturnSummary)
final saleReturnSummaryProvider = SaleReturnSummaryProvider._();

final class SaleReturnSummaryProvider
    extends
        $FunctionalProvider<
          SaleReturnSummaryData,
          SaleReturnSummaryData,
          SaleReturnSummaryData
        >
    with $Provider<SaleReturnSummaryData> {
  SaleReturnSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleReturnSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleReturnSummaryHash();

  @$internal
  @override
  $ProviderElement<SaleReturnSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaleReturnSummaryData create(Ref ref) {
    return saleReturnSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleReturnSummaryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleReturnSummaryData>(value),
    );
  }
}

String _$saleReturnSummaryHash() => r'56bca3a4d79e78c4bf19fa8962de787c49c50fc1';

@ProviderFor(saleReturnRefresh)
final saleReturnRefreshProvider = SaleReturnRefreshProvider._();

final class SaleReturnRefreshProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  SaleReturnRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleReturnRefreshProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleReturnRefreshHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return saleReturnRefresh(ref);
  }
}

String _$saleReturnRefreshHash() => r'471fe4190fb970cf072b7bcbd1392a4a01015540';

@ProviderFor(deleteSaleReturnDraft)
final deleteSaleReturnDraftProvider = DeleteSaleReturnDraftFamily._();

final class DeleteSaleReturnDraftProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  DeleteSaleReturnDraftProvider._({
    required DeleteSaleReturnDraftFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deleteSaleReturnDraftProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteSaleReturnDraftHash();

  @override
  String toString() {
    return r'deleteSaleReturnDraftProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return deleteSaleReturnDraft(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteSaleReturnDraftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteSaleReturnDraftHash() =>
    r'2d7f9647a02e61abefd32b63ef8576538e81602b';

final class DeleteSaleReturnDraftFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  DeleteSaleReturnDraftFamily._()
    : super(
        retry: null,
        name: r'deleteSaleReturnDraftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteSaleReturnDraftProvider call(String documentId) =>
      DeleteSaleReturnDraftProvider._(argument: documentId, from: this);

  @override
  String toString() => r'deleteSaleReturnDraftProvider';
}

@ProviderFor(finalizeSaleReturn)
final finalizeSaleReturnProvider = FinalizeSaleReturnFamily._();

final class FinalizeSaleReturnProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  FinalizeSaleReturnProvider._({
    required FinalizeSaleReturnFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'finalizeSaleReturnProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$finalizeSaleReturnHash();

  @override
  String toString() {
    return r'finalizeSaleReturnProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return finalizeSaleReturn(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FinalizeSaleReturnProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$finalizeSaleReturnHash() =>
    r'ec9a5b9ed85b9e4b8851b71d35c13c1e3d657234';

final class FinalizeSaleReturnFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  FinalizeSaleReturnFamily._()
    : super(
        retry: null,
        name: r'finalizeSaleReturnProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FinalizeSaleReturnProvider call(String documentId) =>
      FinalizeSaleReturnProvider._(argument: documentId, from: this);

  @override
  String toString() => r'finalizeSaleReturnProvider';
}
