// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_suppliers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ItemSuppliers)
final itemSuppliersProvider = ItemSuppliersProvider._();

final class ItemSuppliersProvider
    extends $AsyncNotifierProvider<ItemSuppliers, Map<String, List<String>>> {
  ItemSuppliersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemSuppliersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemSuppliersHash();

  @$internal
  @override
  ItemSuppliers create() => ItemSuppliers();
}

String _$itemSuppliersHash() => r'ac98b8d32c80d7661b2114ca8273caaa6b9133e0';

abstract class _$ItemSuppliers
    extends $AsyncNotifier<Map<String, List<String>>> {
  FutureOr<Map<String, List<String>>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, List<String>>>,
              Map<String, List<String>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, List<String>>>,
                Map<String, List<String>>
              >,
              AsyncValue<Map<String, List<String>>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
