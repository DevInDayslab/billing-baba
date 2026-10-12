// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_items_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PosItemSearchQuery)
final posItemSearchQueryProvider = PosItemSearchQueryProvider._();

final class PosItemSearchQueryProvider
    extends $NotifierProvider<PosItemSearchQuery, String> {
  PosItemSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posItemSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posItemSearchQueryHash();

  @$internal
  @override
  PosItemSearchQuery create() => PosItemSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$posItemSearchQueryHash() =>
    r'd606d67b9cae77931e8a087041b09e2e5425a913';

abstract class _$PosItemSearchQuery extends $Notifier<String> {
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

/// POS catalog derived from the shared inventory cache (single source of truth).

@ProviderFor(posCatalog)
final posCatalogProvider = PosCatalogProvider._();

/// POS catalog derived from the shared inventory cache (single source of truth).

final class PosCatalogProvider
    extends $FunctionalProvider<List<PosItem>, List<PosItem>, List<PosItem>>
    with $Provider<List<PosItem>> {
  /// POS catalog derived from the shared inventory cache (single source of truth).
  PosCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posCatalogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posCatalogHash();

  @$internal
  @override
  $ProviderElement<List<PosItem>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<PosItem> create(Ref ref) {
    return posCatalog(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PosItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PosItem>>(value),
    );
  }
}

String _$posCatalogHash() => r'75d2db014029063d33f6f99ba3ab9f1f6d105cb4';

/// Inventory categories that currently have at least one POS product.

@ProviderFor(posCategories)
final posCategoriesProvider = PosCategoriesProvider._();

/// Inventory categories that currently have at least one POS product.

final class PosCategoriesProvider
    extends
        $FunctionalProvider<
          List<PosCategoryOption>,
          List<PosCategoryOption>,
          List<PosCategoryOption>
        >
    with $Provider<List<PosCategoryOption>> {
  /// Inventory categories that currently have at least one POS product.
  PosCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posCategoriesHash();

  @$internal
  @override
  $ProviderElement<List<PosCategoryOption>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PosCategoryOption> create(Ref ref) {
    return posCategories(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PosCategoryOption> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PosCategoryOption>>(value),
    );
  }
}

String _$posCategoriesHash() => r'147096d766b8c2a6d4f69b09f34c981cd98e64a1';

/// Filtered POS catalog using inventory search (name, barcode/SKU, HSN).

@ProviderFor(posFilteredCatalog)
final posFilteredCatalogProvider = PosFilteredCatalogFamily._();

/// Filtered POS catalog using inventory search (name, barcode/SKU, HSN).

final class PosFilteredCatalogProvider
    extends $FunctionalProvider<List<PosItem>, List<PosItem>, List<PosItem>>
    with $Provider<List<PosItem>> {
  /// Filtered POS catalog using inventory search (name, barcode/SKU, HSN).
  PosFilteredCatalogProvider._({
    required PosFilteredCatalogFamily super.from,
    required ({String searchQuery, String? categoryId, bool inStockOnly})
    super.argument,
  }) : super(
         retry: null,
         name: r'posFilteredCatalogProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$posFilteredCatalogHash();

  @override
  String toString() {
    return r'posFilteredCatalogProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<PosItem>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<PosItem> create(Ref ref) {
    final argument =
        this.argument
            as ({String searchQuery, String? categoryId, bool inStockOnly});
    return posFilteredCatalog(
      ref,
      searchQuery: argument.searchQuery,
      categoryId: argument.categoryId,
      inStockOnly: argument.inStockOnly,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PosItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PosItem>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PosFilteredCatalogProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$posFilteredCatalogHash() =>
    r'41adc801ab79d7d473d1bd5009777d215450486b';

/// Filtered POS catalog using inventory search (name, barcode/SKU, HSN).

final class PosFilteredCatalogFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<PosItem>,
          ({String searchQuery, String? categoryId, bool inStockOnly})
        > {
  PosFilteredCatalogFamily._()
    : super(
        retry: null,
        name: r'posFilteredCatalogProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Filtered POS catalog using inventory search (name, barcode/SKU, HSN).

  PosFilteredCatalogProvider call({
    required String searchQuery,
    String? categoryId,
    bool inStockOnly = false,
  }) => PosFilteredCatalogProvider._(
    argument: (
      searchQuery: searchQuery,
      categoryId: categoryId,
      inStockOnly: inStockOnly,
    ),
    from: this,
  );

  @override
  String toString() => r'posFilteredCatalogProvider';
}

@ProviderFor(posCustomerSearch)
final posCustomerSearchProvider = PosCustomerSearchFamily._();

final class PosCustomerSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PosCustomer>>,
          List<PosCustomer>,
          FutureOr<List<PosCustomer>>
        >
    with
        $FutureModifier<List<PosCustomer>>,
        $FutureProvider<List<PosCustomer>> {
  PosCustomerSearchProvider._({
    required PosCustomerSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'posCustomerSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$posCustomerSearchHash();

  @override
  String toString() {
    return r'posCustomerSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PosCustomer>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PosCustomer>> create(Ref ref) {
    final argument = this.argument as String;
    return posCustomerSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PosCustomerSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$posCustomerSearchHash() => r'a852f05e16c160c872fa5d182adb2306ba0d4b09';

final class PosCustomerSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PosCustomer>>, String> {
  PosCustomerSearchFamily._()
    : super(
        retry: null,
        name: r'posCustomerSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PosCustomerSearchProvider call(String query) =>
      PosCustomerSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'posCustomerSearchProvider';
}
