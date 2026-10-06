import 'dart:async';

import 'package:billing_baba/features/inventory/models/item_location_history_model.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';

/// Warms rack audit thumbnails using persisted signed URLs (no storage API round-trip).
void warmRackHistoryThumbnails(
  ImageService imageService,
  List<ItemLocationHistoryModel> history, {
  int limit = 5,
}) {
  var count = 0;
  for (final entry in history) {
    if (count >= limit) break;
    final url = normalizeImageUrl(entry.photoUrl);
    if (url == null) continue;
    count++;
    final assetId = coalesceStorageMediaAssetId(
      storedMediaAssetId: entry.photoMediaAssetId,
      imageUrl: url,
    );
    final cacheKey = buildImageCacheKey(
      mediaAssetId: assetId,
      fallbackUrl: url,
    );
    unawaited(imageService.prefetchUrl(url, cacheKey: cacheKey));
  }
}

void warmRackPhotoUrl(ImageService imageService, String? photoUrl) {
  final url = normalizeImageUrl(photoUrl);
  if (url == null) return;
  final assetId = extractMediaAssetIdFromUrl(url);
  final cacheKey = buildImageCacheKey(
    mediaAssetId: assetId,
    fallbackUrl: url,
  );
  unawaited(imageService.prefetchUrl(url, cacheKey: cacheKey));
}
