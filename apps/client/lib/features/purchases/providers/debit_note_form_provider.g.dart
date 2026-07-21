// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debit_note_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DebitNoteForm)
final debitNoteFormProvider = DebitNoteFormFamily._();

final class DebitNoteFormProvider
    extends $NotifierProvider<DebitNoteForm, DebitNoteFormState> {
  DebitNoteFormProvider._({
    required DebitNoteFormFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'debitNoteFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$debitNoteFormHash();

  @override
  String toString() {
    return r'debitNoteFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DebitNoteForm create() => DebitNoteForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DebitNoteFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DebitNoteFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DebitNoteFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$debitNoteFormHash() => r'89454a9781ef25a3a2fcb672613eea44ba9820cf';

final class DebitNoteFormFamily extends $Family
    with
        $ClassFamilyOverride<
          DebitNoteForm,
          DebitNoteFormState,
          DebitNoteFormState,
          DebitNoteFormState,
          String?
        > {
  DebitNoteFormFamily._()
    : super(
        retry: null,
        name: r'debitNoteFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DebitNoteFormProvider call({String? debitNoteId}) =>
      DebitNoteFormProvider._(argument: debitNoteId, from: this);

  @override
  String toString() => r'debitNoteFormProvider';
}

abstract class _$DebitNoteForm extends $Notifier<DebitNoteFormState> {
  late final _$args = ref.$arg as String?;
  String? get debitNoteId => _$args;

  DebitNoteFormState build({String? debitNoteId});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DebitNoteFormState, DebitNoteFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DebitNoteFormState, DebitNoteFormState>,
              DebitNoteFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(debitNoteId: _$args));
  }
}

@ProviderFor(debitNoteGrandTotal)
final debitNoteGrandTotalProvider = DebitNoteGrandTotalFamily._();

final class DebitNoteGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  DebitNoteGrandTotalProvider._({
    required DebitNoteGrandTotalFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'debitNoteGrandTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$debitNoteGrandTotalHash();

  @override
  String toString() {
    return r'debitNoteGrandTotalProvider'
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
    return debitNoteGrandTotal(ref, debitNoteId: argument);
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
    return other is DebitNoteGrandTotalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$debitNoteGrandTotalHash() =>
    r'39891d69269fe44a7e70b07f81873ce02c74ca57';

final class DebitNoteGrandTotalFamily extends $Family
    with $FunctionalFamilyOverride<double, String?> {
  DebitNoteGrandTotalFamily._()
    : super(
        retry: null,
        name: r'debitNoteGrandTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DebitNoteGrandTotalProvider call({String? debitNoteId}) =>
      DebitNoteGrandTotalProvider._(argument: debitNoteId, from: this);

  @override
  String toString() => r'debitNoteGrandTotalProvider';
}
