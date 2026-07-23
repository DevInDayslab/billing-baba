import 'dart:async';

import 'package:billing_baba/core/media/image_display_context.dart';
import 'package:billing_baba/features/inventory/application/inventory_item_list_merge.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/providers/item_images_provider.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Seeds gallery cache + prefetches bytes for inventory list hover previews.
class InventoryListImageWarmup {
  InventoryListImageWarmup(this._ref);

  final Ref _ref;
  final Set<String> _galleryWarmInFlight = {};
  final Set<String> _warmedItemIds = {};

  void warmItem(InventoryItem item) {
    if (_warmedItemIds.contains(item.id)) return;
    _warmedItemIds.add(item.id);

    final primary = normalizeImageUrl(item.primaryImageUrl);
    if (primary != null) {
      _ref.read(itemImagesProvider(item.id).notifier).seed([
        seedItemImageFromUrl(item.id, primary),
      ]);
      unawaited(
        _ref.read(imageServiceProvider).prefetchUrl(
              primary,
              cacheKey: buildImageCacheKey(fallbackUrl: primary),
            ),
      );
      return;
    }

    if (!isServerBackedInventoryItemId(item.id)) return;
    if (_galleryWarmInFlight.contains(item.id)) return;
    _galleryWarmInFlight.add(item.id);
    unawaited(_warmGallery(item.id));
  }

  void warmItems(Iterable<InventoryItem> items, {int limit = 60}) {
    var count = 0;
    for (final item in items) {
      if (count >= limit) break;
      warmItem(item);
      count++;
    }
  }

  Future<void> _warmGallery(String itemId) async {
    try {
      final images = await _ref.read(itemImagesProvider(itemId).future);
      final image = _resolvePrimaryOrFirst(images);
      if (image == null) return;

      await _prefetchGalleryImage(image);
    } finally {
      _galleryWarmInFlight.remove(itemId);
    }
  }

  Future<void> _prefetchGalleryImage(ItemImageModel image) async {
    final imageService = _ref.read(imageServiceProvider);
    final thumbUrl = normalizeImageUrl(image.urlForGrid());
    final detailUrl = normalizeImageUrl(image.urlForDetail());
    final mediaAssetId = image.mediaAssetId?.trim();

    if (mediaAssetId != null && mediaAssetId.isNotEmpty) {
      await imageService.prefetchResolved(
        sourceMediaAssetId: mediaAssetId,
        context: ImageDisplayContext.galleryThumb,
        fallbackUrl: thumbUrl,
      );
      if (detailUrl != null) {
        await imageService.prefetchResolved(
          sourceMediaAssetId: mediaAssetId,
          context: ImageDisplayContext.detail,
          fallbackUrl: detailUrl,
        );
      }
      return;
    }

    if (thumbUrl != null) {
      await imageService.prefetchUrl(
        thumbUrl,
        cacheKey: buildImageCacheKey(fallbackUrl: thumbUrl),
      );
    }
  }

  ItemImageModel? _resolvePrimaryOrFirst(List<ItemImageModel> images) {
    if (images.isEmpty) return null;
    return images.where((image) => image.isPrimary).firstOrNull ??
        images.sorted((a, b) => a.sortOrder.compareTo(b.sortOrder)).firstOrNull;
  }
}

final inventoryListImageWarmupProvider = Provider<InventoryListImageWarmup>(
  InventoryListImageWarmup.new,
);
