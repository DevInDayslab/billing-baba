import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/media/image_variant.dart';
import 'package:billing_baba/shared/media/media_image_url_resolver.dart';

final _uuidInPath = RegExp(
  '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
);

final _stagingAssetId = RegExp(
  r'/staging/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})\.[^/]+$',
);

final _variantAssetId = RegExp(
  r'/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})-(?:thumbnail|medium|original)\.[^/]+$',
);

/// Returns a trimmed non-empty URL, or null.
String? normalizeImageUrl(String? url) {
  final trimmed = url?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

/// Extracts a media asset UUID from our storage object keys (staging or variants).
///
/// Signed URLs expire; the asset id is durable and can refresh via the storage API.
String? extractMediaAssetIdFromUrl(String? url) {
  final normalized = normalizeImageUrl(url);
  if (normalized == null) return null;

  final Uri uri;
  try {
    uri = Uri.parse(normalized);
  } on FormatException {
    return null;
  }

  final path = uri.path;
  final staging = _stagingAssetId.firstMatch(path);
  if (staging != null) return staging.group(1);

  final variant = _variantAssetId.firstMatch(path);
  if (variant != null) return variant.group(1);

  final segments = path.split('/').where((part) => part.isNotEmpty).toList();
  if (segments.isEmpty) return null;
  final fileName = segments.last;
  final match = _uuidInPath.firstMatch(fileName);
  if (match == null || match.start != 0) return null;
  return match.group(0);
}

/// URL without query/fragment — signed query params must not be part of cache keys.
String? stripUrlQuery(String? url) {
  final normalized = normalizeImageUrl(url);
  if (normalized == null) return null;
  try {
    final uri = Uri.parse(normalized);
    if (!uri.hasQuery && !uri.hasFragment) return normalized;
    return Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
    ).toString();
  } on FormatException {
    return normalized;
  }
}

/// Stable cache key for signed URLs — survives URL rotation, enables offline reuse.
String? buildImageCacheKey({
  String? mediaAssetId,
  ImageDisplayContext? displayContext,
  String? fallbackUrl,
}) {
  final effectiveContext = displayContext;
  final assetId = mediaAssetId?.trim();
  if (assetId != null && assetId.isNotEmpty && effectiveContext != null) {
    return 'media:$assetId:${effectiveContext.preferredVariant.name}';
  }
  final extracted = extractMediaAssetIdFromUrl(fallbackUrl);
  if (extracted != null && effectiveContext != null) {
    return 'media:$extracted:${effectiveContext.preferredVariant.name}';
  }
  if (assetId != null && assetId.isNotEmpty) {
    return 'media:$assetId:source';
  }
  if (extracted != null) {
    return 'media:$extracted:source';
  }
  return stripUrlQuery(fallbackUrl) ?? normalizeImageUrl(fallbackUrl);
}

/// Resolves the best display URL for a media asset, with optional fallback.
Future<String> resolveImageUrl({
  required String? sourceMediaAssetId,
  required ImageDisplayContext? displayContext,
  String? fallbackUrl,
  MediaImageUrlResolver? resolver,
}) async {
  final assetId =
      sourceMediaAssetId?.trim().isNotEmpty == true
      ? sourceMediaAssetId!.trim()
      : extractMediaAssetIdFromUrl(fallbackUrl);

  if (assetId != null && resolver != null) {
    try {
      if (displayContext != null) {
        return resolver.resolve(
          sourceMediaAssetId: assetId,
          context: displayContext,
          fallbackUrl: fallbackUrl,
        );
      }
      return resolver.resolveSource(
        sourceMediaAssetId: assetId,
        fallbackUrl: fallbackUrl,
      );
    } on Object {
      return normalizeImageUrl(fallbackUrl) ?? '';
    }
  }
  return normalizeImageUrl(fallbackUrl) ?? '';
}

/// Grid/list thumbnail URL for an inventory gallery image.
String? gridImageUrl(ItemImageModel image) =>
    normalizeImageUrl(image.urlForGrid());

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
  return [
    'media:$assetId:source',
    ...ImageVariant.values
      .map((variant) => 'media:$assetId:${variant.name}'),
  ];
}
