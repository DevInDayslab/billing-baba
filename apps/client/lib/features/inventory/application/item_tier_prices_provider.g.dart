// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_tier_prices_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ItemTierPrices)
final itemTierPricesProvider = ItemTierPricesProvider._();

final class ItemTierPricesProvider
    extends
        $AsyncNotifierProvider<
          ItemTierPrices,
          Map<String, Map<String, double>>
        > {
  ItemTierPricesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemTierPricesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemTierPricesHash();

  @$internal
  @override
  ItemTierPrices create() => ItemTierPrices();
}

String _$itemTierPricesHash() => r'c15b7e2007cacf3cef80e2bea73b6b03de8cb618';

abstract class _$ItemTierPrices
    extends $AsyncNotifier<Map<String, Map<String, double>>> {
  FutureOr<Map<String, Map<String, double>>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, Map<String, double>>>,
              Map<String, Map<String, double>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, Map<String, double>>>,
                Map<String, Map<String, double>>
              >,
              AsyncValue<Map<String, Map<String, double>>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
