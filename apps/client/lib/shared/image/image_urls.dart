import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/media/image_variant.dart';
import 'package:billing_baba/shared/media/media_image_url_resolver.dart';

/// Returns a trimmed non-empty URL, or null.
String? normalizeImageUrl(String? url) {
  final trimmed = url?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

/// Stable cache key for signed URLs — survives URL rotation, enables offline reuse.
String? buildImageCacheKey({
  String? mediaAssetId,
  ImageDisplayContext? displayContext,
  String? fallbackUrl,
}) {
  final assetId = mediaAssetId?.trim();
  if (assetId != null &&
      assetId.isNotEmpty &&
      displayContext != null) {
    return 'media:$assetId:${displayContext.preferredVariant.name}';
  }
  return normalizeImageUrl(fallbackUrl);
}

/// Resolves the best display URL for a media asset, with optional fallback.
Future<String> resolveImageUrl({
  required String? sourceMediaAssetId,
  required ImageDisplayContext? displayContext,
  String? fallbackUrl,
  MediaImageUrlResolver? resolver,
}) async {
  if (sourceMediaAssetId != null &&
      displayContext != null &&
      resolver != null) {
    try {
      return resolver.resolve(
        sourceMediaAssetId: sourceMediaAssetId,
        context: displayContext,
        fallbackUrl: fallbackUrl,
      );
    } on Object {
      return normalizeImageUrl(fallbackUrl) ?? '';
    }
  }
  return normalizeImageUrl(fallbackUrl) ?? '';
}

/// Grid/list thumbnail URL for an inventory gallery image.
String? gridImageUrl(ItemImageModel image) => normalizeImageUrl(image.urlForGrid());

/// Detail/medium URL for an inventory gallery image.
String? detailImageUrl(ItemImageModel image) =>
    normalizeImageUrl(image.urlForDetail());

/// All network URLs associated with a gallery image (for invalidation).
List<String> galleryImageUrls(ItemImageModel image) {
  return [
    normalizeImageUrl(image.imageUrl),
    normalizeImageUrl(image.thumbnailUrl),
    normalizeImageUrl(image.mediumUrl),
    gridImageUrl(image),
    detailImageUrl(image),
  ].whereType<String>().toSet().toList();
}

/// Cache keys for all variants of a media asset.
List<String> mediaAssetCacheKeys(String mediaAssetId) {
  final assetId = mediaAssetId.trim();
  return ImageVariant.values
      .map((variant) => 'media:$assetId:${variant.name}')
      .toList();
}
