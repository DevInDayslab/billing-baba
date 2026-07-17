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

String _$purchaseOrdersHash() => r'3c223a86981f98063f3a040d1fde8d1270494968';

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
    r'62d7ca6a666c91bd3bab0e27ac360690724c3a7c';

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
    r'ed801ab221d40315afccbce3c488f60d7bd50bd1';

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
    r'add996ef8dd88694a907a281bb2e7338eaa0c907';

@ProviderFor(purchaseOrderPartyOptions)
final purchaseOrderPartyOptionsProvider = PurchaseOrderPartyOptionsProvider._();

final class PurchaseOrderPartyOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  PurchaseOrderPartyOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseOrderPartyOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseOrderPartyOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return purchaseOrderPartyOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$purchaseOrderPartyOptionsHash() =>
    r'efafbd9e8666596e1b5a842ff7f3f9691fff0c15';

@ProviderFor(purchaseOrderTypeOptions)
final purchaseOrderTypeOptionsProvider = PurchaseOrderTypeOptionsProvider._();

final class PurchaseOrderTypeOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  PurchaseOrderTypeOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseOrderTypeOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseOrderTypeOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return purchaseOrderTypeOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$purchaseOrderTypeOptionsHash() =>
    r'f004266f9340249c930824a3a85599c73ed5fe5c';

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
    r'4bc3aad7ea04636aa26dec7f1d9a55c785c1727d';
