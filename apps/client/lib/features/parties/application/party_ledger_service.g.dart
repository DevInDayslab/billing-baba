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

@ProviderFor(PartyTimeline)
final partyTimelineProvider = PartyTimelineFamily._();

final class PartyTimelineProvider
    extends $AsyncNotifierProvider<PartyTimeline, PartyLedgerModel> {
  PartyTimelineProvider._({
    required PartyTimelineFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'partyTimelineProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyTimelineHash();

  @override
  String toString() {
    return r'partyTimelineProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PartyTimeline create() => PartyTimeline();

  @override
  bool operator ==(Object other) {
    return other is PartyTimelineProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyTimelineHash() => r'fd53c57f1a3205e309c20968fe884d234901348e';

final class PartyTimelineFamily extends $Family
    with
        $ClassFamilyOverride<
          PartyTimeline,
          AsyncValue<PartyLedgerModel>,
          PartyLedgerModel,
          FutureOr<PartyLedgerModel>,
          String
        > {
  PartyTimelineFamily._()
    : super(
        retry: null,
        name: r'partyTimelineProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PartyTimelineProvider call(String partyId) =>
      PartyTimelineProvider._(argument: partyId, from: this);

  @override
  String toString() => r'partyTimelineProvider';
}

abstract class _$PartyTimeline extends $AsyncNotifier<PartyLedgerModel> {
  late final _$args = ref.$arg as String;
  String get partyId => _$args;

  FutureOr<PartyLedgerModel> build(String partyId);
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

@ProviderFor(PartyLedger)
final partyLedgerProvider = PartyLedgerFamily._();

final class PartyLedgerProvider
    extends $AsyncNotifierProvider<PartyLedger, PartyLedgerModel> {
  PartyLedgerProvider._({
    required PartyLedgerFamily super.from,
    required String super.argument,
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

String _$partyLedgerHash() => r'0a9fd32d17befc9939ccac5080107dd11869a4e9';

final class PartyLedgerFamily extends $Family
    with
        $ClassFamilyOverride<
          PartyLedger,
          AsyncValue<PartyLedgerModel>,
          PartyLedgerModel,
          FutureOr<PartyLedgerModel>,
          String
        > {
  PartyLedgerFamily._()
    : super(
        retry: null,
        name: r'partyLedgerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PartyLedgerProvider call(String partyId) =>
      PartyLedgerProvider._(argument: partyId, from: this);

  @override
  String toString() => r'partyLedgerProvider';
}

abstract class _$PartyLedger extends $AsyncNotifier<PartyLedgerModel> {
  late final _$args = ref.$arg as String;
  String get partyId => _$args;

  FutureOr<PartyLedgerModel> build(String partyId);
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
