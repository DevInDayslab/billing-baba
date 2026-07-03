// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_order_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleOrderFormNotifier)
final saleOrderFormProvider = SaleOrderFormNotifierProvider._();

final class SaleOrderFormNotifierProvider
    extends $NotifierProvider<SaleOrderFormNotifier, SaleOrderFormState> {
  SaleOrderFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleOrderFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleOrderFormNotifierHash();

  @$internal
  @override
  SaleOrderFormNotifier create() => SaleOrderFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleOrderFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleOrderFormState>(value),
    );
  }
}

String _$saleOrderFormNotifierHash() =>
    r'65253a569d1dc71420fe8cc33d3637e4f48142c4';

abstract class _$SaleOrderFormNotifier extends $Notifier<SaleOrderFormState> {
  SaleOrderFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SaleOrderFormState, SaleOrderFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleOrderFormState, SaleOrderFormState>,
              SaleOrderFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SavedSaleOrdersNotifier)
final savedSaleOrdersProvider = SavedSaleOrdersNotifierProvider._();

final class SavedSaleOrdersNotifierProvider
    extends $NotifierProvider<SavedSaleOrdersNotifier, List<SavedSaleOrder>> {
  SavedSaleOrdersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedSaleOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedSaleOrdersNotifierHash();

  @$internal
  @override
  SavedSaleOrdersNotifier create() => SavedSaleOrdersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SavedSaleOrder> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SavedSaleOrder>>(value),
    );
  }
}

String _$savedSaleOrdersNotifierHash() =>
    r'e7cd643288e05c6b1579bfa6db9444c6bc4e66b2';

abstract class _$SavedSaleOrdersNotifier
    extends $Notifier<List<SavedSaleOrder>> {
  List<SavedSaleOrder> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<SavedSaleOrder>, List<SavedSaleOrder>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SavedSaleOrder>, List<SavedSaleOrder>>,
              List<SavedSaleOrder>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(saleOrderGrandTotal)
final saleOrderGrandTotalProvider = SaleOrderGrandTotalProvider._();

final class SaleOrderGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  SaleOrderGrandTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleOrderGrandTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleOrderGrandTotalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return saleOrderGrandTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$saleOrderGrandTotalHash() =>
    r'a71cad1be905b34a2314d0e6a74240d9d6924fcb';
