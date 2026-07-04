// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_purchase_order_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddPurchaseOrderForm)
final addPurchaseOrderFormProvider = AddPurchaseOrderFormProvider._();

final class AddPurchaseOrderFormProvider
    extends $NotifierProvider<AddPurchaseOrderForm, AddPurchaseOrderFormState> {
  AddPurchaseOrderFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addPurchaseOrderFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseOrderFormHash();

  @$internal
  @override
  AddPurchaseOrderForm create() => AddPurchaseOrderForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddPurchaseOrderFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddPurchaseOrderFormState>(value),
    );
  }
}

String _$addPurchaseOrderFormHash() =>
    r'33f7f043defcf97ca360c64ec9cab8417ae1d4da';

abstract class _$AddPurchaseOrderForm
    extends $Notifier<AddPurchaseOrderFormState> {
  AddPurchaseOrderFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AddPurchaseOrderFormState, AddPurchaseOrderFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddPurchaseOrderFormState, AddPurchaseOrderFormState>,
              AddPurchaseOrderFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(addPurchaseOrderTotalTax)
final addPurchaseOrderTotalTaxProvider = AddPurchaseOrderTotalTaxProvider._();

final class AddPurchaseOrderTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddPurchaseOrderTotalTaxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addPurchaseOrderTotalTaxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseOrderTotalTaxHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return addPurchaseOrderTotalTax(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$addPurchaseOrderTotalTaxHash() =>
    r'cd3575420d11236bee8059c9665f9ad8ed2f775a';

@ProviderFor(addPurchaseOrderGrandTotal)
final addPurchaseOrderGrandTotalProvider =
    AddPurchaseOrderGrandTotalProvider._();

final class AddPurchaseOrderGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddPurchaseOrderGrandTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addPurchaseOrderGrandTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseOrderGrandTotalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return addPurchaseOrderGrandTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$addPurchaseOrderGrandTotalHash() =>
    r'08104b630ff148895917984492b2cbbf6ec464df';
