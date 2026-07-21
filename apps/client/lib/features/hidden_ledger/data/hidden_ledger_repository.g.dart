// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hidden_ledger_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hiddenLedgerRepository)
final hiddenLedgerRepositoryProvider = HiddenLedgerRepositoryProvider._();

final class HiddenLedgerRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<HiddenLedgerRepository>,
          HiddenLedgerRepository,
          FutureOr<HiddenLedgerRepository>
        >
    with
        $FutureModifier<HiddenLedgerRepository>,
        $FutureProvider<HiddenLedgerRepository> {
  HiddenLedgerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hiddenLedgerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hiddenLedgerRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<HiddenLedgerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HiddenLedgerRepository> create(Ref ref) {
    return hiddenLedgerRepository(ref);
  }
}

String _$hiddenLedgerRepositoryHash() =>
    r'09c735e6e6fb64935c1392e239c4fcc5727bead2';
