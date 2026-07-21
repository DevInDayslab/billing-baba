// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_items_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryItems)
final inventoryItemsProvider = InventoryItemsProvider._();

final class InventoryItemsProvider
    extends $AsyncNotifierProvider<InventoryItems, List<InventoryItem>> {
  InventoryItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryItemsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryItemsHash();

  @$internal
  @override
  InventoryItems create() => InventoryItems();
}

String _$inventoryItemsHash() => r'0421c48aa5855ec8ac584c4030e6a5935d690ac5';

abstract class _$InventoryItems extends $AsyncNotifier<List<InventoryItem>> {
  FutureOr<List<InventoryItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<InventoryItem>>, List<InventoryItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<InventoryItem>>, List<InventoryItem>>,
              AsyncValue<List<InventoryItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
