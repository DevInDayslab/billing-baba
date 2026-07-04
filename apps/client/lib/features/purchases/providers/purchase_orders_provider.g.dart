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

String _$purchaseOrdersHash() => r'62dac2a377e3dd09648641fb1b0eac6e046ee901';

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
    r'3bbe355e7564bc0301a47da4ad221909048d90cb';

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
