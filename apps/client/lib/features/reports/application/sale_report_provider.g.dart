// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleReportFilters)
final saleReportFiltersProvider = SaleReportFiltersProvider._();

final class SaleReportFiltersProvider
    extends $NotifierProvider<SaleReportFilters, SaleReportFiltersState> {
  SaleReportFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleReportFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleReportFiltersHash();

  @$internal
  @override
  SaleReportFilters create() => SaleReportFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleReportFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleReportFiltersState>(value),
    );
  }
}

String _$saleReportFiltersHash() => r'f0afbdbac333515f0527be482404f9103f441c13';

abstract class _$SaleReportFilters extends $Notifier<SaleReportFiltersState> {
  SaleReportFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<SaleReportFiltersState, SaleReportFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleReportFiltersState, SaleReportFiltersState>,
              SaleReportFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(saleReportFirmOptions)
final saleReportFirmOptionsProvider = SaleReportFirmOptionsProvider._();

final class SaleReportFirmOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  SaleReportFirmOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleReportFirmOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleReportFirmOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return saleReportFirmOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$saleReportFirmOptionsHash() =>
    r'e0c05ffd4b7c06d50c50d27306ae451531fe8740';

@ProviderFor(filteredSaleReportInvoices)
final filteredSaleReportInvoicesProvider =
    FilteredSaleReportInvoicesProvider._();

final class FilteredSaleReportInvoicesProvider
    extends
        $FunctionalProvider<
          List<SaleInvoiceModel>,
          List<SaleInvoiceModel>,
          List<SaleInvoiceModel>
        >
    with $Provider<List<SaleInvoiceModel>> {
  FilteredSaleReportInvoicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredSaleReportInvoicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredSaleReportInvoicesHash();

  @$internal
  @override
  $ProviderElement<List<SaleInvoiceModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SaleInvoiceModel> create(Ref ref) {
    return filteredSaleReportInvoices(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SaleInvoiceModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SaleInvoiceModel>>(value),
    );
  }
}

String _$filteredSaleReportInvoicesHash() =>
    r'eeec89141d6c38f4afaab8e2d4f4069cfb30f337';

@ProviderFor(paginatedSaleReportInvoices)
final paginatedSaleReportInvoicesProvider =
    PaginatedSaleReportInvoicesProvider._();

final class PaginatedSaleReportInvoicesProvider
    extends
        $FunctionalProvider<
          PaginatedSaleInvoices,
          PaginatedSaleInvoices,
          PaginatedSaleInvoices
        >
    with $Provider<PaginatedSaleInvoices> {
  PaginatedSaleReportInvoicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedSaleReportInvoicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedSaleReportInvoicesHash();

  @$internal
  @override
  $ProviderElement<PaginatedSaleInvoices> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedSaleInvoices create(Ref ref) {
    return paginatedSaleReportInvoices(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedSaleInvoices value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedSaleInvoices>(value),
    );
  }
}

String _$paginatedSaleReportInvoicesHash() =>
    r'7bcb105cf8e2228b6660bc218355e1ce89dc2860';

@ProviderFor(saleReportSummary)
final saleReportSummaryProvider = SaleReportSummaryProvider._();

final class SaleReportSummaryProvider
    extends
        $FunctionalProvider<
          SaleInvoiceSummaryData,
          SaleInvoiceSummaryData,
          SaleInvoiceSummaryData
        >
    with $Provider<SaleInvoiceSummaryData> {
  SaleReportSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleReportSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleReportSummaryHash();

  @$internal
  @override
  $ProviderElement<SaleInvoiceSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaleInvoiceSummaryData create(Ref ref) {
    return saleReportSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleInvoiceSummaryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleInvoiceSummaryData>(value),
    );
  }
}

String _$saleReportSummaryHash() => r'2f90db0b778b1f7efa93556614708bee1fd87975';
