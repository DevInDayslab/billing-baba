// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_note_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreditNoteForm)
final creditNoteFormProvider = CreditNoteFormProvider._();

final class CreditNoteFormProvider
    extends $NotifierProvider<CreditNoteForm, CreditNoteFormState> {
  CreditNoteFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditNoteFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditNoteFormHash();

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
}

String _$creditNoteFormHash() => r'e95390bb9c2c6ecc9b010f7483e8582b5229f674';

abstract class _$CreditNoteForm extends $Notifier<CreditNoteFormState> {
  CreditNoteFormState build();
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
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SavedCreditNotesNotifier)
final savedCreditNotesProvider = SavedCreditNotesNotifierProvider._();

final class SavedCreditNotesNotifierProvider
    extends $NotifierProvider<SavedCreditNotesNotifier, List<SavedCreditNote>> {
  SavedCreditNotesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedCreditNotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedCreditNotesNotifierHash();

  @$internal
  @override
  SavedCreditNotesNotifier create() => SavedCreditNotesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SavedCreditNote> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SavedCreditNote>>(value),
    );
  }
}

String _$savedCreditNotesNotifierHash() =>
    r'f2efdb64eadf32106980f01eade6ba1e1fb1e4c2';

abstract class _$SavedCreditNotesNotifier
    extends $Notifier<List<SavedCreditNote>> {
  List<SavedCreditNote> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<SavedCreditNote>, List<SavedCreditNote>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SavedCreditNote>, List<SavedCreditNote>>,
              List<SavedCreditNote>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(creditNoteGrandTotal)
final creditNoteGrandTotalProvider = CreditNoteGrandTotalProvider._();

final class CreditNoteGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  CreditNoteGrandTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditNoteGrandTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditNoteGrandTotalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return creditNoteGrandTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$creditNoteGrandTotalHash() =>
    r'f98ee409c2c30e8c22620ec38ff5ed3735bad386';
