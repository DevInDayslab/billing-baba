// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_return_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleReturnFilters)
final saleReturnFiltersProvider = SaleReturnFiltersProvider._();

final class SaleReturnFiltersProvider
    extends $NotifierProvider<SaleReturnFilters, SaleReturnFiltersState> {
  SaleReturnFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleReturnFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleReturnFiltersHash();

  @$internal
  @override
  SaleReturnFilters create() => SaleReturnFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleReturnFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleReturnFiltersState>(value),
    );
  }
}

String _$saleReturnFiltersHash() => r'6b9cb82d2dbfd3469fee50afe97bd2694e5c6ffd';

abstract class _$SaleReturnFilters extends $Notifier<SaleReturnFiltersState> {
  SaleReturnFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<SaleReturnFiltersState, SaleReturnFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleReturnFiltersState, SaleReturnFiltersState>,
              SaleReturnFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(paginatedSaleReturns)
final paginatedSaleReturnsProvider = PaginatedSaleReturnsProvider._();

final class PaginatedSaleReturnsProvider
    extends
        $FunctionalProvider<
          PaginatedSaleReturns,
          PaginatedSaleReturns,
          PaginatedSaleReturns
        >
    with $Provider<PaginatedSaleReturns> {
  PaginatedSaleReturnsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedSaleReturnsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedSaleReturnsHash();

  @$internal
  @override
  $ProviderElement<PaginatedSaleReturns> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedSaleReturns create(Ref ref) {
    return paginatedSaleReturns(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedSaleReturns value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedSaleReturns>(value),
    );
  }
}

String _$paginatedSaleReturnsHash() =>
    r'964a319d436df5e89f36d1e151fbdb0a74065ce5';

@ProviderFor(saleReturnRefresh)
final saleReturnRefreshProvider = SaleReturnRefreshProvider._();

final class SaleReturnRefreshProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  SaleReturnRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleReturnRefreshProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleReturnRefreshHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return saleReturnRefresh(ref);
  }
}

String _$saleReturnRefreshHash() => r'b578e965464e0c9ecaedad67062105933a588f0e';

@ProviderFor(deleteSaleReturnDraft)
final deleteSaleReturnDraftProvider = DeleteSaleReturnDraftFamily._();

final class DeleteSaleReturnDraftProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  DeleteSaleReturnDraftProvider._({
    required DeleteSaleReturnDraftFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deleteSaleReturnDraftProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteSaleReturnDraftHash();

  @override
  String toString() {
    return r'deleteSaleReturnDraftProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return deleteSaleReturnDraft(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteSaleReturnDraftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteSaleReturnDraftHash() =>
    r'cf7b10dd6225bc5131a7e3511b1feea4cd4c7989';

final class DeleteSaleReturnDraftFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  DeleteSaleReturnDraftFamily._()
    : super(
        retry: null,
        name: r'deleteSaleReturnDraftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteSaleReturnDraftProvider call(String documentId) =>
      DeleteSaleReturnDraftProvider._(argument: documentId, from: this);

  @override
  String toString() => r'deleteSaleReturnDraftProvider';
}

@ProviderFor(finalizeSaleReturn)
final finalizeSaleReturnProvider = FinalizeSaleReturnFamily._();

final class FinalizeSaleReturnProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  FinalizeSaleReturnProvider._({
    required FinalizeSaleReturnFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'finalizeSaleReturnProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$finalizeSaleReturnHash();

  @override
  String toString() {
    return r'finalizeSaleReturnProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return finalizeSaleReturn(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FinalizeSaleReturnProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$finalizeSaleReturnHash() =>
    r'7fca07442084d43e15cf241376d5d992d638d7ab';

final class FinalizeSaleReturnFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  FinalizeSaleReturnFamily._()
    : super(
        retry: null,
        name: r'finalizeSaleReturnProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FinalizeSaleReturnProvider call(String documentId) =>
      FinalizeSaleReturnProvider._(argument: documentId, from: this);

  @override
  String toString() => r'finalizeSaleReturnProvider';
}
