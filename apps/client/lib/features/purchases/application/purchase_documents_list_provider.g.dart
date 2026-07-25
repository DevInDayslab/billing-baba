// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_documents_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PurchaseDocumentSearchQuery)
final purchaseDocumentSearchQueryProvider =
    PurchaseDocumentSearchQueryFamily._();

final class PurchaseDocumentSearchQueryProvider
    extends $NotifierProvider<PurchaseDocumentSearchQuery, String> {
  PurchaseDocumentSearchQueryProvider._({
    required PurchaseDocumentSearchQueryFamily super.from,
    required PurchaseDocumentListScope super.argument,
  }) : super(
         retry: null,
         name: r'purchaseDocumentSearchQueryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseDocumentSearchQueryHash();

  @override
  String toString() {
    return r'purchaseDocumentSearchQueryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PurchaseDocumentSearchQuery create() => PurchaseDocumentSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseDocumentSearchQueryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseDocumentSearchQueryHash() =>
    r'399b69c9adf0713e7a96203f2ec0235444e824a3';

final class PurchaseDocumentSearchQueryFamily extends $Family
    with
        $ClassFamilyOverride<
          PurchaseDocumentSearchQuery,
          String,
          String,
          String,
          PurchaseDocumentListScope
        > {
  PurchaseDocumentSearchQueryFamily._()
    : super(
        retry: null,
        name: r'purchaseDocumentSearchQueryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PurchaseDocumentSearchQueryProvider call(PurchaseDocumentListScope scope) =>
      PurchaseDocumentSearchQueryProvider._(argument: scope, from: this);

  @override
  String toString() => r'purchaseDocumentSearchQueryProvider';
}

abstract class _$PurchaseDocumentSearchQuery extends $Notifier<String> {
  late final _$args = ref.$arg as PurchaseDocumentListScope;
  PurchaseDocumentListScope get scope => _$args;

  String build(PurchaseDocumentListScope scope);
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

@ProviderFor(PurchaseDocumentFilters)
final purchaseDocumentFiltersProvider = PurchaseDocumentFiltersFamily._();

final class PurchaseDocumentFiltersProvider
    extends
        $NotifierProvider<
          PurchaseDocumentFilters,
          PurchaseDocumentFiltersState
        > {
  PurchaseDocumentFiltersProvider._({
    required PurchaseDocumentFiltersFamily super.from,
    required PurchaseDocumentListScope super.argument,
  }) : super(
         retry: null,
         name: r'purchaseDocumentFiltersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseDocumentFiltersHash();

  @override
  String toString() {
    return r'purchaseDocumentFiltersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PurchaseDocumentFilters create() => PurchaseDocumentFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseDocumentFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseDocumentFiltersState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseDocumentFiltersProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseDocumentFiltersHash() =>
    r'7d26b33675ec2ab959871eef3bff910e7cc4ebe4';

final class PurchaseDocumentFiltersFamily extends $Family
    with
        $ClassFamilyOverride<
          PurchaseDocumentFilters,
          PurchaseDocumentFiltersState,
          PurchaseDocumentFiltersState,
          PurchaseDocumentFiltersState,
          PurchaseDocumentListScope
        > {
  PurchaseDocumentFiltersFamily._()
    : super(
        retry: null,
        name: r'purchaseDocumentFiltersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PurchaseDocumentFiltersProvider call(PurchaseDocumentListScope scope) =>
      PurchaseDocumentFiltersProvider._(argument: scope, from: this);

  @override
  String toString() => r'purchaseDocumentFiltersProvider';
}

abstract class _$PurchaseDocumentFilters
    extends $Notifier<PurchaseDocumentFiltersState> {
  late final _$args = ref.$arg as PurchaseDocumentListScope;
  PurchaseDocumentListScope get scope => _$args;

  PurchaseDocumentFiltersState build(PurchaseDocumentListScope scope);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<PurchaseDocumentFiltersState, PurchaseDocumentFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                PurchaseDocumentFiltersState,
                PurchaseDocumentFiltersState
              >,
              PurchaseDocumentFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(PurchaseDocumentsList)
final purchaseDocumentsListProvider = PurchaseDocumentsListFamily._();

final class PurchaseDocumentsListProvider
    extends
        $AsyncNotifierProvider<
          PurchaseDocumentsList,
          PaginatedPurchaseDocuments
        > {
  PurchaseDocumentsListProvider._({
    required PurchaseDocumentsListFamily super.from,
    required PurchaseDocumentListScope super.argument,
  }) : super(
         retry: null,
         name: r'purchaseDocumentsListProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseDocumentsListHash();

  @override
  String toString() {
    return r'purchaseDocumentsListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PurchaseDocumentsList create() => PurchaseDocumentsList();

  @override
  bool operator ==(Object other) {
    return other is PurchaseDocumentsListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseDocumentsListHash() =>
    r'ce6622e924644f3bdeb6335561e4b6532728d345';

final class PurchaseDocumentsListFamily extends $Family
    with
        $ClassFamilyOverride<
          PurchaseDocumentsList,
          AsyncValue<PaginatedPurchaseDocuments>,
          PaginatedPurchaseDocuments,
          FutureOr<PaginatedPurchaseDocuments>,
          PurchaseDocumentListScope
        > {
  PurchaseDocumentsListFamily._()
    : super(
        retry: null,
        name: r'purchaseDocumentsListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  PurchaseDocumentsListProvider call(PurchaseDocumentListScope scope) =>
      PurchaseDocumentsListProvider._(argument: scope, from: this);

  @override
  String toString() => r'purchaseDocumentsListProvider';
}

abstract class _$PurchaseDocumentsList
    extends $AsyncNotifier<PaginatedPurchaseDocuments> {
  late final _$args = ref.$arg as PurchaseDocumentListScope;
  PurchaseDocumentListScope get scope => _$args;

  FutureOr<PaginatedPurchaseDocuments> build(PurchaseDocumentListScope scope);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedPurchaseDocuments>,
              PaginatedPurchaseDocuments
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedPurchaseDocuments>,
                PaginatedPurchaseDocuments
              >,
              AsyncValue<PaginatedPurchaseDocuments>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
