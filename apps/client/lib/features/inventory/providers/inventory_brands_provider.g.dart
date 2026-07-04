// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_brands_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryBrands)
final inventoryBrandsProvider = InventoryBrandsProvider._();

final class InventoryBrandsProvider
    extends $AsyncNotifierProvider<InventoryBrands, List<BrandModel>> {
  InventoryBrandsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryBrandsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryBrandsHash();

  @$internal
  @override
  InventoryBrands create() => InventoryBrands();
}

String _$inventoryBrandsHash() => r'b4eca5de5520b59036c9b50f1f2a6f0b0d9f8477';

abstract class _$InventoryBrands extends $AsyncNotifier<List<BrandModel>> {
  FutureOr<List<BrandModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<BrandModel>>, List<BrandModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BrandModel>>, List<BrandModel>>,
              AsyncValue<List<BrandModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
