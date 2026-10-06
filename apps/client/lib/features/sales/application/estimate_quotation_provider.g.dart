// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estimate_quotation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(estimateFirmFilterOptions)
final estimateFirmFilterOptionsProvider = EstimateFirmFilterOptionsProvider._();

final class EstimateFirmFilterOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  EstimateFirmFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'estimateFirmFilterOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$estimateFirmFilterOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return estimateFirmFilterOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$estimateFirmFilterOptionsHash() =>
    r'351214f6a6fd56424c50f9f2096de5a8fba27186';

@ProviderFor(estimateUserFilterOptions)
final estimateUserFilterOptionsProvider = EstimateUserFilterOptionsProvider._();

final class EstimateUserFilterOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  EstimateUserFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'estimateUserFilterOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$estimateUserFilterOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return estimateUserFilterOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$estimateUserFilterOptionsHash() =>
    r'8346e849529a73d98ef547a4932b625190e24f84';

@ProviderFor(estimateGodownFilterOptions)
final estimateGodownFilterOptionsProvider =
    EstimateGodownFilterOptionsProvider._();

final class EstimateGodownFilterOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  EstimateGodownFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'estimateGodownFilterOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$estimateGodownFilterOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return estimateGodownFilterOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$estimateGodownFilterOptionsHash() =>
    r'fdc15d011665b7545a95f9c62a28a145adc99a75';

@ProviderFor(EstimateQuotationSearchQuery)
final estimateQuotationSearchQueryProvider =
    EstimateQuotationSearchQueryProvider._();

final class EstimateQuotationSearchQueryProvider
    extends $NotifierProvider<EstimateQuotationSearchQuery, String> {
  EstimateQuotationSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'estimateQuotationSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$estimateQuotationSearchQueryHash();

  @$internal
  @override
  EstimateQuotationSearchQuery create() => EstimateQuotationSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$estimateQuotationSearchQueryHash() =>
    r'af414ac8f976bb634f3674ebbb85f09f97b91dab';

abstract class _$EstimateQuotationSearchQuery extends $Notifier<String> {
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

@ProviderFor(SelectedEstimateQuotationId)
final selectedEstimateQuotationIdProvider =
    SelectedEstimateQuotationIdProvider._();

final class SelectedEstimateQuotationIdProvider
    extends $NotifierProvider<SelectedEstimateQuotationId, String?> {
  SelectedEstimateQuotationIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedEstimateQuotationIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedEstimateQuotationIdHash();

  @$internal
  @override
  SelectedEstimateQuotationId create() => SelectedEstimateQuotationId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedEstimateQuotationIdHash() =>
    r'd282d7b993444420e709d7039a680ba966b6077e';

abstract class _$SelectedEstimateQuotationId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(EstimateQuotations)
final estimateQuotationsProvider = EstimateQuotationsProvider._();

final class EstimateQuotationsProvider
    extends $AsyncNotifierProvider<EstimateQuotations, PaginatedSaleInvoices> {
  EstimateQuotationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'estimateQuotationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$estimateQuotationsHash();

  @$internal
  @override
  EstimateQuotations create() => EstimateQuotations();
}

String _$estimateQuotationsHash() =>
    r'af70eaf412f7e93c5c9acb8876f6ea37f59f7c13';

abstract class _$EstimateQuotations
    extends $AsyncNotifier<PaginatedSaleInvoices> {
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

@ProviderFor(EstimateQuotationFilters)
final estimateQuotationFiltersProvider = EstimateQuotationFiltersProvider._();

final class EstimateQuotationFiltersProvider
    extends
        $NotifierProvider<
          EstimateQuotationFilters,
          EstimateQuotationFiltersState
        > {
  EstimateQuotationFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'estimateQuotationFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$estimateQuotationFiltersHash();

  @$internal
  @override
  EstimateQuotationFilters create() => EstimateQuotationFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EstimateQuotationFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EstimateQuotationFiltersState>(
        value,
      ),
    );
  }
}

String _$estimateQuotationFiltersHash() =>
    r'8db462db61baa5234f74fde32bf5a79d33ed66a5';

abstract class _$EstimateQuotationFilters
    extends $Notifier<EstimateQuotationFiltersState> {
  EstimateQuotationFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              EstimateQuotationFiltersState,
              EstimateQuotationFiltersState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                EstimateQuotationFiltersState,
                EstimateQuotationFiltersState
              >,
              EstimateQuotationFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredEstimateQuotations)
final filteredEstimateQuotationsProvider =
    FilteredEstimateQuotationsProvider._();

final class FilteredEstimateQuotationsProvider
    extends
        $FunctionalProvider<
          List<SaleInvoiceModel>,
          List<SaleInvoiceModel>,
          List<SaleInvoiceModel>
        >
    with $Provider<List<SaleInvoiceModel>> {
  FilteredEstimateQuotationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredEstimateQuotationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredEstimateQuotationsHash();

  @$internal
  @override
  $ProviderElement<List<SaleInvoiceModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SaleInvoiceModel> create(Ref ref) {
    return filteredEstimateQuotations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SaleInvoiceModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SaleInvoiceModel>>(value),
    );
  }
}

String _$filteredEstimateQuotationsHash() =>
    r'45545422d798813db1896f13767980d9cde02c3e';

@ProviderFor(paginatedEstimateQuotations)
final paginatedEstimateQuotationsProvider =
    PaginatedEstimateQuotationsProvider._();

final class PaginatedEstimateQuotationsProvider
    extends
        $FunctionalProvider<
          PaginatedSaleInvoices,
          PaginatedSaleInvoices,
          PaginatedSaleInvoices
        >
    with $Provider<PaginatedSaleInvoices> {
  PaginatedEstimateQuotationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedEstimateQuotationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedEstimateQuotationsHash();

  @$internal
  @override
  $ProviderElement<PaginatedSaleInvoices> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedSaleInvoices create(Ref ref) {
    return paginatedEstimateQuotations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedSaleInvoices value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedSaleInvoices>(value),
    );
  }
}

String _$paginatedEstimateQuotationsHash() =>
    r'5b99e0caba89aa739fe7ed57e4cb593810b2eeed';

@ProviderFor(estimateQuotationSummary)
final estimateQuotationSummaryProvider = EstimateQuotationSummaryProvider._();

final class EstimateQuotationSummaryProvider
    extends
        $FunctionalProvider<
          EstimateQuotationSummaryData,
          EstimateQuotationSummaryData,
          EstimateQuotationSummaryData
        >
    with $Provider<EstimateQuotationSummaryData> {
  EstimateQuotationSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'estimateQuotationSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$estimateQuotationSummaryHash();

  @$internal
  @override
  $ProviderElement<EstimateQuotationSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EstimateQuotationSummaryData create(Ref ref) {
    return estimateQuotationSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EstimateQuotationSummaryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EstimateQuotationSummaryData>(value),
    );
  }
}

String _$estimateQuotationSummaryHash() =>
    r'da50adcf1c7b51edd83743b368072edd8b303483';
