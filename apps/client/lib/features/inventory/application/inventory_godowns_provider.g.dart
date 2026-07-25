// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_godowns_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryGodowns)
final inventoryGodownsProvider = InventoryGodownsProvider._();

final class InventoryGodownsProvider
    extends $AsyncNotifierProvider<InventoryGodowns, List<GodownModel>> {
  InventoryGodownsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryGodownsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryGodownsHash();

  @$internal
  @override
  InventoryGodowns create() => InventoryGodowns();
}

String _$inventoryGodownsHash() => r'41e45708dafdd4afe1d4aa20eb38cb805a91779a';

abstract class _$InventoryGodowns extends $AsyncNotifier<List<GodownModel>> {
  FutureOr<List<GodownModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<GodownModel>>, List<GodownModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<GodownModel>>, List<GodownModel>>,
              AsyncValue<List<GodownModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
