// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_invoices_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleInvoices)
final saleInvoicesProvider = SaleInvoicesProvider._();

final class SaleInvoicesProvider
    extends $NotifierProvider<SaleInvoices, List<SaleInvoiceModel>> {
  SaleInvoicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleInvoicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleInvoicesHash();

  @$internal
  @override
  SaleInvoices create() => SaleInvoices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SaleInvoiceModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SaleInvoiceModel>>(value),
    );
  }
}

String _$saleInvoicesHash() => r'5e4aa087b29b98ace8a12c5147b41a9bd8eef07c';

abstract class _$SaleInvoices extends $Notifier<List<SaleInvoiceModel>> {
  List<SaleInvoiceModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<SaleInvoiceModel>, List<SaleInvoiceModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SaleInvoiceModel>, List<SaleInvoiceModel>>,
              List<SaleInvoiceModel>,
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
    r'950f6aca409553eaa5d3bbc5f42d5f546cfbf679';

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

@ProviderFor(filteredSaleInvoices)
final filteredSaleInvoicesProvider = FilteredSaleInvoicesProvider._();

final class FilteredSaleInvoicesProvider
    extends
        $FunctionalProvider<
          List<SaleInvoiceModel>,
          List<SaleInvoiceModel>,
          List<SaleInvoiceModel>
        >
    with $Provider<List<SaleInvoiceModel>> {
  FilteredSaleInvoicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredSaleInvoicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredSaleInvoicesHash();

  @$internal
  @override
  $ProviderElement<List<SaleInvoiceModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SaleInvoiceModel> create(Ref ref) {
    return filteredSaleInvoices(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SaleInvoiceModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SaleInvoiceModel>>(value),
    );
  }
}

String _$filteredSaleInvoicesHash() =>
    r'ea2dddae71f8315b106ad71ba83d604c0df522d8';

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
    r'ffa09fe4ae18ba214d1f36211de7239a5b98b17f';

@ProviderFor(SaleInvoiceSummary)
final saleInvoiceSummaryProvider = SaleInvoiceSummaryProvider._();

final class SaleInvoiceSummaryProvider
    extends $NotifierProvider<SaleInvoiceSummary, SaleInvoiceSummaryData> {
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
  SaleInvoiceSummary create() => SaleInvoiceSummary();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleInvoiceSummaryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleInvoiceSummaryData>(value),
    );
  }
}

String _$saleInvoiceSummaryHash() =>
    r'b5983566e9abf93c059c11b7d7e47e2f00916052';

abstract class _$SaleInvoiceSummary extends $Notifier<SaleInvoiceSummaryData> {
  SaleInvoiceSummaryData build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<SaleInvoiceSummaryData, SaleInvoiceSummaryData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleInvoiceSummaryData, SaleInvoiceSummaryData>,
              SaleInvoiceSummaryData,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
