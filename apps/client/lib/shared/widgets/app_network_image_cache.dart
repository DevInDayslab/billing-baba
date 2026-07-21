import 'package:billing_baba/shared/image/image_cache_manager.dart';
import 'package:billing_baba/shared/image/image_debug_log.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Evicts a network image from the shared disk/memory cache.
Future<void> evictAppNetworkImage(
  String? imageUrl, {
  String? cacheKey,
}) async {
  final url = normalizeImageUrl(imageUrl);
  final key = cacheKey ?? url;
  if (key == null) return;

  ImageDebugLog.cacheEvicted(key);

  try {
    if (url != null) {
      await appImageCacheManager.removeFile(url);
    }
    await appImageCacheManager.removeFile(key);
  } on Object {
    // Cache entry may already be gone.
  }

  if (url != null) {
    await CachedNetworkImage.evictFromCache(
      url,
      cacheManager: appImageCacheManager,
    );
  }

  if (cacheKey != null && cacheKey != url) {
    await CachedNetworkImage.evictFromCache(
      cacheKey,
      cacheManager: appImageCacheManager,
    );
  }
}
