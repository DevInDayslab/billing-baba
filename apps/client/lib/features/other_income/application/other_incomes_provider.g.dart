// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other_incomes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IncomeCategories)
final incomeCategoriesProvider = IncomeCategoriesProvider._();

final class IncomeCategoriesProvider
    extends
        $AsyncNotifierProvider<IncomeCategories, List<IncomeCategoryModel>> {
  IncomeCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeCategoriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeCategoriesHash();

  @$internal
  @override
  IncomeCategories create() => IncomeCategories();
}

String _$incomeCategoriesHash() => r'5621c77b8ae6cd01e669557a800eb5e2f5e24de0';

abstract class _$IncomeCategories
    extends $AsyncNotifier<List<IncomeCategoryModel>> {
  FutureOr<List<IncomeCategoryModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<IncomeCategoryModel>>,
              List<IncomeCategoryModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<IncomeCategoryModel>>,
                List<IncomeCategoryModel>
              >,
              AsyncValue<List<IncomeCategoryModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(IncomeCatalogItems)
final incomeCatalogItemsProvider = IncomeCatalogItemsProvider._();

final class IncomeCatalogItemsProvider
    extends
        $AsyncNotifierProvider<
          IncomeCatalogItems,
          List<IncomeCatalogItemModel>
        > {
  IncomeCatalogItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeCatalogItemsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeCatalogItemsHash();

  @$internal
  @override
  IncomeCatalogItems create() => IncomeCatalogItems();
}

String _$incomeCatalogItemsHash() =>
    r'5423cc028d9d06b12a883b8ee8c96214dc24e1e5';

abstract class _$IncomeCatalogItems
    extends $AsyncNotifier<List<IncomeCatalogItemModel>> {
  FutureOr<List<IncomeCatalogItemModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<IncomeCatalogItemModel>>,
              List<IncomeCatalogItemModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<IncomeCatalogItemModel>>,
                List<IncomeCatalogItemModel>
              >,
              AsyncValue<List<IncomeCatalogItemModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(OtherIncomeTransactions)
final otherIncomeTransactionsProvider = OtherIncomeTransactionsProvider._();

final class OtherIncomeTransactionsProvider
    extends
        $AsyncNotifierProvider<
          OtherIncomeTransactions,
          List<OtherIncomeTransactionModel>
        > {
  OtherIncomeTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otherIncomeTransactionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otherIncomeTransactionsHash();

  @$internal
  @override
  OtherIncomeTransactions create() => OtherIncomeTransactions();
}

String _$otherIncomeTransactionsHash() =>
    r'8647de8a3e2d5528c21a3bc1ea69066bf7b3015c';

abstract class _$OtherIncomeTransactions
    extends $AsyncNotifier<List<OtherIncomeTransactionModel>> {
  FutureOr<List<OtherIncomeTransactionModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<OtherIncomeTransactionModel>>,
              List<OtherIncomeTransactionModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<OtherIncomeTransactionModel>>,
                List<OtherIncomeTransactionModel>
              >,
              AsyncValue<List<OtherIncomeTransactionModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(otherIncomesPageData)
final otherIncomesPageDataProvider = OtherIncomesPageDataProvider._();

final class OtherIncomesPageDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<OtherIncomePageData>,
          OtherIncomePageData,
          FutureOr<OtherIncomePageData>
        >
    with
        $FutureModifier<OtherIncomePageData>,
        $FutureProvider<OtherIncomePageData> {
  OtherIncomesPageDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otherIncomesPageDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otherIncomesPageDataHash();

  @$internal
  @override
  $FutureProviderElement<OtherIncomePageData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OtherIncomePageData> create(Ref ref) {
    return otherIncomesPageData(ref);
  }
}

String _$otherIncomesPageDataHash() =>
    r'79be8bcbe64ce39c405c31c33f7c4fc77b14c86b';

@ProviderFor(incomeItems)
final incomeItemsProvider = IncomeItemsProvider._();

final class IncomeItemsProvider
    extends
        $FunctionalProvider<
          List<IncomeItemModel>,
          List<IncomeItemModel>,
          List<IncomeItemModel>
        >
    with $Provider<List<IncomeItemModel>> {
  IncomeItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeItemsHash();

  @$internal
  @override
  $ProviderElement<List<IncomeItemModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<IncomeItemModel> create(Ref ref) {
    return incomeItems(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<IncomeItemModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<IncomeItemModel>>(value),
    );
  }
}

String _$incomeItemsHash() => r'a1c88cc874ef46e5bfad729436a39ad55d8c1760';

@ProviderFor(OtherIncomeTabIndex)
final otherIncomeTabIndexProvider = OtherIncomeTabIndexProvider._();

final class OtherIncomeTabIndexProvider
    extends $NotifierProvider<OtherIncomeTabIndex, int> {
  OtherIncomeTabIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otherIncomeTabIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otherIncomeTabIndexHash();

  @$internal
  @override
  OtherIncomeTabIndex create() => OtherIncomeTabIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$otherIncomeTabIndexHash() =>
    r'b13e7d6ff83dc2a4b24e380260854a1c1426e558';

abstract class _$OtherIncomeTabIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedIncomeCategoryId)
final selectedIncomeCategoryIdProvider = SelectedIncomeCategoryIdProvider._();

final class SelectedIncomeCategoryIdProvider
    extends $NotifierProvider<SelectedIncomeCategoryId, String?> {
  SelectedIncomeCategoryIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedIncomeCategoryIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedIncomeCategoryIdHash();

  @$internal
  @override
  SelectedIncomeCategoryId create() => SelectedIncomeCategoryId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedIncomeCategoryIdHash() =>
    r'e706ad98f89bcef2b91c5abc574d97f27322c3cb';

abstract class _$SelectedIncomeCategoryId extends $Notifier<String?> {
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

@ProviderFor(SelectedIncomeItemId)
final selectedIncomeItemIdProvider = SelectedIncomeItemIdProvider._();

final class SelectedIncomeItemIdProvider
    extends $NotifierProvider<SelectedIncomeItemId, String?> {
  SelectedIncomeItemIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedIncomeItemIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedIncomeItemIdHash();

  @$internal
  @override
  SelectedIncomeItemId create() => SelectedIncomeItemId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedIncomeItemIdHash() =>
    r'93b8d25e23d85f52bf634ca36f8558caca694914';

abstract class _$SelectedIncomeItemId extends $Notifier<String?> {
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

@ProviderFor(IncomeCategorySearchQuery)
final incomeCategorySearchQueryProvider = IncomeCategorySearchQueryProvider._();

final class IncomeCategorySearchQueryProvider
    extends $NotifierProvider<IncomeCategorySearchQuery, String> {
  IncomeCategorySearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeCategorySearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeCategorySearchQueryHash();

  @$internal
  @override
  IncomeCategorySearchQuery create() => IncomeCategorySearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$incomeCategorySearchQueryHash() =>
    r'60fc37bbfe00c6f95ea15cf796dbf7a3b9dcf285';

abstract class _$IncomeCategorySearchQuery extends $Notifier<String> {
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

@ProviderFor(OtherIncomeTransactionSearchQuery)
final otherIncomeTransactionSearchQueryProvider =
    OtherIncomeTransactionSearchQueryProvider._();

final class OtherIncomeTransactionSearchQueryProvider
    extends $NotifierProvider<OtherIncomeTransactionSearchQuery, String> {
  OtherIncomeTransactionSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otherIncomeTransactionSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$otherIncomeTransactionSearchQueryHash();

  @$internal
  @override
  OtherIncomeTransactionSearchQuery create() =>
      OtherIncomeTransactionSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$otherIncomeTransactionSearchQueryHash() =>
    r'68f2be7c8f63ccec8e2e2d7c2da2a9de5e515c35';

abstract class _$OtherIncomeTransactionSearchQuery extends $Notifier<String> {
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

@ProviderFor(IncomeItemSearchQuery)
final incomeItemSearchQueryProvider = IncomeItemSearchQueryProvider._();

final class IncomeItemSearchQueryProvider
    extends $NotifierProvider<IncomeItemSearchQuery, String> {
  IncomeItemSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeItemSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeItemSearchQueryHash();

  @$internal
  @override
  IncomeItemSearchQuery create() => IncomeItemSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$incomeItemSearchQueryHash() =>
    r'a37e5104137aa58e6f08c0f6ec2bc8e1b55bfb1d';

abstract class _$IncomeItemSearchQuery extends $Notifier<String> {
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

@ProviderFor(IncomeItemTransactionSearchQuery)
final incomeItemTransactionSearchQueryProvider =
    IncomeItemTransactionSearchQueryProvider._();

final class IncomeItemTransactionSearchQueryProvider
    extends $NotifierProvider<IncomeItemTransactionSearchQuery, String> {
  IncomeItemTransactionSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeItemTransactionSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeItemTransactionSearchQueryHash();

  @$internal
  @override
  IncomeItemTransactionSearchQuery create() =>
      IncomeItemTransactionSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$incomeItemTransactionSearchQueryHash() =>
    r'9c4422a6e03606497a5a0b601bbfd07985a5b3b1';

abstract class _$IncomeItemTransactionSearchQuery extends $Notifier<String> {
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

@ProviderFor(OtherIncomeFilters)
final otherIncomeFiltersProvider = OtherIncomeFiltersProvider._();

final class OtherIncomeFiltersProvider
    extends $NotifierProvider<OtherIncomeFilters, OtherIncomeFiltersState> {
  OtherIncomeFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otherIncomeFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otherIncomeFiltersHash();

  @$internal
  @override
  OtherIncomeFilters create() => OtherIncomeFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OtherIncomeFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OtherIncomeFiltersState>(value),
    );
  }
}

String _$otherIncomeFiltersHash() =>
    r'80b0103e81abb722d9c26a3a2028c234e402c13b';

abstract class _$OtherIncomeFilters extends $Notifier<OtherIncomeFiltersState> {
  OtherIncomeFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<OtherIncomeFiltersState, OtherIncomeFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OtherIncomeFiltersState, OtherIncomeFiltersState>,
              OtherIncomeFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredIncomeCategories)
final filteredIncomeCategoriesProvider = FilteredIncomeCategoriesProvider._();

final class FilteredIncomeCategoriesProvider
    extends
        $FunctionalProvider<
          List<IncomeCategoryModel>,
          List<IncomeCategoryModel>,
          List<IncomeCategoryModel>
        >
    with $Provider<List<IncomeCategoryModel>> {
  FilteredIncomeCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredIncomeCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredIncomeCategoriesHash();

  @$internal
  @override
  $ProviderElement<List<IncomeCategoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<IncomeCategoryModel> create(Ref ref) {
    return filteredIncomeCategories(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<IncomeCategoryModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<IncomeCategoryModel>>(value),
    );
  }
}

String _$filteredIncomeCategoriesHash() =>
    r'11f506c1e1bd236efcd6e97b9a45ea24771f49a0';

@ProviderFor(categoryOtherIncomeTransactions)
final categoryOtherIncomeTransactionsProvider =
    CategoryOtherIncomeTransactionsFamily._();

final class CategoryOtherIncomeTransactionsProvider
    extends
        $FunctionalProvider<
          List<OtherIncomeTransactionModel>,
          List<OtherIncomeTransactionModel>,
          List<OtherIncomeTransactionModel>
        >
    with $Provider<List<OtherIncomeTransactionModel>> {
  CategoryOtherIncomeTransactionsProvider._({
    required CategoryOtherIncomeTransactionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryOtherIncomeTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryOtherIncomeTransactionsHash();

  @override
  String toString() {
    return r'categoryOtherIncomeTransactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<OtherIncomeTransactionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<OtherIncomeTransactionModel> create(Ref ref) {
    final argument = this.argument as String;
    return categoryOtherIncomeTransactions(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<OtherIncomeTransactionModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<OtherIncomeTransactionModel>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryOtherIncomeTransactionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryOtherIncomeTransactionsHash() =>
    r'5027e1f62d27353530d04f8cc547c31ba6be5d95';

final class CategoryOtherIncomeTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<List<OtherIncomeTransactionModel>, String> {
  CategoryOtherIncomeTransactionsFamily._()
    : super(
        retry: null,
        name: r'categoryOtherIncomeTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryOtherIncomeTransactionsProvider call(String categoryId) =>
      CategoryOtherIncomeTransactionsProvider._(
        argument: categoryId,
        from: this,
      );

  @override
  String toString() => r'categoryOtherIncomeTransactionsProvider';
}

@ProviderFor(filteredIncomeItems)
final filteredIncomeItemsProvider = FilteredIncomeItemsProvider._();

final class FilteredIncomeItemsProvider
    extends
        $FunctionalProvider<
          List<IncomeItemModel>,
          List<IncomeItemModel>,
          List<IncomeItemModel>
        >
    with $Provider<List<IncomeItemModel>> {
  FilteredIncomeItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredIncomeItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredIncomeItemsHash();

  @$internal
  @override
  $ProviderElement<List<IncomeItemModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<IncomeItemModel> create(Ref ref) {
    return filteredIncomeItems(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<IncomeItemModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<IncomeItemModel>>(value),
    );
  }
}

String _$filteredIncomeItemsHash() =>
    r'cbd51624b3e653e533909ae9a710c26b4a999530';

@ProviderFor(itemOtherIncomeTransactions)
final itemOtherIncomeTransactionsProvider =
    ItemOtherIncomeTransactionsFamily._();

final class ItemOtherIncomeTransactionsProvider
    extends
        $FunctionalProvider<
          List<OtherIncomeTransactionModel>,
          List<OtherIncomeTransactionModel>,
          List<OtherIncomeTransactionModel>
        >
    with $Provider<List<OtherIncomeTransactionModel>> {
  ItemOtherIncomeTransactionsProvider._({
    required ItemOtherIncomeTransactionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itemOtherIncomeTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemOtherIncomeTransactionsHash();

  @override
  String toString() {
    return r'itemOtherIncomeTransactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<OtherIncomeTransactionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<OtherIncomeTransactionModel> create(Ref ref) {
    final argument = this.argument as String;
    return itemOtherIncomeTransactions(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<OtherIncomeTransactionModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<OtherIncomeTransactionModel>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ItemOtherIncomeTransactionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemOtherIncomeTransactionsHash() =>
    r'9710e94a6e21a7488521b7be64fcba7a86cef94b';

final class ItemOtherIncomeTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<List<OtherIncomeTransactionModel>, String> {
  ItemOtherIncomeTransactionsFamily._()
    : super(
        retry: null,
        name: r'itemOtherIncomeTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemOtherIncomeTransactionsProvider call(String itemId) =>
      ItemOtherIncomeTransactionsProvider._(argument: itemId, from: this);

  @override
  String toString() => r'itemOtherIncomeTransactionsProvider';
}

@ProviderFor(otherIncomeTransactionPartyOptions)
final otherIncomeTransactionPartyOptionsProvider =
    OtherIncomeTransactionPartyOptionsProvider._();

final class OtherIncomeTransactionPartyOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  OtherIncomeTransactionPartyOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otherIncomeTransactionPartyOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$otherIncomeTransactionPartyOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return otherIncomeTransactionPartyOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$otherIncomeTransactionPartyOptionsHash() =>
    r'0def595111f921e081877a63d628581b19b833f1';

@ProviderFor(expensesTotalAmount)
final expensesTotalAmountProvider = ExpensesTotalAmountProvider._();

final class ExpensesTotalAmountProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  ExpensesTotalAmountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expensesTotalAmountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expensesTotalAmountHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return expensesTotalAmount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$expensesTotalAmountHash() =>
    r'12cdba9b70b8630981008ebfc9914944746bf3b3';
