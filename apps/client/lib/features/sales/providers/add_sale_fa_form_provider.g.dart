// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_sale_fa_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddSaleFaForm)
final addSaleFaFormProvider = AddSaleFaFormFamily._();

final class AddSaleFaFormProvider
    extends $NotifierProvider<AddSaleFaForm, AddSaleFaFormState> {
  AddSaleFaFormProvider._({
    required AddSaleFaFormFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addSaleFaFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addSaleFaFormHash();

  @override
  String toString() {
    return r'addSaleFaFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AddSaleFaForm create() => AddSaleFaForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddSaleFaFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddSaleFaFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddSaleFaFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addSaleFaFormHash() => r'0bdb49922c0087c81c4a554f3d7ace89731f99e7';

final class AddSaleFaFormFamily extends $Family
    with
        $ClassFamilyOverride<
          AddSaleFaForm,
          AddSaleFaFormState,
          AddSaleFaFormState,
          AddSaleFaFormState,
          String
        > {
  AddSaleFaFormFamily._()
    : super(
        retry: null,
        name: r'addSaleFaFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddSaleFaFormProvider call({String sessionKey = 'default'}) =>
      AddSaleFaFormProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'addSaleFaFormProvider';
}

abstract class _$AddSaleFaForm extends $Notifier<AddSaleFaFormState> {
  late final _$args = ref.$arg as String;
  String get sessionKey => _$args;

  AddSaleFaFormState build({String sessionKey = 'default'});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AddSaleFaFormState, AddSaleFaFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddSaleFaFormState, AddSaleFaFormState>,
              AddSaleFaFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(sessionKey: _$args));
  }
}

@ProviderFor(addSaleFaTotalTax)
final addSaleFaTotalTaxProvider = AddSaleFaTotalTaxFamily._();

final class AddSaleFaTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddSaleFaTotalTaxProvider._({
    required AddSaleFaTotalTaxFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addSaleFaTotalTaxProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addSaleFaTotalTaxHash();

  @override
  String toString() {
    return r'addSaleFaTotalTaxProvider'
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
    return addSaleFaTotalTax(ref, sessionKey: argument);
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
    return other is AddSaleFaTotalTaxProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addSaleFaTotalTaxHash() => r'1da0a1cb9f4714454a1fe9171bbe26ff601d88d3';

final class AddSaleFaTotalTaxFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  AddSaleFaTotalTaxFamily._()
    : super(
        retry: null,
        name: r'addSaleFaTotalTaxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddSaleFaTotalTaxProvider call({String sessionKey = 'default'}) =>
      AddSaleFaTotalTaxProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'addSaleFaTotalTaxProvider';
}

@ProviderFor(addSaleFaGrandTotal)
final addSaleFaGrandTotalProvider = AddSaleFaGrandTotalFamily._();

final class AddSaleFaGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddSaleFaGrandTotalProvider._({
    required AddSaleFaGrandTotalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addSaleFaGrandTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addSaleFaGrandTotalHash();

  @override
  String toString() {
    return r'addSaleFaGrandTotalProvider'
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
    return addSaleFaGrandTotal(ref, sessionKey: argument);
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
    return other is AddSaleFaGrandTotalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addSaleFaGrandTotalHash() =>
    r'0373d81eab85d803ef7b8db902427210f89ebade';

final class AddSaleFaGrandTotalFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  AddSaleFaGrandTotalFamily._()
    : super(
        retry: null,
        name: r'addSaleFaGrandTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddSaleFaGrandTotalProvider call({String sessionKey = 'default'}) =>
      AddSaleFaGrandTotalProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'addSaleFaGrandTotalProvider';
}
