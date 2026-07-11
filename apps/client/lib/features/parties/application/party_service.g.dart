// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(partyService)
final partyServiceProvider = PartyServiceProvider._();

final class PartyServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PartyService>,
          PartyService,
          FutureOr<PartyService>
        >
    with $FutureModifier<PartyService>, $FutureProvider<PartyService> {
  PartyServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyServiceHash();

  @$internal
  @override
  $FutureProviderElement<PartyService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PartyService> create(Ref ref) {
    return partyService(ref);
  }
}

String _$partyServiceHash() => r'3e85483e3c4ff838ab6476e607e5a07882e14681';

@ProviderFor(PartyList)
final partyListProvider = PartyListProvider._();

final class PartyListProvider
    extends $AsyncNotifierProvider<PartyList, List<PartyModel>> {
  PartyListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyListHash();

  @$internal
  @override
  PartyList create() => PartyList();
}

String _$partyListHash() => r'66ed49197e26a2144fb682c1a3012b01719b13c9';

abstract class _$PartyList extends $AsyncNotifier<List<PartyModel>> {
  FutureOr<List<PartyModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<PartyModel>>, List<PartyModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PartyModel>>, List<PartyModel>>,
              AsyncValue<List<PartyModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PartyDetail)
final partyDetailProvider = PartyDetailFamily._();

final class PartyDetailProvider
    extends $AsyncNotifierProvider<PartyDetail, PartyModel> {
  PartyDetailProvider._({
    required PartyDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'partyDetailProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyDetailHash();

  @override
  String toString() {
    return r'partyDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PartyDetail create() => PartyDetail();

  @override
  bool operator ==(Object other) {
    return other is PartyDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyDetailHash() => r'f398c681b37ca2247c8c52dfe39ba04659d1f0a8';

final class PartyDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          PartyDetail,
          AsyncValue<PartyModel>,
          PartyModel,
          FutureOr<PartyModel>,
          String
        > {
  PartyDetailFamily._()
    : super(
        retry: null,
        name: r'partyDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  PartyDetailProvider call(String partyId) =>
      PartyDetailProvider._(argument: partyId, from: this);

  @override
  String toString() => r'partyDetailProvider';
}

abstract class _$PartyDetail extends $AsyncNotifier<PartyModel> {
  late final _$args = ref.$arg as String;
  String get partyId => _$args;

  FutureOr<PartyModel> build(String partyId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PartyModel>, PartyModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PartyModel>, PartyModel>,
              AsyncValue<PartyModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(PartyBackendSearch)
final partyBackendSearchProvider = PartyBackendSearchProvider._();

final class PartyBackendSearchProvider
    extends $NotifierProvider<PartyBackendSearch, String> {
  PartyBackendSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyBackendSearchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyBackendSearchHash();

  @$internal
  @override
  PartyBackendSearch create() => PartyBackendSearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$partyBackendSearchHash() =>
    r'3a7ec4ddc4d452e07badadf6d80443b17cf5e339';

abstract class _$PartyBackendSearch extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(partiesUsingCache)
final partiesUsingCacheProvider = PartiesUsingCacheProvider._();

final class PartiesUsingCacheProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  PartiesUsingCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partiesUsingCacheProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partiesUsingCacheHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return partiesUsingCache(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$partiesUsingCacheHash() => r'1565b53c077b8b69b0e126375adf7dd05a6bb25c';
