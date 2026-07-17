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
    r'97115c0e96847a327cd137fdebdab8fefa835df5';

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
final addPurchaseOrderTotalTaxProvider = AddPurchaseOrderTotalTaxFamily._();

final class AddPurchaseOrderTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddPurchaseOrderTotalTaxProvider._({
    required AddPurchaseOrderTotalTaxFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addPurchaseOrderTotalTaxProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseOrderTotalTaxHash();

  @override
  String toString() {
    return r'addPurchaseOrderTotalTaxProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as String?;
    return addPurchaseOrderTotalTax(ref, orderId: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddPurchaseOrderTotalTaxProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addPurchaseOrderTotalTaxHash() =>
    r'6bd7cad7140f44715150731a9c859e5a177559df';

final class AddPurchaseOrderTotalTaxFamily extends $Family
    with $FunctionalFamilyOverride<double, String?> {
  AddPurchaseOrderTotalTaxFamily._()
    : super(
        retry: null,
        name: r'addPurchaseOrderTotalTaxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddPurchaseOrderTotalTaxProvider call({String? orderId}) =>
      AddPurchaseOrderTotalTaxProvider._(argument: orderId, from: this);

  @override
  String toString() => r'addPurchaseOrderTotalTaxProvider';
}

@ProviderFor(addPurchaseOrderGrandTotal)
final addPurchaseOrderGrandTotalProvider = AddPurchaseOrderGrandTotalFamily._();

final class AddPurchaseOrderGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddPurchaseOrderGrandTotalProvider._({
    required AddPurchaseOrderGrandTotalFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addPurchaseOrderGrandTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseOrderGrandTotalHash();

  @override
  String toString() {
    return r'addPurchaseOrderGrandTotalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as String?;
    return addPurchaseOrderGrandTotal(ref, orderId: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddPurchaseOrderGrandTotalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addPurchaseOrderGrandTotalHash() =>
    r'702aba3e6880b0a5850059dc08cfa0e73baa45e3';

final class AddPurchaseOrderGrandTotalFamily extends $Family
    with $FunctionalFamilyOverride<double, String?> {
  AddPurchaseOrderGrandTotalFamily._()
    : super(
        retry: null,
        name: r'addPurchaseOrderGrandTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddPurchaseOrderGrandTotalProvider call({String? orderId}) =>
      AddPurchaseOrderGrandTotalProvider._(argument: orderId, from: this);

  @override
  String toString() => r'addPurchaseOrderGrandTotalProvider';
}
