// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_purchase_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddPurchaseForm)
final addPurchaseFormProvider = AddPurchaseFormFamily._();

final class AddPurchaseFormProvider
    extends $NotifierProvider<AddPurchaseForm, AddPurchaseFormState> {
  AddPurchaseFormProvider._({
    required AddPurchaseFormFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addPurchaseFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseFormHash();

  @override
  String toString() {
    return r'addPurchaseFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AddPurchaseForm create() => AddPurchaseForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddPurchaseFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddPurchaseFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddPurchaseFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addPurchaseFormHash() => r'd0f3d51093ec1b9b60877e5f848b3170b89ced04';

final class AddPurchaseFormFamily extends $Family
    with
        $ClassFamilyOverride<
          AddPurchaseForm,
          AddPurchaseFormState,
          AddPurchaseFormState,
          AddPurchaseFormState,
          String?
        > {
  AddPurchaseFormFamily._()
    : super(
        retry: null,
        name: r'addPurchaseFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddPurchaseFormProvider call({String? billId}) =>
      AddPurchaseFormProvider._(argument: billId, from: this);

  @override
  String toString() => r'addPurchaseFormProvider';
}

abstract class _$AddPurchaseForm extends $Notifier<AddPurchaseFormState> {
  late final _$args = ref.$arg as String?;
  String? get billId => _$args;

  AddPurchaseFormState build({String? billId});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AddPurchaseFormState, AddPurchaseFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddPurchaseFormState, AddPurchaseFormState>,
              AddPurchaseFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(billId: _$args));
  }
}

@ProviderFor(addPurchaseTotalTax)
final addPurchaseTotalTaxProvider = AddPurchaseTotalTaxFamily._();

final class AddPurchaseTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddPurchaseTotalTaxProvider._({
    required AddPurchaseTotalTaxFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addPurchaseTotalTaxProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseTotalTaxHash();

  @override
  String toString() {
    return r'addPurchaseTotalTaxProvider'
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
    return addPurchaseTotalTax(ref, billId: argument);
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
    return other is AddPurchaseTotalTaxProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addPurchaseTotalTaxHash() =>
    r'7c0fbbcc32d47b76c7b8150f171b9588a751dee2';

final class AddPurchaseTotalTaxFamily extends $Family
    with $FunctionalFamilyOverride<double, String?> {
  AddPurchaseTotalTaxFamily._()
    : super(
        retry: null,
        name: r'addPurchaseTotalTaxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddPurchaseTotalTaxProvider call({String? billId}) =>
      AddPurchaseTotalTaxProvider._(argument: billId, from: this);

  @override
  String toString() => r'addPurchaseTotalTaxProvider';
}

@ProviderFor(addPurchaseGrandTotal)
final addPurchaseGrandTotalProvider = AddPurchaseGrandTotalFamily._();

final class AddPurchaseGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddPurchaseGrandTotalProvider._({
    required AddPurchaseGrandTotalFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addPurchaseGrandTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseGrandTotalHash();

  @override
  String toString() {
    return r'addPurchaseGrandTotalProvider'
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
    return addPurchaseGrandTotal(ref, billId: argument);
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
    return other is AddPurchaseGrandTotalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addPurchaseGrandTotalHash() =>
    r'14767e2c5b29e1bcb5248afd7c7205be7f16f462';

final class AddPurchaseGrandTotalFamily extends $Family
    with $FunctionalFamilyOverride<double, String?> {
  AddPurchaseGrandTotalFamily._()
    : super(
        retry: null,
        name: r'addPurchaseGrandTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddPurchaseGrandTotalProvider call({String? billId}) =>
      AddPurchaseGrandTotalProvider._(argument: billId, from: this);

  @override
  String toString() => r'addPurchaseGrandTotalProvider';
}
