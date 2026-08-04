import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_images_provider.g.dart';

const _seedImageIdPrefix = '__seed__';

/// Whether [id] is a temporary seed row shown before the gallery API responds.
bool isSeedItemImageId(String id) => id.startsWith(_seedImageIdPrefix);

ItemImageModel seedItemImageFromUrl(String itemId, String url) {
  return ItemImageModel(
    id: '$_seedImageIdPrefix$itemId',
    imageUrl: url.trim(),
    sortOrder: 0,
    isPrimary: true,
  );
}

@Riverpod(keepAlive: true)
class ItemImages extends _$ItemImages {
  late String _itemId;

  @override
  Future<List<ItemImageModel>> build(String itemId) async {
    _itemId = itemId;
    final previous = state.asData?.value;
    try {
      final service = await ref.watch(inventoryServiceProvider.future);
      return await service.fetchItemImages(itemId);
    } on Object {
      // Keep seeded / previous gallery visible when the gallery API fails.
      if (previous != null && previous.isNotEmpty) return previous;
      return const [];
    }
  }

  List<ItemImageModel> get _current => state.value ?? const [];

  List<ItemImageModel> _withPrimary(
    List<ItemImageModel> images,
    String primaryId,
  ) {
    return images
        .map((image) => image.copyWith(isPrimary: image.id == primaryId))
        .toList();
  }

  /// Paint cached gallery immediately (e.g. list primary URL) before fetch completes.
  void seed(List<ItemImageModel> images) {
    if (images.isEmpty || _current.isNotEmpty) return;
    state = AsyncData(images);
  }

  /// Restores a snapshot after a failed optimistic mutation.
  void applyOptimistic(List<ItemImageModel> images) {
    state = AsyncData(images);
  }

  void upsert(ItemImageModel image) {
    final withoutSeed = _current.where((img) => !isSeedItemImageId(img.id));
    final withoutId = withoutSeed.where((img) => img.id != image.id);
    var next = [...withoutId, image];
    if (image.isPrimary) {
      next = _withPrimary(next, image.id);
    }
    state = AsyncData(next);
  }

  void removeLocal(String imageId) {
    final next = _current.where((image) => image.id != imageId).toList();
    state = AsyncData(next);
  }

  void setPrimaryLocal(String imageId) {
    if (_current.isEmpty) return;
    state = AsyncData(_withPrimary(_current, imageId));
  }

  /// Reconcile with server without flashing a loading state.
  Future<void> refreshInBackground() async {
    final previous = _current;
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final fresh = await service.fetchItemImages(_itemId);
      if (!ref.mounted) return;
      state = AsyncData(fresh);
    } on Object {
      if (ref.mounted && previous.isNotEmpty) {
        state = AsyncData(previous);
      }
    }
  }
}
