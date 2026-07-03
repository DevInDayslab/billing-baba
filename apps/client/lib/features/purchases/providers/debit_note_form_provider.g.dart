// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debit_note_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DebitNoteForm)
final debitNoteFormProvider = DebitNoteFormProvider._();

final class DebitNoteFormProvider
    extends $NotifierProvider<DebitNoteForm, DebitNoteFormState> {
  DebitNoteFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debitNoteFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debitNoteFormHash();

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
}

String _$debitNoteFormHash() => r'caa03627a2227c0f3b29391ccc39dc5ab10bc0aa';

abstract class _$DebitNoteForm extends $Notifier<DebitNoteFormState> {
  DebitNoteFormState build();
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
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SavedDebitNotesNotifier)
final savedDebitNotesProvider = SavedDebitNotesNotifierProvider._();

final class SavedDebitNotesNotifierProvider
    extends $NotifierProvider<SavedDebitNotesNotifier, List<SavedDebitNote>> {
  SavedDebitNotesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedDebitNotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedDebitNotesNotifierHash();

  @$internal
  @override
  SavedDebitNotesNotifier create() => SavedDebitNotesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SavedDebitNote> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SavedDebitNote>>(value),
    );
  }
}

String _$savedDebitNotesNotifierHash() =>
    r'd688e934c1dd5e3ff78323885097f3eb4ac39a5c';

abstract class _$SavedDebitNotesNotifier
    extends $Notifier<List<SavedDebitNote>> {
  List<SavedDebitNote> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<SavedDebitNote>, List<SavedDebitNote>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SavedDebitNote>, List<SavedDebitNote>>,
              List<SavedDebitNote>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(debitNoteGrandTotal)
final debitNoteGrandTotalProvider = DebitNoteGrandTotalProvider._();

final class DebitNoteGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  DebitNoteGrandTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debitNoteGrandTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debitNoteGrandTotalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return debitNoteGrandTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$debitNoteGrandTotalHash() =>
    r'7e6bb67e33915fba34bb95e4c2aeb0eeeffa3346';
