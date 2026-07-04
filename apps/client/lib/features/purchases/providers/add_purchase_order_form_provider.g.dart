// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_purchase_order_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddPurchaseOrderForm)
final addPurchaseOrderFormProvider = AddPurchaseOrderFormFamily._();

final class AddPurchaseOrderFormProvider
    extends $NotifierProvider<AddPurchaseOrderForm, AddPurchaseOrderFormState> {
  AddPurchaseOrderFormProvider._({
    required AddPurchaseOrderFormFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addPurchaseOrderFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseOrderFormHash();

  @override
  String toString() {
    return r'addPurchaseOrderFormProvider'
        ''
        '($argument)';
  }

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

  @override
  bool operator ==(Object other) {
    return other is AddPurchaseOrderFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addPurchaseOrderFormHash() =>
    r'bd3b8891e37d4135ae156c6de97321a2bcf36a77';

final class AddPurchaseOrderFormFamily extends $Family
    with
        $ClassFamilyOverride<
          AddPurchaseOrderForm,
          AddPurchaseOrderFormState,
          AddPurchaseOrderFormState,
          AddPurchaseOrderFormState,
          String?
        > {
  AddPurchaseOrderFormFamily._()
    : super(
        retry: null,
        name: r'addPurchaseOrderFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddPurchaseOrderFormProvider call({String? orderId}) =>
      AddPurchaseOrderFormProvider._(argument: orderId, from: this);

  @override
  String toString() => r'addPurchaseOrderFormProvider';
}

abstract class _$AddPurchaseOrderForm
    extends $Notifier<AddPurchaseOrderFormState> {
  late final _$args = ref.$arg as String?;
  String? get orderId => _$args;

  AddPurchaseOrderFormState build({String? orderId});
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
    return element.handleCreate(ref, () => build(orderId: _$args));
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
    r'99e158b2ede73ed8579311672d6ede5efefdc412';

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
    r'e5e2cbc566af3c2e507f8ca2e25b7e10d2ba5e8d';
