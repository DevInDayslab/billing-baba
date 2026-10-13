// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_bom_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ItemBom)
final itemBomProvider = ItemBomProvider._();

final class ItemBomProvider extends $AsyncNotifierProvider<ItemBom, void> {
  ItemBomProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemBomProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemBomHash();

  @$internal
  @override
  ItemBom create() => ItemBom();
}

String _$itemBomHash() => r'cc0d811dfa1095acec7f20a36b023e1338ce624f';

abstract class _$ItemBom extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
