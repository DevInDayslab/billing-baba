// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inventoryService)
final inventoryServiceProvider = InventoryServiceProvider._();

final class InventoryServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<InventoryService>,
          InventoryService,
          FutureOr<InventoryService>
        >
    with $FutureModifier<InventoryService>, $FutureProvider<InventoryService> {
  InventoryServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryServiceHash();

  @$internal
  @override
  $FutureProviderElement<InventoryService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InventoryService> create(Ref ref) {
    return inventoryService(ref);
  }
}

String _$inventoryServiceHash() => r'de00b5b6c2c71a0980d6afda3641348187225c5c';
