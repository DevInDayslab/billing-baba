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
    extends $AsyncNotifierProvider<InventoryItems, PaginatedInventoryItems> {
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

String _$inventoryItemsHash() => r'd5c6ab909d33df654dcb65a740c6059ce3b77560';

abstract class _$InventoryItems
    extends $AsyncNotifier<PaginatedInventoryItems> {
  FutureOr<PaginatedInventoryItems> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedInventoryItems>,
              PaginatedInventoryItems
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedInventoryItems>,
                PaginatedInventoryItems
              >,
              AsyncValue<PaginatedInventoryItems>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
