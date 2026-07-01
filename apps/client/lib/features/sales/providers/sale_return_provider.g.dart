// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_return_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$saleReturnFiltersHash() => r'sale_return_filters_hash';

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
          PaginatedSaleReturns,
          PaginatedSaleReturns,
          PaginatedSaleReturns
        >
    with $Provider<PaginatedSaleReturns> {
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
  $ProviderElement<PaginatedSaleReturns> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedSaleReturns create(Ref ref) {
    return paginatedSaleReturns(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedSaleReturns value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedSaleReturns>(value),
    );
  }
}

String _$paginatedSaleReturnsHash() => r'paginated_sale_returns_hash';
