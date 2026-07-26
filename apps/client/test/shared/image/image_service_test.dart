import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/image/app_image_prefetcher.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeImageUrl', () {
    test('returns null for empty values', () {
      expect(normalizeImageUrl(null), isNull);
      expect(normalizeImageUrl(''), isNull);
      expect(normalizeImageUrl('   '), isNull);
    });

    test('trims valid URLs', () {
      expect(
        normalizeImageUrl('  https://example.com/a.jpg  '),
        'https://example.com/a.jpg',
      );
    });
  });

  group('buildImageCacheKey', () {
    test('uses stable media asset key when asset id and context are set', () {
      expect(
        buildImageCacheKey(
          mediaAssetId: 'asset-123',
          displayContext: ImageDisplayContext.galleryThumb,
        ),
        'media:asset-123:thumbnail',
      );
    });

    test('falls back to normalized URL when media asset is absent', () {
      expect(
        buildImageCacheKey(fallbackUrl: '  https://example.com/logo.png  '),
        'https://example.com/logo.png',
      );
    });

    test('prefers media asset key over fallback URL', () {
      expect(
        buildImageCacheKey(
          mediaAssetId: 'asset-123',
          displayContext: ImageDisplayContext.detail,
          fallbackUrl: 'https://example.com/old-signed.jpg',
        ),
        'media:asset-123:medium',
      );
    });
  });

  group('mediaAssetCacheKeys', () {
    test('returns one key per image variant', () {
      final keys = mediaAssetCacheKeys('asset-123');
      expect(keys, contains('media:asset-123:thumbnail'));
      expect(keys, contains('media:asset-123:medium'));
      expect(keys, contains('media:asset-123:original'));
    });
  });

  group('collectImageUrls', () {
    test('keeps order and skips empty URLs', () {
      final urls = collectImageUrls(
        ['a', 'b', 'c'],
        (item) => item == 'b' ? null : 'https://example.com/$item.jpg',
      );

      expect(urls, [
        'https://example.com/a.jpg',
        'https://example.com/c.jpg',
      ]);
    });
  });

  group('AppImagePrefetcher.estimateLastVisibleIndex', () {
    test('returns zero when controller has no clients', () {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      expect(
        AppImagePrefetcher.estimateLastVisibleIndex(controller),
        0,
      );
    });
  });
}
