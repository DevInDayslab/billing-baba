// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PartyLoyaltyBalanceCache)
final partyLoyaltyBalanceCacheProvider = PartyLoyaltyBalanceCacheProvider._();

final class PartyLoyaltyBalanceCacheProvider
    extends
        $NotifierProvider<
          PartyLoyaltyBalanceCache,
          Map<String, PartyLoyaltyBalanceDto>
        > {
  PartyLoyaltyBalanceCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyLoyaltyBalanceCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyLoyaltyBalanceCacheHash();

  @$internal
  @override
  PartyLoyaltyBalanceCache create() => PartyLoyaltyBalanceCache();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, PartyLoyaltyBalanceDto> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, PartyLoyaltyBalanceDto>>(
        value,
      ),
    );
  }
}

String _$partyLoyaltyBalanceCacheHash() =>
    r'3d693a7dd6df951779978836e6f6c9037301876c';

abstract class _$PartyLoyaltyBalanceCache
    extends $Notifier<Map<String, PartyLoyaltyBalanceDto>> {
  Map<String, PartyLoyaltyBalanceDto> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, PartyLoyaltyBalanceDto>,
              Map<String, PartyLoyaltyBalanceDto>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, PartyLoyaltyBalanceDto>,
                Map<String, PartyLoyaltyBalanceDto>
              >,
              Map<String, PartyLoyaltyBalanceDto>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(loyaltyService)
final loyaltyServiceProvider = LoyaltyServiceProvider._();

final class LoyaltyServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<LoyaltyService>,
          LoyaltyService,
          FutureOr<LoyaltyService>
        >
    with $FutureModifier<LoyaltyService>, $FutureProvider<LoyaltyService> {
  LoyaltyServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loyaltyServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loyaltyServiceHash();

  @$internal
  @override
  $FutureProviderElement<LoyaltyService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LoyaltyService> create(Ref ref) {
    return loyaltyService(ref);
  }
}

String _$loyaltyServiceHash() => r'bb850595929bfba84365939b185f566e327c43ce';

@ProviderFor(partyLoyaltyBalance)
final partyLoyaltyBalanceProvider = PartyLoyaltyBalanceFamily._();

final class PartyLoyaltyBalanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PartyLoyaltyBalanceDto>,
          PartyLoyaltyBalanceDto,
          FutureOr<PartyLoyaltyBalanceDto>
        >
    with
        $FutureModifier<PartyLoyaltyBalanceDto>,
        $FutureProvider<PartyLoyaltyBalanceDto> {
  PartyLoyaltyBalanceProvider._({
    required PartyLoyaltyBalanceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'partyLoyaltyBalanceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyLoyaltyBalanceHash();

  @override
  String toString() {
    return r'partyLoyaltyBalanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PartyLoyaltyBalanceDto> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PartyLoyaltyBalanceDto> create(Ref ref) {
    final argument = this.argument as String;
    return partyLoyaltyBalance(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PartyLoyaltyBalanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyLoyaltyBalanceHash() =>
    r'817ec9ad2d8767bcb5de7800c04c3ef5a0e866cd';

final class PartyLoyaltyBalanceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PartyLoyaltyBalanceDto>, String> {
  PartyLoyaltyBalanceFamily._()
    : super(
        retry: null,
        name: r'partyLoyaltyBalanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PartyLoyaltyBalanceProvider call(String partyId) =>
      PartyLoyaltyBalanceProvider._(argument: partyId, from: this);

  @override
  String toString() => r'partyLoyaltyBalanceProvider';
}
