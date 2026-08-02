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
    r'06b976ccc44bb9f1dd6802a1033d17afe30307cf';

@ProviderFor(partyLedgerBusinessId)
final partyLedgerBusinessIdProvider = PartyLedgerBusinessIdProvider._();

final class PartyLedgerBusinessIdProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  PartyLedgerBusinessIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyLedgerBusinessIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyLedgerBusinessIdHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return partyLedgerBusinessId(ref);
  }
}

String _$partyLedgerBusinessIdHash() =>
    r'76286aab1d3a454518738effe90edb70a5ba85f0';

@ProviderFor(PartyProfileProjection)
final partyProfileProjectionProvider = PartyProfileProjectionFamily._();

final class PartyProfileProjectionProvider
    extends $AsyncNotifierProvider<PartyProfileProjection, PartyProjection> {
  PartyProfileProjectionProvider._({
    required PartyProfileProjectionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'partyProfileProjectionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyProfileProjectionHash();

  @override
  String toString() {
    return r'partyProfileProjectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PartyProfileProjection create() => PartyProfileProjection();

  @override
  bool operator ==(Object other) {
    return other is PartyProfileProjectionProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyProfileProjectionHash() =>
    r'36ac3770939a7c682a6014279bcd2cf5008eb7bb';

final class PartyProfileProjectionFamily extends $Family
    with
        $ClassFamilyOverride<
          PartyProfileProjection,
          AsyncValue<PartyProjection>,
          PartyProjection,
          FutureOr<PartyProjection>,
          String
        > {
  PartyProfileProjectionFamily._()
    : super(
        retry: null,
        name: r'partyProfileProjectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  PartyProfileProjectionProvider call(String partyId) =>
      PartyProfileProjectionProvider._(argument: partyId, from: this);

  @override
  String toString() => r'partyProfileProjectionProvider';
}

abstract class _$PartyProfileProjection
    extends $AsyncNotifier<PartyProjection> {
  late final _$args = ref.$arg as String;
  String get partyId => _$args;

  FutureOr<PartyProjection> build(String partyId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PartyProjection>, PartyProjection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PartyProjection>, PartyProjection>,
              AsyncValue<PartyProjection>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

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

String _$partyTimelineHash() => r'2cb8521a08b965a1ae857212379364d0b49d2f6f';

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

String _$partyLedgerHash() => r'07468f2daba0e1fc71fe1afba47fdbd734596848';

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
