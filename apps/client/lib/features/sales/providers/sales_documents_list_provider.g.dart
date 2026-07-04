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
         isAutoDispose: true,
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
    r'dfa59a235a29a3c64d8c7e953784c0455161d370';

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
        isAutoDispose: true,
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
         isAutoDispose: true,
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
    r'0e894dc1155a72ab6fa948ded894567f533cbcc1';

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
        isAutoDispose: true,
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
    r'18ffaa51a42a887b1161b88cb6d9e803363b99c9';

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
    r'265c4fde05e0148fc165f49f71c800bfad211d62';

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
