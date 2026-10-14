// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExpenseCategories)
final expenseCategoriesProvider = ExpenseCategoriesProvider._();

final class ExpenseCategoriesProvider
    extends
        $AsyncNotifierProvider<ExpenseCategories, List<ExpenseCategoryModel>> {
  ExpenseCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseCategoriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseCategoriesHash();

  @$internal
  @override
  ExpenseCategories create() => ExpenseCategories();
}

String _$expenseCategoriesHash() => r'7af632f2a8311b91a052e3442167b300240bc987';

abstract class _$ExpenseCategories
    extends $AsyncNotifier<List<ExpenseCategoryModel>> {
  FutureOr<List<ExpenseCategoryModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ExpenseCategoryModel>>,
              List<ExpenseCategoryModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ExpenseCategoryModel>>,
                List<ExpenseCategoryModel>
              >,
              AsyncValue<List<ExpenseCategoryModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ExpenseCatalogItems)
final expenseCatalogItemsProvider = ExpenseCatalogItemsProvider._();

final class ExpenseCatalogItemsProvider
    extends
        $AsyncNotifierProvider<
          ExpenseCatalogItems,
          List<ExpenseCatalogItemModel>
        > {
  ExpenseCatalogItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseCatalogItemsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseCatalogItemsHash();

  @$internal
  @override
  ExpenseCatalogItems create() => ExpenseCatalogItems();
}

String _$expenseCatalogItemsHash() =>
    r'bcd934d6be2b14a76e6fc0f04a9345636bddad2e';

abstract class _$ExpenseCatalogItems
    extends $AsyncNotifier<List<ExpenseCatalogItemModel>> {
  FutureOr<List<ExpenseCatalogItemModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ExpenseCatalogItemModel>>,
              List<ExpenseCatalogItemModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ExpenseCatalogItemModel>>,
                List<ExpenseCatalogItemModel>
              >,
              AsyncValue<List<ExpenseCatalogItemModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ExpenseTransactions)
final expenseTransactionsProvider = ExpenseTransactionsProvider._();

final class ExpenseTransactionsProvider
    extends
        $AsyncNotifierProvider<
          ExpenseTransactions,
          List<ExpenseTransactionModel>
        > {
  ExpenseTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseTransactionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseTransactionsHash();

  @$internal
  @override
  ExpenseTransactions create() => ExpenseTransactions();
}

String _$expenseTransactionsHash() =>
    r'3efaf83c5aee82ba4b6fa644d401d875ab2651c2';

