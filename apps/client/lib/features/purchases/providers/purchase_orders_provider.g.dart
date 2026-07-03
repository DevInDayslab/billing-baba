// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PurchaseOrders)
final purchaseOrdersProvider = PurchaseOrdersProvider._();

final class PurchaseOrdersProvider
    extends $NotifierProvider<PurchaseOrders, List<PurchaseOrderModel>> {
  PurchaseOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseOrdersHash();

  @$internal
  @override
  PurchaseOrders create() => PurchaseOrders();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PurchaseOrderModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PurchaseOrderModel>>(value),
    );
  }
}

String _$purchaseOrdersHash() => r'4b65b4ed5fc3d02f926ffa1921f508bc9b611907';

abstract class _$PurchaseOrders extends $Notifier<List<PurchaseOrderModel>> {
  List<PurchaseOrderModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<PurchaseOrderModel>, List<PurchaseOrderModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PurchaseOrderModel>, List<PurchaseOrderModel>>,
              List<PurchaseOrderModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PurchaseOrderFilters)
final purchaseOrderFiltersProvider = PurchaseOrderFiltersProvider._();

final class PurchaseOrderFiltersProvider
    extends $NotifierProvider<PurchaseOrderFilters, PurchaseOrderFiltersState> {
  PurchaseOrderFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseOrderFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseOrderFiltersHash();

  @$internal
  @override
  PurchaseOrderFilters create() => PurchaseOrderFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseOrderFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseOrderFiltersState>(value),
    );
  }
}

String _$purchaseOrderFiltersHash() =>
    r'bfc0aa5e9f23a01110261eb0733464a60ad91d70';

abstract class _$PurchaseOrderFilters
    extends $Notifier<PurchaseOrderFiltersState> {
  PurchaseOrderFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<PurchaseOrderFiltersState, PurchaseOrderFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PurchaseOrderFiltersState, PurchaseOrderFiltersState>,
              PurchaseOrderFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredPurchaseOrders)
final filteredPurchaseOrdersProvider = FilteredPurchaseOrdersProvider._();

final class FilteredPurchaseOrdersProvider
    extends
        $FunctionalProvider<
          List<PurchaseOrderModel>,
          List<PurchaseOrderModel>,
          List<PurchaseOrderModel>
        >
    with $Provider<List<PurchaseOrderModel>> {
  FilteredPurchaseOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredPurchaseOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredPurchaseOrdersHash();

  @$internal
  @override
  $ProviderElement<List<PurchaseOrderModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PurchaseOrderModel> create(Ref ref) {
    return filteredPurchaseOrders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PurchaseOrderModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PurchaseOrderModel>>(value),
    );
  }
}

String _$filteredPurchaseOrdersHash() =>
    r'b574e65314e9e139ed9a03135ab3f797ddbf8546';

@ProviderFor(paginatedPurchaseOrders)
final paginatedPurchaseOrdersProvider = PaginatedPurchaseOrdersProvider._();

final class PaginatedPurchaseOrdersProvider
    extends
        $FunctionalProvider<
          PaginatedPurchaseOrders,
          PaginatedPurchaseOrders,
          PaginatedPurchaseOrders
        >
    with $Provider<PaginatedPurchaseOrders> {
  PaginatedPurchaseOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedPurchaseOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedPurchaseOrdersHash();

  @$internal
  @override
  $ProviderElement<PaginatedPurchaseOrders> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedPurchaseOrders create(Ref ref) {
    return paginatedPurchaseOrders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedPurchaseOrders value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedPurchaseOrders>(value),
    );
  }
}

String _$paginatedPurchaseOrdersHash() =>
    r'a99b2ae8182029492be8346ed35ac16faab28dcf';
