// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hidden_ledger_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hiddenLedgerService)
final hiddenLedgerServiceProvider = HiddenLedgerServiceProvider._();

final class HiddenLedgerServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<HiddenLedgerService>,
          HiddenLedgerService,
          FutureOr<HiddenLedgerService>
        >
    with
        $FutureModifier<HiddenLedgerService>,
        $FutureProvider<HiddenLedgerService> {
  HiddenLedgerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hiddenLedgerServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hiddenLedgerServiceHash();

  @$internal
  @override
  $FutureProviderElement<HiddenLedgerService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HiddenLedgerService> create(Ref ref) {
    return hiddenLedgerService(ref);
  }
}

String _$hiddenLedgerServiceHash() =>
    r'52e725010fec55a35489cbed7c06db0904c44723';

@ProviderFor(HiddenLedgerFiltersState)
final hiddenLedgerFiltersStateProvider = HiddenLedgerFiltersStateProvider._();

final class HiddenLedgerFiltersStateProvider
    extends $NotifierProvider<HiddenLedgerFiltersState, HiddenLedgerFilters> {
  HiddenLedgerFiltersStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hiddenLedgerFiltersStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hiddenLedgerFiltersStateHash();

  @$internal
  @override
  HiddenLedgerFiltersState create() => HiddenLedgerFiltersState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HiddenLedgerFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HiddenLedgerFilters>(value),
    );
  }
}

String _$hiddenLedgerFiltersStateHash() =>
    r'5ccd73055747d75c090c422bf6243013727e516b';

abstract class _$HiddenLedgerFiltersState
    extends $Notifier<HiddenLedgerFilters> {
  HiddenLedgerFilters build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HiddenLedgerFilters, HiddenLedgerFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HiddenLedgerFilters, HiddenLedgerFilters>,
              HiddenLedgerFilters,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(HiddenLedgerList)
final hiddenLedgerListProvider = HiddenLedgerListProvider._();

final class HiddenLedgerListProvider
    extends
        $AsyncNotifierProvider<HiddenLedgerList, PaginatedHiddenLedgerEntries> {
  HiddenLedgerListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hiddenLedgerListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hiddenLedgerListHash();

  @$internal
  @override
  HiddenLedgerList create() => HiddenLedgerList();
}

String _$hiddenLedgerListHash() => r'598f001282b4b67acf2c07ca200c99fde4bda00d';

abstract class _$HiddenLedgerList
    extends $AsyncNotifier<PaginatedHiddenLedgerEntries> {
  FutureOr<PaginatedHiddenLedgerEntries> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedHiddenLedgerEntries>,
              PaginatedHiddenLedgerEntries
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedHiddenLedgerEntries>,
                PaginatedHiddenLedgerEntries
              >,
              AsyncValue<PaginatedHiddenLedgerEntries>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(partyHiddenLedgerSummary)
final partyHiddenLedgerSummaryProvider = PartyHiddenLedgerSummaryFamily._();

final class PartyHiddenLedgerSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<HiddenLedgerPartySummaryModel>,
          HiddenLedgerPartySummaryModel,
          FutureOr<HiddenLedgerPartySummaryModel>
        >
    with
        $FutureModifier<HiddenLedgerPartySummaryModel>,
        $FutureProvider<HiddenLedgerPartySummaryModel> {
  PartyHiddenLedgerSummaryProvider._({
    required PartyHiddenLedgerSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'partyHiddenLedgerSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyHiddenLedgerSummaryHash();

  @override
  String toString() {
    return r'partyHiddenLedgerSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HiddenLedgerPartySummaryModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HiddenLedgerPartySummaryModel> create(Ref ref) {
    final argument = this.argument as String;
    return partyHiddenLedgerSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PartyHiddenLedgerSummaryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyHiddenLedgerSummaryHash() =>
    r'09d33c1536b575b12ff116daa5b31830be2544cb';

final class PartyHiddenLedgerSummaryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HiddenLedgerPartySummaryModel>,
          String
        > {
  PartyHiddenLedgerSummaryFamily._()
    : super(
        retry: null,
        name: r'partyHiddenLedgerSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PartyHiddenLedgerSummaryProvider call(String partyId) =>
      PartyHiddenLedgerSummaryProvider._(argument: partyId, from: this);

  @override
  String toString() => r'partyHiddenLedgerSummaryProvider';
}

@ProviderFor(partyHiddenLedgerEntries)
final partyHiddenLedgerEntriesProvider = PartyHiddenLedgerEntriesFamily._();

final class PartyHiddenLedgerEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HiddenLedgerEntryModel>>,
          List<HiddenLedgerEntryModel>,
          FutureOr<List<HiddenLedgerEntryModel>>
        >
    with
        $FutureModifier<List<HiddenLedgerEntryModel>>,
        $FutureProvider<List<HiddenLedgerEntryModel>> {
  PartyHiddenLedgerEntriesProvider._({
    required PartyHiddenLedgerEntriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'partyHiddenLedgerEntriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyHiddenLedgerEntriesHash();

  @override
  String toString() {
    return r'partyHiddenLedgerEntriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<HiddenLedgerEntryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HiddenLedgerEntryModel>> create(Ref ref) {
    final argument = this.argument as String;
    return partyHiddenLedgerEntries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PartyHiddenLedgerEntriesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyHiddenLedgerEntriesHash() =>
    r'6aa811d70f4753850544a809af9226b4fc274e98';

final class PartyHiddenLedgerEntriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<HiddenLedgerEntryModel>>,
          String
        > {
  PartyHiddenLedgerEntriesFamily._()
    : super(
        retry: null,
        name: r'partyHiddenLedgerEntriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PartyHiddenLedgerEntriesProvider call(String partyId) =>
      PartyHiddenLedgerEntriesProvider._(argument: partyId, from: this);

  @override
  String toString() => r'partyHiddenLedgerEntriesProvider';
}

@ProviderFor(hiddenLedgerEntryDetail)
final hiddenLedgerEntryDetailProvider = HiddenLedgerEntryDetailFamily._();

final class HiddenLedgerEntryDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<HiddenLedgerEntryDetailModel>,
          HiddenLedgerEntryDetailModel,
          FutureOr<HiddenLedgerEntryDetailModel>
        >
    with
        $FutureModifier<HiddenLedgerEntryDetailModel>,
        $FutureProvider<HiddenLedgerEntryDetailModel> {
  HiddenLedgerEntryDetailProvider._({
    required HiddenLedgerEntryDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hiddenLedgerEntryDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hiddenLedgerEntryDetailHash();

  @override
  String toString() {
    return r'hiddenLedgerEntryDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HiddenLedgerEntryDetailModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HiddenLedgerEntryDetailModel> create(Ref ref) {
    final argument = this.argument as String;
    return hiddenLedgerEntryDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HiddenLedgerEntryDetailProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hiddenLedgerEntryDetailHash() =>
    r'042e9b06899df09ae937281d5d99cf1833105ff5';

final class HiddenLedgerEntryDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HiddenLedgerEntryDetailModel>,
          String
        > {
  HiddenLedgerEntryDetailFamily._()
    : super(
        retry: null,
        name: r'hiddenLedgerEntryDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HiddenLedgerEntryDetailProvider call(String entryId) =>
      HiddenLedgerEntryDetailProvider._(argument: entryId, from: this);

  @override
  String toString() => r'hiddenLedgerEntryDetailProvider';
}
