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
        isAutoDispose: false,
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
    r'a88d11bec2bd8164740e368cf5c469eae2616184';

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

String _$saleInvoicesHash() => r'fd8716e5ee3f0be43f77a8a4785de79bb3995072';

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
        isAutoDispose: false,
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
    r'1ed104620744df8ce6375d44c61377ce0408ff3b';

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
    r'ca4f98acdb224f07dce152de1f59360d896e362b';