abstract class _$ExpenseTransactions
    extends $AsyncNotifier<List<ExpenseTransactionModel>> {
  FutureOr<List<ExpenseTransactionModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ExpenseTransactionModel>>,
              List<ExpenseTransactionModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ExpenseTransactionModel>>,
                List<ExpenseTransactionModel>
              >,
              AsyncValue<List<ExpenseTransactionModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(expensesPageData)
final expensesPageDataProvider = ExpensesPageDataProvider._();

final class ExpensesPageDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExpensePageData>,
          ExpensePageData,
          FutureOr<ExpensePageData>
        >
    with $FutureModifier<ExpensePageData>, $FutureProvider<ExpensePageData> {
  ExpensesPageDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expensesPageDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expensesPageDataHash();

  @$internal
  @override
  $FutureProviderElement<ExpensePageData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExpensePageData> create(Ref ref) {
    return expensesPageData(ref);
  }
}

String _$expensesPageDataHash() => r'c0da514431ea0ae837f6afa4405926211aadba84';

@ProviderFor(expenseItems)
final expenseItemsProvider = ExpenseItemsProvider._();

final class ExpenseItemsProvider
    extends
        $FunctionalProvider<
          List<ExpenseItemModel>,
          List<ExpenseItemModel>,
          List<ExpenseItemModel>
        >
    with $Provider<List<ExpenseItemModel>> {
  ExpenseItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseItemsHash();

  @$internal
  @override
  $ProviderElement<List<ExpenseItemModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ExpenseItemModel> create(Ref ref) {
    return expenseItems(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ExpenseItemModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ExpenseItemModel>>(value),
    );
  }
}

String _$expenseItemsHash() => r'445c60b5481ac710450d4e0de5cfbc3a00c4c575';

@ProviderFor(ExpenseTabIndex)
final expenseTabIndexProvider = ExpenseTabIndexProvider._();

final class ExpenseTabIndexProvider
    extends $NotifierProvider<ExpenseTabIndex, int> {
  ExpenseTabIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseTabIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseTabIndexHash();

  @$internal
  @override
  ExpenseTabIndex create() => ExpenseTabIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$expenseTabIndexHash() => r'c78761479d063d5019ae68de872b3be0651cba0d';

abstract class _$ExpenseTabIndex extends $Notifier<int> {
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

@ProviderFor(SelectedExpenseCategoryId)
final selectedExpenseCategoryIdProvider = SelectedExpenseCategoryIdProvider._();

final class SelectedExpenseCategoryIdProvider
    extends $NotifierProvider<SelectedExpenseCategoryId, String?> {
  SelectedExpenseCategoryIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedExpenseCategoryIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedExpenseCategoryIdHash();

  @$internal
  @override
  SelectedExpenseCategoryId create() => SelectedExpenseCategoryId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedExpenseCategoryIdHash() =>
    r'af3597b65e043c60f0f6ec4836746462763c7c29';

abstract class _$SelectedExpenseCategoryId extends $Notifier<String?> {
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

@ProviderFor(SelectedExpenseItemId)
final selectedExpenseItemIdProvider = SelectedExpenseItemIdProvider._();

final class SelectedExpenseItemIdProvider
    extends $NotifierProvider<SelectedExpenseItemId, String?> {
  SelectedExpenseItemIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedExpenseItemIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedExpenseItemIdHash();

  @$internal
  @override
  SelectedExpenseItemId create() => SelectedExpenseItemId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedExpenseItemIdHash() =>
    r'3cc2b1af818351329c64d8a9131d993ad6b27900';

abstract class _$SelectedExpenseItemId extends $Notifier<String?> {
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

@ProviderFor(ExpenseCategorySearchQuery)
final expenseCategorySearchQueryProvider =
    ExpenseCategorySearchQueryProvider._();

final class ExpenseCategorySearchQueryProvider
    extends $NotifierProvider<ExpenseCategorySearchQuery, String> {
  ExpenseCategorySearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseCategorySearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseCategorySearchQueryHash();

  @$internal
  @override
  ExpenseCategorySearchQuery create() => ExpenseCategorySearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$expenseCategorySearchQueryHash() =>
    r'8eb9cd72081a9ef72f4f8e8081f1d28fb4fb5fb0';

abstract class _$ExpenseCategorySearchQuery extends $Notifier<String> {
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

@ProviderFor(ExpenseTransactionSearchQuery)
final expenseTransactionSearchQueryProvider =
    ExpenseTransactionSearchQueryProvider._();

final class ExpenseTransactionSearchQueryProvider
    extends $NotifierProvider<ExpenseTransactionSearchQuery, String> {
  ExpenseTransactionSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseTransactionSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseTransactionSearchQueryHash();

  @$internal
  @override
  ExpenseTransactionSearchQuery create() => ExpenseTransactionSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$expenseTransactionSearchQueryHash() =>
    r'4632b6d00f4884a7ad7985754434f0e69db660fa';

abstract class _$ExpenseTransactionSearchQuery extends $Notifier<String> {
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

@ProviderFor(ExpenseItemSearchQuery)
final expenseItemSearchQueryProvider = ExpenseItemSearchQueryProvider._();

final class ExpenseItemSearchQueryProvider
    extends $NotifierProvider<ExpenseItemSearchQuery, String> {
  ExpenseItemSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseItemSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseItemSearchQueryHash();

  @$internal
  @override
  ExpenseItemSearchQuery create() => ExpenseItemSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$expenseItemSearchQueryHash() =>
    r'dd15e49bd9bb20e43aa1a54395b8acdc0ab71932';

abstract class _$ExpenseItemSearchQuery extends $Notifier<String> {
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

@ProviderFor(ExpenseItemTransactionSearchQuery)
final expenseItemTransactionSearchQueryProvider =
    ExpenseItemTransactionSearchQueryProvider._();

final class ExpenseItemTransactionSearchQueryProvider
    extends $NotifierProvider<ExpenseItemTransactionSearchQuery, String> {
  ExpenseItemTransactionSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseItemTransactionSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$expenseItemTransactionSearchQueryHash();

  @$internal
  @override
  ExpenseItemTransactionSearchQuery create() =>
      ExpenseItemTransactionSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$expenseItemTransactionSearchQueryHash() =>
    r'94acaa3d8a6d22022509bf5e1e15a8cf08af14c7';

abstract class _$ExpenseItemTransactionSearchQuery extends $Notifier<String> {
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

@ProviderFor(ExpenseFilters)
final expenseFiltersProvider = ExpenseFiltersProvider._();

final class ExpenseFiltersProvider
    extends $NotifierProvider<ExpenseFilters, ExpenseFiltersState> {
  ExpenseFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseFiltersHash();

  @$internal
  @override
  ExpenseFilters create() => ExpenseFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseFiltersState>(value),
    );
  }
}

String _$expenseFiltersHash() => r'b9d900ed7958fa6d6623f4e49f6d86d9d5f0363e';

abstract class _$ExpenseFilters extends $Notifier<ExpenseFiltersState> {
  ExpenseFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ExpenseFiltersState, ExpenseFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExpenseFiltersState, ExpenseFiltersState>,
              ExpenseFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredExpenseCategories)
final filteredExpenseCategoriesProvider = FilteredExpenseCategoriesProvider._();

final class FilteredExpenseCategoriesProvider
    extends
        $FunctionalProvider<
          List<ExpenseCategoryModel>,
          List<ExpenseCategoryModel>,
          List<ExpenseCategoryModel>
        >
    with $Provider<List<ExpenseCategoryModel>> {
  FilteredExpenseCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredExpenseCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredExpenseCategoriesHash();

  @$internal
  @override
  $ProviderElement<List<ExpenseCategoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ExpenseCategoryModel> create(Ref ref) {
    return filteredExpenseCategories(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ExpenseCategoryModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ExpenseCategoryModel>>(value),
    );
  }
}

String _$filteredExpenseCategoriesHash() =>
    r'4579d7c02ff7779257010641bdec9bfdbbde1793';

@ProviderFor(categoryExpenseTransactions)
final categoryExpenseTransactionsProvider =
    CategoryExpenseTransactionsFamily._();

final class CategoryExpenseTransactionsProvider
    extends
        $FunctionalProvider<
          List<ExpenseTransactionModel>,
          List<ExpenseTransactionModel>,
          List<ExpenseTransactionModel>
        >
    with $Provider<List<ExpenseTransactionModel>> {
  CategoryExpenseTransactionsProvider._({
    required CategoryExpenseTransactionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryExpenseTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryExpenseTransactionsHash();

  @override
  String toString() {
    return r'categoryExpenseTransactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<ExpenseTransactionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ExpenseTransactionModel> create(Ref ref) {
    final argument = this.argument as String;
    return categoryExpenseTransactions(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ExpenseTransactionModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ExpenseTransactionModel>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryExpenseTransactionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryExpenseTransactionsHash() =>
    r'90e19e12553dcd42db1fd0caa319a7fe37bb2ac7';

final class CategoryExpenseTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<List<ExpenseTransactionModel>, String> {
  CategoryExpenseTransactionsFamily._()
    : super(
        retry: null,
        name: r'categoryExpenseTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryExpenseTransactionsProvider call(String categoryId) =>
      CategoryExpenseTransactionsProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'categoryExpenseTransactionsProvider';
}

@ProviderFor(filteredExpenseItems)
final filteredExpenseItemsProvider = FilteredExpenseItemsProvider._();

final class FilteredExpenseItemsProvider
    extends
        $FunctionalProvider<
          List<ExpenseItemModel>,
          List<ExpenseItemModel>,
          List<ExpenseItemModel>
        >
    with $Provider<List<ExpenseItemModel>> {
  FilteredExpenseItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredExpenseItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredExpenseItemsHash();

  @$internal
  @override
  $ProviderElement<List<ExpenseItemModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ExpenseItemModel> create(Ref ref) {
    return filteredExpenseItems(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ExpenseItemModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ExpenseItemModel>>(value),
    );
  }
}

String _$filteredExpenseItemsHash() =>
    r'99b75c05eda6b11fa4ed20772bcd295e71e9413e';

@ProviderFor(itemExpenseTransactions)
final itemExpenseTransactionsProvider = ItemExpenseTransactionsFamily._();

final class ItemExpenseTransactionsProvider
    extends
        $FunctionalProvider<
          List<ExpenseTransactionModel>,
          List<ExpenseTransactionModel>,
          List<ExpenseTransactionModel>
        >
    with $Provider<List<ExpenseTransactionModel>> {
  ItemExpenseTransactionsProvider._({
    required ItemExpenseTransactionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itemExpenseTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemExpenseTransactionsHash();

  @override
  String toString() {
    return r'itemExpenseTransactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<ExpenseTransactionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ExpenseTransactionModel> create(Ref ref) {
    final argument = this.argument as String;
    return itemExpenseTransactions(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ExpenseTransactionModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ExpenseTransactionModel>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ItemExpenseTransactionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemExpenseTransactionsHash() =>
    r'bbc3f5e01606cbb3634aab4f730f6e675c90e06f';

final class ItemExpenseTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<List<ExpenseTransactionModel>, String> {
  ItemExpenseTransactionsFamily._()
    : super(
        retry: null,
        name: r'itemExpenseTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemExpenseTransactionsProvider call(String itemId) =>
      ItemExpenseTransactionsProvider._(argument: itemId, from: this);

  @override
  String toString() => r'itemExpenseTransactionsProvider';
}

@ProviderFor(expenseTransactionPartyOptions)
final expenseTransactionPartyOptionsProvider =
    ExpenseTransactionPartyOptionsProvider._();

final class ExpenseTransactionPartyOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  ExpenseTransactionPartyOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseTransactionPartyOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseTransactionPartyOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return expenseTransactionPartyOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$expenseTransactionPartyOptionsHash() =>
    r'32506a80bf60eb2feff2151bcec8bcb7beb09f96';

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
    r'0bec28fbd8861edf669bffd84fa812aa9f117653';
