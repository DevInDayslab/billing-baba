// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_note_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreditNoteForm)
final creditNoteFormProvider = CreditNoteFormFamily._();

final class CreditNoteFormProvider
    extends $NotifierProvider<CreditNoteForm, CreditNoteFormState> {
  CreditNoteFormProvider._({
    required CreditNoteFormFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'creditNoteFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creditNoteFormHash();

  @override
  String toString() {
    return r'creditNoteFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CreditNoteForm create() => CreditNoteForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreditNoteFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreditNoteFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CreditNoteFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creditNoteFormHash() => r'638d7ebf455a7238f9fd538675f0f002f5fa8b8d';

final class CreditNoteFormFamily extends $Family
    with
        $ClassFamilyOverride<
          CreditNoteForm,
          CreditNoteFormState,
          CreditNoteFormState,
          CreditNoteFormState,
          String
        > {
  CreditNoteFormFamily._()
    : super(
        retry: null,
        name: r'creditNoteFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreditNoteFormProvider call({String sessionKey = 'default'}) =>
      CreditNoteFormProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'creditNoteFormProvider';
}

abstract class _$CreditNoteForm extends $Notifier<CreditNoteFormState> {
  late final _$args = ref.$arg as String;
  String get sessionKey => _$args;

  CreditNoteFormState build({String sessionKey = 'default'});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CreditNoteFormState, CreditNoteFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreditNoteFormState, CreditNoteFormState>,
              CreditNoteFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(sessionKey: _$args));
  }
}

@ProviderFor(creditNoteTotalTax)
final creditNoteTotalTaxProvider = CreditNoteTotalTaxFamily._();

final class CreditNoteTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  CreditNoteTotalTaxProvider._({
    required CreditNoteTotalTaxFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'creditNoteTotalTaxProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creditNoteTotalTaxHash();

  @override
  String toString() {
    return r'creditNoteTotalTaxProvider'
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
    return creditNoteTotalTax(ref, sessionKey: argument);
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
    return other is CreditNoteTotalTaxProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creditNoteTotalTaxHash() =>
    r'b5229e102862bb17ff9ea522575070dfee35fa45';

final class CreditNoteTotalTaxFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  CreditNoteTotalTaxFamily._()
    : super(
        retry: null,
        name: r'creditNoteTotalTaxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreditNoteTotalTaxProvider call({String sessionKey = 'default'}) =>
      CreditNoteTotalTaxProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'creditNoteTotalTaxProvider';
}

@ProviderFor(creditNoteGrandTotal)
final creditNoteGrandTotalProvider = CreditNoteGrandTotalFamily._();

final class CreditNoteGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  CreditNoteGrandTotalProvider._({
    required CreditNoteGrandTotalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'creditNoteGrandTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creditNoteGrandTotalHash();

  @override
  String toString() {
    return r'creditNoteGrandTotalProvider'
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
    return creditNoteGrandTotal(ref, sessionKey: argument);
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
    return other is CreditNoteGrandTotalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creditNoteGrandTotalHash() =>
    r'd86181c71609a0ad636913936d461b5aa91fc377';

final class CreditNoteGrandTotalFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  CreditNoteGrandTotalFamily._()
    : super(
        retry: null,
        name: r'creditNoteGrandTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreditNoteGrandTotalProvider call({String sessionKey = 'default'}) =>
      CreditNoteGrandTotalProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'creditNoteGrandTotalProvider';
}
