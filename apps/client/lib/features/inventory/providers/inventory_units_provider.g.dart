// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_units_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryUnits)
final inventoryUnitsProvider = InventoryUnitsProvider._();

final class InventoryUnitsProvider
    extends $AsyncNotifierProvider<InventoryUnits, List<InventoryUnit>> {
  InventoryUnitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryUnitsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryUnitsHash();

  @$internal
  @override
  InventoryUnits create() => InventoryUnits();
}

String _$inventoryUnitsHash() => r'a0aa0203f853dd7f8942e88af7c2e30178d3d688';

abstract class _$InventoryUnits extends $AsyncNotifier<List<InventoryUnit>> {
  FutureOr<List<InventoryUnit>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<InventoryUnit>>, List<InventoryUnit>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<InventoryUnit>>, List<InventoryUnit>>,
              AsyncValue<List<InventoryUnit>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
