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
    extends $AsyncNotifierProvider<PurchaseOrders, PaginatedPurchaseOrders> {
  PurchaseOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseOrdersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseOrdersHash();

  @$internal
  @override
  PurchaseOrders create() => PurchaseOrders();
}

String _$purchaseOrdersHash() => r'f443313f058f8e80bf672ccc6c9740b1d0e4cfc7';

abstract class _$PurchaseOrders
    extends $AsyncNotifier<PaginatedPurchaseOrders> {
  FutureOr<PaginatedPurchaseOrders> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedPurchaseOrders>,
              PaginatedPurchaseOrders
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedPurchaseOrders>,
                PaginatedPurchaseOrders
              >,
              AsyncValue<PaginatedPurchaseOrders>,
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
    r'414840405a41fa6a4d62116f7c6675be705a4e6d';

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
    r'978d00624315a4c57b84e637124ff9ebf8d8764e';

@ProviderFor(purchaseOrderSummary)
final purchaseOrderSummaryProvider = PurchaseOrderSummaryProvider._();

final class PurchaseOrderSummaryProvider
    extends
        $FunctionalProvider<
          PurchaseOrderSummaryData,
          PurchaseOrderSummaryData,
          PurchaseOrderSummaryData
        >
    with $Provider<PurchaseOrderSummaryData> {
  PurchaseOrderSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseOrderSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseOrderSummaryHash();

  @$internal
  @override
  $ProviderElement<PurchaseOrderSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PurchaseOrderSummaryData create(Ref ref) {
    return purchaseOrderSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseOrderSummaryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseOrderSummaryData>(value),
    );
  }
}

String _$purchaseOrderSummaryHash() =>
    r'25b5ec192d3308fb7abab79ac64e873af11e5ef7';
