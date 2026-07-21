// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_images_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ItemImages)
final itemImagesProvider = ItemImagesFamily._();

final class ItemImagesProvider
    extends $AsyncNotifierProvider<ItemImages, List<ItemImageModel>> {
  ItemImagesProvider._({
    required ItemImagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itemImagesProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemImagesHash();

  @override
  String toString() {
    return r'itemImagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ItemImages create() => ItemImages();

  @override
  bool operator ==(Object other) {
    return other is ItemImagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemImagesHash() => r'e577260013d2b8edd52078ff98f4b492b6789576';

final class ItemImagesFamily extends $Family
    with
        $ClassFamilyOverride<
          ItemImages,
          AsyncValue<List<ItemImageModel>>,
          List<ItemImageModel>,
          FutureOr<List<ItemImageModel>>,
          String
        > {
  ItemImagesFamily._()
    : super(
        retry: null,
        name: r'itemImagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ItemImagesProvider call(String itemId) =>
      ItemImagesProvider._(argument: itemId, from: this);

  @override
  String toString() => r'itemImagesProvider';
}

abstract class _$ItemImages extends $AsyncNotifier<List<ItemImageModel>> {
  late final _$args = ref.$arg as String;
  String get itemId => _$args;

  FutureOr<List<ItemImageModel>> build(String itemId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ItemImageModel>>, List<ItemImageModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ItemImageModel>>,
                List<ItemImageModel>
              >,
              AsyncValue<List<ItemImageModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
