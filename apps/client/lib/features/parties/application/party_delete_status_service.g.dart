// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_delete_status_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(partyDeleteStatusService)
final partyDeleteStatusServiceProvider = PartyDeleteStatusServiceProvider._();

final class PartyDeleteStatusServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PartyDeleteStatusService>,
          PartyDeleteStatusService,
          FutureOr<PartyDeleteStatusService>
        >
    with
        $FutureModifier<PartyDeleteStatusService>,
        $FutureProvider<PartyDeleteStatusService> {
  PartyDeleteStatusServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyDeleteStatusServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyDeleteStatusServiceHash();

  @$internal
  @override
  $FutureProviderElement<PartyDeleteStatusService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PartyDeleteStatusService> create(Ref ref) {
    return partyDeleteStatusService(ref);
  }
}

String _$partyDeleteStatusServiceHash() =>
    r'47247a8d03096f7f5a7f04850ab5072bd5253d88';
