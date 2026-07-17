// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_documents_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SalesDocumentSearchQuery)
final salesDocumentSearchQueryProvider = SalesDocumentSearchQueryFamily._();

final class SalesDocumentSearchQueryProvider
    extends $NotifierProvider<SalesDocumentSearchQuery, String> {
  SalesDocumentSearchQueryProvider._({
    required SalesDocumentSearchQueryFamily super.from,
    required SalesDocumentListScope super.argument,
  }) : super(
         retry: null,
         name: r'salesDocumentSearchQueryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$salesDocumentSearchQueryHash();

  @override
  String toString() {
    return r'salesDocumentSearchQueryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SalesDocumentSearchQuery create() => SalesDocumentSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SalesDocumentSearchQueryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$salesDocumentSearchQueryHash() =>
    r'f8ef92e21c06677e920e5771da9cbd823f702d1a';

final class SalesDocumentSearchQueryFamily extends $Family
    with
        $ClassFamilyOverride<
          SalesDocumentSearchQuery,
          String,
          String,
          String,
          SalesDocumentListScope
        > {
  SalesDocumentSearchQueryFamily._()
    : super(
        retry: null,
        name: r'salesDocumentSearchQueryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SalesDocumentSearchQueryProvider call(SalesDocumentListScope scope) =>
      SalesDocumentSearchQueryProvider._(argument: scope, from: this);

  @override
  String toString() => r'salesDocumentSearchQueryProvider';
}

abstract class _$SalesDocumentSearchQuery extends $Notifier<String> {
  late final _$args = ref.$arg as SalesDocumentListScope;
  SalesDocumentListScope get scope => _$args;

  String build(SalesDocumentListScope scope);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(SalesDocumentFilters)
final salesDocumentFiltersProvider = SalesDocumentFiltersFamily._();

final class SalesDocumentFiltersProvider
    extends $NotifierProvider<SalesDocumentFilters, SalesDocumentFiltersState> {
  SalesDocumentFiltersProvider._({
    required SalesDocumentFiltersFamily super.from,
    required SalesDocumentListScope super.argument,
  }) : super(
         retry: null,
         name: r'salesDocumentFiltersProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$salesDocumentFiltersHash();

  @override
  String toString() {
    return r'salesDocumentFiltersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SalesDocumentFilters create() => SalesDocumentFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SalesDocumentFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SalesDocumentFiltersState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SalesDocumentFiltersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$salesDocumentFiltersHash() =>
    r'bb562c9b8cb9be20b5f74650dd38e4c0a0d0933d';

final class SalesDocumentFiltersFamily extends $Family
    with
        $ClassFamilyOverride<
          SalesDocumentFilters,
          SalesDocumentFiltersState,
          SalesDocumentFiltersState,
          SalesDocumentFiltersState,
          SalesDocumentListScope
        > {
  SalesDocumentFiltersFamily._()
    : super(
        retry: null,
        name: r'salesDocumentFiltersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SalesDocumentFiltersProvider call(SalesDocumentListScope scope) =>
      SalesDocumentFiltersProvider._(argument: scope, from: this);

  @override
  String toString() => r'salesDocumentFiltersProvider';
}

abstract class _$SalesDocumentFilters
    extends $Notifier<SalesDocumentFiltersState> {
  late final _$args = ref.$arg as SalesDocumentListScope;
  SalesDocumentListScope get scope => _$args;

  SalesDocumentFiltersState build(SalesDocumentListScope scope);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<SalesDocumentFiltersState, SalesDocumentFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SalesDocumentFiltersState, SalesDocumentFiltersState>,
              SalesDocumentFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(SalesDocumentsList)
final salesDocumentsListProvider = SalesDocumentsListFamily._();

final class SalesDocumentsListProvider
    extends $AsyncNotifierProvider<SalesDocumentsList, PaginatedSaleInvoices> {
  SalesDocumentsListProvider._({
    required SalesDocumentsListFamily super.from,
    required SalesDocumentListScope super.argument,
  }) : super(
         retry: null,
         name: r'salesDocumentsListProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$salesDocumentsListHash();

  @override
  String toString() {
    return r'salesDocumentsListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SalesDocumentsList create() => SalesDocumentsList();

  @override
  bool operator ==(Object other) {
    return other is SalesDocumentsListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$salesDocumentsListHash() =>
    r'61dd7c18b070ea9230e0f30176f48e1881161dd0';

final class SalesDocumentsListFamily extends $Family
    with
        $ClassFamilyOverride<
          SalesDocumentsList,
          AsyncValue<PaginatedSaleInvoices>,
          PaginatedSaleInvoices,
          FutureOr<PaginatedSaleInvoices>,
          SalesDocumentListScope
        > {
  SalesDocumentsListFamily._()
    : super(
        retry: null,
        name: r'salesDocumentsListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SalesDocumentsListProvider call(SalesDocumentListScope scope) =>
      SalesDocumentsListProvider._(argument: scope, from: this);

  @override
  String toString() => r'salesDocumentsListProvider';
}

abstract class _$SalesDocumentsList
    extends $AsyncNotifier<PaginatedSaleInvoices> {
  late final _$args = ref.$arg as SalesDocumentListScope;
  SalesDocumentListScope get scope => _$args;

  FutureOr<PaginatedSaleInvoices> build(SalesDocumentListScope scope);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(filteredSalesDocuments)
final filteredSalesDocumentsProvider = FilteredSalesDocumentsFamily._();

final class FilteredSalesDocumentsProvider
    extends
        $FunctionalProvider<
          List<SaleInvoiceModel>,
          List<SaleInvoiceModel>,
          List<SaleInvoiceModel>
        >
    with $Provider<List<SaleInvoiceModel>> {
  FilteredSalesDocumentsProvider._({
    required FilteredSalesDocumentsFamily super.from,
    required SalesDocumentListScope super.argument,
  }) : super(
         retry: null,
         name: r'filteredSalesDocumentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredSalesDocumentsHash();

  @override
  String toString() {
    return r'filteredSalesDocumentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<SaleInvoiceModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SaleInvoiceModel> create(Ref ref) {
    final argument = this.argument as SalesDocumentListScope;
    return filteredSalesDocuments(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SaleInvoiceModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SaleInvoiceModel>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredSalesDocumentsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredSalesDocumentsHash() =>
    r'c17af9f9f04c0861e344728c1a90086421052a86';

final class FilteredSalesDocumentsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<SaleInvoiceModel>,
          SalesDocumentListScope
        > {
  FilteredSalesDocumentsFamily._()
    : super(
        retry: null,
        name: r'filteredSalesDocumentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FilteredSalesDocumentsProvider call(SalesDocumentListScope scope) =>
      FilteredSalesDocumentsProvider._(argument: scope, from: this);

  @override
  String toString() => r'filteredSalesDocumentsProvider';
}

@ProviderFor(paginatedSalesDocuments)
final paginatedSalesDocumentsProvider = PaginatedSalesDocumentsFamily._();

final class PaginatedSalesDocumentsProvider
    extends
        $FunctionalProvider<
          PaginatedSaleInvoices,
          PaginatedSaleInvoices,
          PaginatedSaleInvoices
        >
    with $Provider<PaginatedSaleInvoices> {
  PaginatedSalesDocumentsProvider._({
    required PaginatedSalesDocumentsFamily super.from,
    required SalesDocumentListScope super.argument,
  }) : super(
         retry: null,
         name: r'paginatedSalesDocumentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paginatedSalesDocumentsHash();

  @override
  String toString() {
    return r'paginatedSalesDocumentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<PaginatedSaleInvoices> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedSaleInvoices create(Ref ref) {
    final argument = this.argument as SalesDocumentListScope;
    return paginatedSalesDocuments(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedSaleInvoices value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedSaleInvoices>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PaginatedSalesDocumentsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paginatedSalesDocumentsHash() =>
    r'29b9bac20b015633c171436782037cdc62cca179';

final class PaginatedSalesDocumentsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          PaginatedSaleInvoices,
          SalesDocumentListScope
        > {
  PaginatedSalesDocumentsFamily._()
    : super(
        retry: null,
        name: r'paginatedSalesDocumentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaginatedSalesDocumentsProvider call(SalesDocumentListScope scope) =>
      PaginatedSalesDocumentsProvider._(argument: scope, from: this);

  @override
  String toString() => r'paginatedSalesDocumentsProvider';
}

@ProviderFor(salesOrderStatusSummary)
final salesOrderStatusSummaryProvider = SalesOrderStatusSummaryProvider._();

final class SalesOrderStatusSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SalesOrderSummaryData>,
          SalesOrderSummaryData,
          FutureOr<SalesOrderSummaryData>
        >
    with
        $FutureModifier<SalesOrderSummaryData>,
        $FutureProvider<SalesOrderSummaryData> {
  SalesOrderStatusSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesOrderStatusSummaryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesOrderStatusSummaryHash();

  @$internal
  @override
  $FutureProviderElement<SalesOrderSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SalesOrderSummaryData> create(Ref ref) {
    return salesOrderStatusSummary(ref);
  }
}

String _$salesOrderStatusSummaryHash() =>
    r'21c920b79f3f414d9ec94f2aa2bcc142273f4c5e';
