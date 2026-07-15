// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_sale_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddSaleForm)
final addSaleFormProvider = AddSaleFormFamily._();

final class AddSaleFormProvider
    extends $NotifierProvider<AddSaleForm, AddSaleFormState> {
  AddSaleFormProvider._({
    required AddSaleFormFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addSaleFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addSaleFormHash();

  @override
  String toString() {
    return r'addSaleFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AddSaleForm create() => AddSaleForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddSaleFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddSaleFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddSaleFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addSaleFormHash() => r'f2805206b497697cbd0949b33aaa0e6a7ecaefbd';

final class AddSaleFormFamily extends $Family
    with
        $ClassFamilyOverride<
          AddSaleForm,
          AddSaleFormState,
          AddSaleFormState,
          AddSaleFormState,
          String
        > {
  AddSaleFormFamily._()
    : super(
        retry: null,
        name: r'addSaleFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddSaleFormProvider call({String sessionKey = 'default'}) =>
      AddSaleFormProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'addSaleFormProvider';
}

abstract class _$AddSaleForm extends $Notifier<AddSaleFormState> {
  late final _$args = ref.$arg as String;
  String get sessionKey => _$args;

  AddSaleFormState build({String sessionKey = 'default'});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AddSaleFormState, AddSaleFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddSaleFormState, AddSaleFormState>,
              AddSaleFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(sessionKey: _$args));
  }
}

@ProviderFor(addSaleSubtotal)
final addSaleSubtotalProvider = AddSaleSubtotalFamily._();

final class AddSaleSubtotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddSaleSubtotalProvider._({
    required AddSaleSubtotalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addSaleSubtotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addSaleSubtotalHash();

  @override
  String toString() {
    return r'addSaleSubtotalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as String;
    return addSaleSubtotal(ref, sessionKey: argument);
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
    return other is AddSaleSubtotalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addSaleSubtotalHash() => r'bd6fcede1e437ef366583a7f4fe2e20136770a2a';

final class AddSaleSubtotalFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  AddSaleSubtotalFamily._()
    : super(
        retry: null,
        name: r'addSaleSubtotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddSaleSubtotalProvider call({String sessionKey = 'default'}) =>
      AddSaleSubtotalProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'addSaleSubtotalProvider';
}

@ProviderFor(addSaleTotalTax)
final addSaleTotalTaxProvider = AddSaleTotalTaxFamily._();

final class AddSaleTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddSaleTotalTaxProvider._({
    required AddSaleTotalTaxFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addSaleTotalTaxProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addSaleTotalTaxHash();

  @override
  String toString() {
    return r'addSaleTotalTaxProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as String;
    return addSaleTotalTax(ref, sessionKey: argument);
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
    return other is AddSaleTotalTaxProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addSaleTotalTaxHash() => r'7db6eab935d6b911f8549b9c281422cf5e5339f0';

final class AddSaleTotalTaxFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  AddSaleTotalTaxFamily._()
    : super(
        retry: null,
        name: r'addSaleTotalTaxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddSaleTotalTaxProvider call({String sessionKey = 'default'}) =>
      AddSaleTotalTaxProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'addSaleTotalTaxProvider';
}

@ProviderFor(addSaleGrandTotal)
final addSaleGrandTotalProvider = AddSaleGrandTotalFamily._();

final class AddSaleGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddSaleGrandTotalProvider._({
    required AddSaleGrandTotalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addSaleGrandTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addSaleGrandTotalHash();

  @override
  String toString() {
    return r'addSaleGrandTotalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as String;
    return addSaleGrandTotal(ref, sessionKey: argument);
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
    return other is AddSaleGrandTotalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addSaleGrandTotalHash() => r'70c206bbf8a7cdfd3cbafd836be5a7ed2211b3f6';

final class AddSaleGrandTotalFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  AddSaleGrandTotalFamily._()
    : super(
        retry: null,
        name: r'addSaleGrandTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddSaleGrandTotalProvider call({String sessionKey = 'default'}) =>
      AddSaleGrandTotalProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'addSaleGrandTotalProvider';
}
