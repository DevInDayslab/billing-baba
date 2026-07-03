// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_purchase_fa_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddPurchaseFaForm)
final addPurchaseFaFormProvider = AddPurchaseFaFormProvider._();

final class AddPurchaseFaFormProvider
    extends $NotifierProvider<AddPurchaseFaForm, AddPurchaseFaFormState> {
  AddPurchaseFaFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addPurchaseFaFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseFaFormHash();

  @$internal
  @override
  AddPurchaseFaForm create() => AddPurchaseFaForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddPurchaseFaFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddPurchaseFaFormState>(value),
    );
  }
}

String _$addPurchaseFaFormHash() => r'e97fb738afc8f4c9a9babaad2e0fb7ae5e5399a3';

abstract class _$AddPurchaseFaForm extends $Notifier<AddPurchaseFaFormState> {
  AddPurchaseFaFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AddPurchaseFaFormState, AddPurchaseFaFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddPurchaseFaFormState, AddPurchaseFaFormState>,
              AddPurchaseFaFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(addPurchaseFaTotalTax)
final addPurchaseFaTotalTaxProvider = AddPurchaseFaTotalTaxProvider._();

final class AddPurchaseFaTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddPurchaseFaTotalTaxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addPurchaseFaTotalTaxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseFaTotalTaxHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return addPurchaseFaTotalTax(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$addPurchaseFaTotalTaxHash() =>
    r'70146c6e60b7ead33f5b370791a0af66e5168fdc';

@ProviderFor(addPurchaseFaGrandTotal)
final addPurchaseFaGrandTotalProvider = AddPurchaseFaGrandTotalProvider._();

final class AddPurchaseFaGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddPurchaseFaGrandTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addPurchaseFaGrandTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseFaGrandTotalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return addPurchaseFaGrandTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$addPurchaseFaGrandTotalHash() =>
    r'323102f21597cdda24d05bd023f79309ac570f9d';
