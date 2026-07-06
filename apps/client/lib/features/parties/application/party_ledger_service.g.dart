// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_ledger_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(partyLedgerService)
final partyLedgerServiceProvider = PartyLedgerServiceProvider._();

final class PartyLedgerServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PartyLedgerService>,
          PartyLedgerService,
          FutureOr<PartyLedgerService>
        >
    with
        $FutureModifier<PartyLedgerService>,
        $FutureProvider<PartyLedgerService> {
  PartyLedgerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyLedgerServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyLedgerServiceHash();

  @$internal
  @override
  $FutureProviderElement<PartyLedgerService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PartyLedgerService> create(Ref ref) {
    return partyLedgerService(ref);
  }
}

String _$partyLedgerServiceHash() =>
    r'477a72680bab55138162a27daa6660461d01c462';

@ProviderFor(PartyLedger)
final partyLedgerProvider = PartyLedgerFamily._();

final class PartyLedgerProvider
    extends $AsyncNotifierProvider<PartyLedger, PartyLedgerModel> {
  PartyLedgerProvider._({
    required PartyLedgerFamily super.from,
    required PartyLedgerKey super.argument,
  }) : super(
         retry: null,
         name: r'partyLedgerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyLedgerHash();

  @override
  String toString() {
    return r'partyLedgerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PartyLedger create() => PartyLedger();

  @override
  bool operator ==(Object other) {
    return other is PartyLedgerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyLedgerHash() => r'2e2a46de22dac2dd3c00b3493eb75eee56166f87';

final class PartyLedgerFamily extends $Family
    with
        $ClassFamilyOverride<
          PartyLedger,
          AsyncValue<PartyLedgerModel>,
          PartyLedgerModel,
          FutureOr<PartyLedgerModel>,
          PartyLedgerKey
        > {
  PartyLedgerFamily._()
    : super(
        retry: null,
        name: r'partyLedgerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PartyLedgerProvider call(PartyLedgerKey key) =>
      PartyLedgerProvider._(argument: key, from: this);

  @override
  String toString() => r'partyLedgerProvider';
}

abstract class _$PartyLedger extends $AsyncNotifier<PartyLedgerModel> {
  late final _$args = ref.$arg as PartyLedgerKey;
  PartyLedgerKey get key => _$args;

  FutureOr<PartyLedgerModel> build(PartyLedgerKey key);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PartyLedgerModel>, PartyLedgerModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PartyLedgerModel>, PartyLedgerModel>,
              AsyncValue<PartyLedgerModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
