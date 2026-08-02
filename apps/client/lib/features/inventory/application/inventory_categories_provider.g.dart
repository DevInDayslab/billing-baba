// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryCategories)
final inventoryCategoriesProvider = InventoryCategoriesProvider._();

final class InventoryCategoriesProvider
    extends
        $AsyncNotifierProvider<InventoryCategories, List<InventoryCategory>> {
  InventoryCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryCategoriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryCategoriesHash();

  @$internal
  @override
  InventoryCategories create() => InventoryCategories();
}

String _$inventoryCategoriesHash() =>
    r'e82f5a0d21610eeb612a40bd5477c1777acec5b7';

abstract class _$InventoryCategories
    extends $AsyncNotifier<List<InventoryCategory>> {
  FutureOr<List<InventoryCategory>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<InventoryCategory>>,
              List<InventoryCategory>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<InventoryCategory>>,
                List<InventoryCategory>
              >,
              AsyncValue<List<InventoryCategory>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
