import 'dart:async';
import 'dart:typed_data';

import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/media/media_image_providers.dart';
import 'package:billing_baba/shared/media/media_image_url_resolver.dart';
import 'package:billing_baba/shared/image/image_cache_manager.dart';
import 'package:billing_baba/shared/image/image_debug_log.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/widgets/app_network_image_cache.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized image download, disk cache, prefetch, and byte access.
class ImageService {
  ImageService({
    required this._cacheManager,
    required this._ref,
  });

  final CacheManager _cacheManager;
  final Ref _ref;
  final Set<String> _inFlight = {};

  String _dedupeKey(String? url, String? cacheKey) =>
      cacheKey ?? normalizeImageUrl(url) ?? '';

  Future<void> prefetchUrl(
    String? url, {
    String? cacheKey,
  }) async {
    final normalized = normalizeImageUrl(url);
    if (normalized == null) return;

    final key = _dedupeKey(normalized, cacheKey);
    if (_inFlight.contains(key)) return;

    _inFlight.add(key);
    ImageDebugLog.prefetchStart(key);
    try {
      await _cacheManager.downloadFile(normalized, key: key);
      ImageDebugLog.prefetchComplete(key);
      ImageDebugLog.downloaded(key);
    } on Object {
      // Best-effort warm-up.
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<void> prefetchUrls(
    Iterable<String> urls, {
    int limit = 30,
    String? Function(String url)? cacheKeyForUrl,
  }) async {
    var count = 0;
    for (final url in urls) {
      if (count >= limit) break;
      final normalized = normalizeImageUrl(url);
      if (normalized == null) continue;
      count++;
      unawaited(
        prefetchUrl(
          normalized,
          cacheKey: cacheKeyForUrl?.call(normalized),
        ),
      );
    }
  }

  Future<void> prefetchResolved({
    required String sourceMediaAssetId,
    required ImageDisplayContext context,
    String? fallbackUrl,
  }) async {
    final cacheKey = buildImageCacheKey(
      mediaAssetId: sourceMediaAssetId,
      displayContext: context,
      fallbackUrl: fallbackUrl,
    );
    final resolved = await resolveImageUrl(
      sourceMediaAssetId: sourceMediaAssetId,
      displayContext: context,
      fallbackUrl: fallbackUrl,
      resolver: _ref.read(mediaImageUrlResolverProvider),
    );
    await prefetchUrl(resolved, cacheKey: cacheKey);
  }

  Future<Uint8List?> getBytes(
    String? url, {
    String? cacheKey,
  }) async {
    final normalized = normalizeImageUrl(url);
    if (normalized == null) return null;

    final key = _dedupeKey(normalized, cacheKey);
    try {
      final fileInfo = await _cacheManager.getFileFromCache(key);
      if (fileInfo != null) {
        ImageDebugLog.loadedFromDisk(key);
        return fileInfo.file.readAsBytes();
      }

      final file = await _cacheManager.getSingleFile(normalized, key: key);
      ImageDebugLog.downloaded(key);
      return file.readAsBytes();
    } on Object {
      return null;
    }
  }

  Future<void> evict(
    String? url, {
    String? cacheKey,
  }) async {
    await evictAppNetworkImage(url, cacheKey: cacheKey);
  }

  Future<void> invalidateImage({
    String? url,
    String? cacheKey,
    String? mediaAssetId,
    Iterable<String> extraUrls = const [],
    Iterable<String> extraCacheKeys = const [],
  }) async {
    final keys = <String>{
      ?cacheKey,
      ...extraCacheKeys,
    };
    final urls = <String>{
      ?normalizeImageUrl(url),
      ...extraUrls.map(normalizeImageUrl).whereType<String>(),
    };

    for (final key in keys) {
      await evictAppNetworkImage(null, cacheKey: key);
    }
    for (final itemUrl in urls) {
      await evictAppNetworkImage(itemUrl);
    }

    if (mediaAssetId != null && mediaAssetId.trim().isNotEmpty) {
      invalidateMediaVariantUrls(_ref.container, mediaAssetId);
      for (final key in mediaAssetCacheKeys(mediaAssetId)) {
        await evictAppNetworkImage(null, cacheKey: key);
      }
    }
  }

  Future<void> replaceImage({
    required String? oldUrl,
    required String? newUrl,
    String? oldCacheKey,
    String? newCacheKey,
    String? mediaAssetId,
    Iterable<String> oldUrls = const [],
  }) async {
    await invalidateImage(
      url: oldUrl,
      cacheKey: oldCacheKey,
      mediaAssetId: mediaAssetId,
      extraUrls: oldUrls,
    );
    await prefetchUrl(newUrl, cacheKey: newCacheKey);
  }

  Future<void> clearAll() async {
    _inFlight.clear();
    await _cacheManager.emptyCache();
  }

  /// Exposed for tests — tracks in-flight prefetch deduplication.
  bool isPrefetchInFlight(String url, {String? cacheKey}) =>
      _inFlight.contains(_dedupeKey(url, cacheKey));
}

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService(
    cacheManager: appImageCacheManager,
    ref: ref,
  );
});
