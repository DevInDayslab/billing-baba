// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(saleOrderFirmFilterOptions)
final saleOrderFirmFilterOptionsProvider =
    SaleOrderFirmFilterOptionsProvider._();

final class SaleOrderFirmFilterOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  SaleOrderFirmFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleOrderFirmFilterOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleOrderFirmFilterOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return saleOrderFirmFilterOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$saleOrderFirmFilterOptionsHash() =>
    r'41b2801832e201ba954b9a7906d509339626a925';

@ProviderFor(saleOrderUserFilterOptions)
final saleOrderUserFilterOptionsProvider =
    SaleOrderUserFilterOptionsProvider._();

final class SaleOrderUserFilterOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  SaleOrderUserFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleOrderUserFilterOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleOrderUserFilterOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return saleOrderUserFilterOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$saleOrderUserFilterOptionsHash() =>
    r'a9034a7d61feedf307f88d545d13a2da778b76fc';

@ProviderFor(saleOrderGodownFilterOptions)
final saleOrderGodownFilterOptionsProvider =
    SaleOrderGodownFilterOptionsProvider._();

final class SaleOrderGodownFilterOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  SaleOrderGodownFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleOrderGodownFilterOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleOrderGodownFilterOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return saleOrderGodownFilterOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$saleOrderGodownFilterOptionsHash() =>
    r'fc2264eaec7c090e27b4d75bbcb8f70d5d948bfb';

@ProviderFor(SaleOrderSearchQuery)
final saleOrderSearchQueryProvider = SaleOrderSearchQueryProvider._();

final class SaleOrderSearchQueryProvider
    extends $NotifierProvider<SaleOrderSearchQuery, String> {
  SaleOrderSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleOrderSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleOrderSearchQueryHash();

  @$internal
  @override
  SaleOrderSearchQuery create() => SaleOrderSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$saleOrderSearchQueryHash() =>
    r'b9e129d08505a8f226820e5d72f2e63a1c791664';

abstract class _$SaleOrderSearchQuery extends $Notifier<String> {
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

@ProviderFor(SelectedSaleOrderId)
final selectedSaleOrderIdProvider = SelectedSaleOrderIdProvider._();

final class SelectedSaleOrderIdProvider
    extends $NotifierProvider<SelectedSaleOrderId, String?> {
  SelectedSaleOrderIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedSaleOrderIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedSaleOrderIdHash();

  @$internal
  @override
  SelectedSaleOrderId create() => SelectedSaleOrderId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedSaleOrderIdHash() =>
    r'6911be97fa25774ebabf7f1b01f78272ef6c548e';

abstract class _$SelectedSaleOrderId extends $Notifier<String?> {
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

@ProviderFor(BulkSelectedSaleOrderIds)
final bulkSelectedSaleOrderIdsProvider = BulkSelectedSaleOrderIdsProvider._();

final class BulkSelectedSaleOrderIdsProvider
    extends $NotifierProvider<BulkSelectedSaleOrderIds, Set<String>> {
  BulkSelectedSaleOrderIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bulkSelectedSaleOrderIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bulkSelectedSaleOrderIdsHash();

  @$internal
  @override
  BulkSelectedSaleOrderIds create() => BulkSelectedSaleOrderIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$bulkSelectedSaleOrderIdsHash() =>
    r'936d3760caf20ff201e46e89a22888498d9623e1';

abstract class _$BulkSelectedSaleOrderIds extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SaleOrders)
final saleOrdersProvider = SaleOrdersProvider._();

final class SaleOrdersProvider
    extends $AsyncNotifierProvider<SaleOrders, PaginatedSaleInvoices> {
  SaleOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleOrdersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleOrdersHash();

  @$internal
  @override
  SaleOrders create() => SaleOrders();
}

String _$saleOrdersHash() => r'bdfbada52e88ea08dfb79cd1d2115363042ae883';

abstract class _$SaleOrders extends $AsyncNotifier<PaginatedSaleInvoices> {
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

@ProviderFor(SaleOrderFilters)
final saleOrderFiltersProvider = SaleOrderFiltersProvider._();

final class SaleOrderFiltersProvider
    extends $NotifierProvider<SaleOrderFilters, SaleOrderFiltersState> {
  SaleOrderFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleOrderFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleOrderFiltersHash();

  @$internal
  @override
  SaleOrderFilters create() => SaleOrderFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleOrderFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleOrderFiltersState>(value),
    );
  }
}

String _$saleOrderFiltersHash() => r'b7bf3224767db7fef3174accebb9345ad9a11fa5';

abstract class _$SaleOrderFilters extends $Notifier<SaleOrderFiltersState> {
  SaleOrderFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SaleOrderFiltersState, SaleOrderFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleOrderFiltersState, SaleOrderFiltersState>,
              SaleOrderFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredSaleOrders)
final filteredSaleOrdersProvider = FilteredSaleOrdersProvider._();

final class FilteredSaleOrdersProvider
    extends
        $FunctionalProvider<
          List<SaleInvoiceModel>,
          List<SaleInvoiceModel>,
          List<SaleInvoiceModel>
        >
    with $Provider<List<SaleInvoiceModel>> {
  FilteredSaleOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredSaleOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredSaleOrdersHash();

  @$internal
  @override
  $ProviderElement<List<SaleInvoiceModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SaleInvoiceModel> create(Ref ref) {
    return filteredSaleOrders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SaleInvoiceModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SaleInvoiceModel>>(value),
    );
  }
}

String _$filteredSaleOrdersHash() =>
    r'121a349b6a69771f7d86af65c56ac5bd50a2333a';

@ProviderFor(paginatedSaleOrders)
final paginatedSaleOrdersProvider = PaginatedSaleOrdersProvider._();

final class PaginatedSaleOrdersProvider
    extends
        $FunctionalProvider<
          PaginatedSaleInvoices,
          PaginatedSaleInvoices,
          PaginatedSaleInvoices
        >
    with $Provider<PaginatedSaleInvoices> {
  PaginatedSaleOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedSaleOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedSaleOrdersHash();

  @$internal
  @override
  $ProviderElement<PaginatedSaleInvoices> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedSaleInvoices create(Ref ref) {
    return paginatedSaleOrders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedSaleInvoices value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedSaleInvoices>(value),
    );
  }
}

String _$paginatedSaleOrdersHash() =>
    r'd1c40f1a9481fc6e0be8a683869e5f1d5f762963';
