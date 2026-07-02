// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_purchase_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddPurchaseForm)
final addPurchaseFormProvider = AddPurchaseFormProvider._();

final class AddPurchaseFormProvider
    extends $NotifierProvider<AddPurchaseForm, AddPurchaseFormState> {
  AddPurchaseFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addPurchaseFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseFormHash();

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
}

String _$addPurchaseFormHash() => r'07b064f79aa85dded3b0008f5cf4b7f74c02364f';

abstract class _$AddPurchaseForm extends $Notifier<AddPurchaseFormState> {
  AddPurchaseFormState build();
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
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(addPurchaseTotalTax)
final addPurchaseTotalTaxProvider = AddPurchaseTotalTaxProvider._();

final class AddPurchaseTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddPurchaseTotalTaxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addPurchaseTotalTaxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseTotalTaxHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return addPurchaseTotalTax(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$addPurchaseTotalTaxHash() =>
    r'8980d4ec5d0373303f2b24d919b889c76acef127';

@ProviderFor(addPurchaseGrandTotal)
final addPurchaseGrandTotalProvider = AddPurchaseGrandTotalProvider._();

final class AddPurchaseGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddPurchaseGrandTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addPurchaseGrandTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseGrandTotalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return addPurchaseGrandTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$addPurchaseGrandTotalHash() =>
    r'1d20b7cfec2b7bff56c3c614e480483be909cbfd';
