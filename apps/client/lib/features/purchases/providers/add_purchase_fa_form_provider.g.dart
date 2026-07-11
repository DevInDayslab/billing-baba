// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_purchase_fa_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddPurchaseFaForm)
final addPurchaseFaFormProvider = AddPurchaseFaFormFamily._();

final class AddPurchaseFaFormProvider
    extends $NotifierProvider<AddPurchaseFaForm, AddPurchaseFaFormState> {
  AddPurchaseFaFormProvider._({
    required AddPurchaseFaFormFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addPurchaseFaFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseFaFormHash();

  @override
  String toString() {
    return r'addPurchaseFaFormProvider'
        ''
        '($argument)';
  }

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

  @override
  bool operator ==(Object other) {
    return other is AddPurchaseFaFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addPurchaseFaFormHash() => r'60bfb493430986ae52e92bf1547595a98f5e7ed1';

final class AddPurchaseFaFormFamily extends $Family
    with
        $ClassFamilyOverride<
          AddPurchaseFaForm,
          AddPurchaseFaFormState,
          AddPurchaseFaFormState,
          AddPurchaseFaFormState,
          String?
        > {
  AddPurchaseFaFormFamily._()
    : super(
        retry: null,
        name: r'addPurchaseFaFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddPurchaseFaFormProvider call({String? batchId}) =>
      AddPurchaseFaFormProvider._(argument: batchId, from: this);

  @override
  String toString() => r'addPurchaseFaFormProvider';
}

abstract class _$AddPurchaseFaForm extends $Notifier<AddPurchaseFaFormState> {
  late final _$args = ref.$arg as String?;
  String? get batchId => _$args;

  AddPurchaseFaFormState build({String? batchId});
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
    return element.handleCreate(ref, () => build(batchId: _$args));
  }
}

@ProviderFor(addPurchaseFaTotalTax)
final addPurchaseFaTotalTaxProvider = AddPurchaseFaTotalTaxFamily._();

final class AddPurchaseFaTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddPurchaseFaTotalTaxProvider._({
    required AddPurchaseFaTotalTaxFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addPurchaseFaTotalTaxProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseFaTotalTaxHash();

  @override
  String toString() {
    return r'addPurchaseFaTotalTaxProvider'
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
    return addPurchaseFaTotalTax(ref, batchId: argument);
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
    return other is AddPurchaseFaTotalTaxProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addPurchaseFaTotalTaxHash() =>
    r'c0eda9cee25eb67dd863e009ca3b51e714a37856';

final class AddPurchaseFaTotalTaxFamily extends $Family
    with $FunctionalFamilyOverride<double, String?> {
  AddPurchaseFaTotalTaxFamily._()
    : super(
        retry: null,
        name: r'addPurchaseFaTotalTaxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddPurchaseFaTotalTaxProvider call({String? batchId}) =>
      AddPurchaseFaTotalTaxProvider._(argument: batchId, from: this);

  @override
  String toString() => r'addPurchaseFaTotalTaxProvider';
}

@ProviderFor(addPurchaseFaGrandTotal)
final addPurchaseFaGrandTotalProvider = AddPurchaseFaGrandTotalFamily._();

final class AddPurchaseFaGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddPurchaseFaGrandTotalProvider._({
    required AddPurchaseFaGrandTotalFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addPurchaseFaGrandTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addPurchaseFaGrandTotalHash();

  @override
  String toString() {
    return r'addPurchaseFaGrandTotalProvider'
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
    return addPurchaseFaGrandTotal(ref, batchId: argument);
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
    return other is AddPurchaseFaGrandTotalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addPurchaseFaGrandTotalHash() =>
    r'8cf3c2f52ec550e6d6220c33a5e95258ceace4da';

final class AddPurchaseFaGrandTotalFamily extends $Family
    with $FunctionalFamilyOverride<double, String?> {
  AddPurchaseFaGrandTotalFamily._()
    : super(
        retry: null,
        name: r'addPurchaseFaGrandTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddPurchaseFaGrandTotalProvider call({String? batchId}) =>
      AddPurchaseFaGrandTotalProvider._(argument: batchId, from: this);

  @override
  String toString() => r'addPurchaseFaGrandTotalProvider';
}
