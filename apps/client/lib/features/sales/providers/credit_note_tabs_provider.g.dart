// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_note_tabs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreditNoteTabs)
final creditNoteTabsProvider = CreditNoteTabsFamily._();

final class CreditNoteTabsProvider
    extends $NotifierProvider<CreditNoteTabs, CreditNoteTabsState> {
  CreditNoteTabsProvider._({
    required CreditNoteTabsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'creditNoteTabsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creditNoteTabsHash();

  @override
  String toString() {
    return r'creditNoteTabsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CreditNoteTabs create() => CreditNoteTabs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreditNoteTabsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreditNoteTabsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CreditNoteTabsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creditNoteTabsHash() => r'b2c3d4e5f6789012345678abcdef01234567890';

final class CreditNoteTabsFamily extends $Family
    with
        $ClassFamilyOverride<
          CreditNoteTabs,
          CreditNoteTabsState,
          CreditNoteTabsState,
          CreditNoteTabsState,
          String?
        > {
  CreditNoteTabsFamily._()
    : super(
        retry: null,
        name: r'creditNoteTabsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreditNoteTabsProvider call({String? initialDocumentId}) =>
      CreditNoteTabsProvider._(argument: initialDocumentId, from: this);

  @override
  String toString() => r'creditNoteTabsProvider';
}

abstract class _$CreditNoteTabs extends $Notifier<CreditNoteTabsState> {
  late final _$args = ref.$arg as String?;
  String? get initialDocumentId => _$args;

  CreditNoteTabsState build({String? initialDocumentId});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CreditNoteTabsState, CreditNoteTabsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreditNoteTabsState, CreditNoteTabsState>,
              CreditNoteTabsState,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(initialDocumentId: _$args),
    );
  }
}
