// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_invoices_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleInvoiceSearchQuery)
final saleInvoiceSearchQueryProvider = SaleInvoiceSearchQueryProvider._();

final class SaleInvoiceSearchQueryProvider
    extends $NotifierProvider<SaleInvoiceSearchQuery, String> {
  SaleInvoiceSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleInvoiceSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleInvoiceSearchQueryHash();

  @$internal
  @override
  SaleInvoiceSearchQuery create() => SaleInvoiceSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$saleInvoiceSearchQueryHash() =>
    r'ca4ff02a32054f65615a16379a22a50515d59618';

abstract class _$SaleInvoiceSearchQuery extends $Notifier<String> {
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

@ProviderFor(SaleInvoices)
final saleInvoicesProvider = SaleInvoicesProvider._();

final class SaleInvoicesProvider
    extends $AsyncNotifierProvider<SaleInvoices, PaginatedSaleInvoices> {
  SaleInvoicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleInvoicesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleInvoicesHash();

  @$internal
  @override
  SaleInvoices create() => SaleInvoices();
}

String _$saleInvoicesHash() => r'a0acccc91fa334c5cd881f1e2e2bdda4444c8d79';

abstract class _$SaleInvoices extends $AsyncNotifier<PaginatedSaleInvoices> {
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

@ProviderFor(SaleInvoiceFilters)
final saleInvoiceFiltersProvider = SaleInvoiceFiltersProvider._();

final class SaleInvoiceFiltersProvider
    extends $NotifierProvider<SaleInvoiceFilters, SaleInvoiceFiltersState> {
  SaleInvoiceFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleInvoiceFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleInvoiceFiltersHash();

  @$internal
  @override
  SaleInvoiceFilters create() => SaleInvoiceFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleInvoiceFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleInvoiceFiltersState>(value),
    );
  }
}

String _$saleInvoiceFiltersHash() =>
    r'9e9f06887527924ae2cb21ce771c548821a9a317';

abstract class _$SaleInvoiceFilters extends $Notifier<SaleInvoiceFiltersState> {
  SaleInvoiceFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<SaleInvoiceFiltersState, SaleInvoiceFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleInvoiceFiltersState, SaleInvoiceFiltersState>,
              SaleInvoiceFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(paginatedSaleInvoices)
final paginatedSaleInvoicesProvider = PaginatedSaleInvoicesProvider._();

final class PaginatedSaleInvoicesProvider
    extends
        $FunctionalProvider<
          PaginatedSaleInvoices,
          PaginatedSaleInvoices,
          PaginatedSaleInvoices
        >
    with $Provider<PaginatedSaleInvoices> {
  PaginatedSaleInvoicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedSaleInvoicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedSaleInvoicesHash();

  @$internal
  @override
  $ProviderElement<PaginatedSaleInvoices> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedSaleInvoices create(Ref ref) {
    return paginatedSaleInvoices(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedSaleInvoices value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedSaleInvoices>(value),
    );
  }
}

String _$paginatedSaleInvoicesHash() =>
    r'7fddab20340e09bf021534d5be2f4f999d39ca25';

@ProviderFor(saleInvoiceSummary)
final saleInvoiceSummaryProvider = SaleInvoiceSummaryProvider._();

final class SaleInvoiceSummaryProvider
    extends
        $FunctionalProvider<
          SaleInvoiceSummaryData,
          SaleInvoiceSummaryData,
          SaleInvoiceSummaryData
        >
    with $Provider<SaleInvoiceSummaryData> {
  SaleInvoiceSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleInvoiceSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleInvoiceSummaryHash();

  @$internal
  @override
  $ProviderElement<SaleInvoiceSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaleInvoiceSummaryData create(Ref ref) {
    return saleInvoiceSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleInvoiceSummaryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleInvoiceSummaryData>(value),
    );
  }
}

String _$saleInvoiceSummaryHash() =>
    r'9ad9169106a0e956bff1ef4682200b4307626854';
