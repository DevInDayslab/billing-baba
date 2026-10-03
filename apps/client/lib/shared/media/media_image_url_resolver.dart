import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/media/image_variant.dart';
import 'package:billing_baba/shared/media/media_image_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaImageUrlResolver {
  MediaImageUrlResolver(this._ref);

  final Ref _ref;

  Future<String> resolve({
    required String sourceMediaAssetId,
    required ImageDisplayContext context,
    String? fallbackUrl,
  }) async {
    final preferred = context.preferredVariant;
    final chain = _fallbackChain(preferred);

    // Staging rack/item uploads often have no variants — resolve source first
    // to avoid three variant 404s per thumbnail.
    if (preferred == ImageVariant.thumbnail &&
        _isStagingObjectUrl(fallbackUrl)) {
      try {
        final sourceUrl = await _ref.read(
          mediaSourceUrlProvider(sourceMediaAssetId).future,
        );
        if (sourceUrl.isNotEmpty) return sourceUrl;
      } on Object {
        // Fall through to variant chain + fallback URL.
      }
    }

    for (final variant in chain) {
      try {
        final url = await _ref.read(
          mediaVariantUrlProvider((
            sourceMediaAssetId: sourceMediaAssetId,
            variant: variant,
          )).future,
        );
        if (url.isNotEmpty) return url;
      } on Object {
        continue;
      }
    }

    // Staging uploads (and other sources without variants) still need a fresh
    // signed URL — persisted primary_image_url signatures expire in ~1 hour.
    try {
      final sourceUrl = await _ref.read(
        mediaSourceUrlProvider(sourceMediaAssetId).future,
      );
      if (sourceUrl.isNotEmpty) return sourceUrl;
    } on Object {
      // Fall through to caller-supplied URL.
    }

    if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
      return fallbackUrl;
    }

    throw StateError('Unable to resolve image URL for $sourceMediaAssetId');
  }

  Future<String> resolveSource({
    required String sourceMediaAssetId,
    String? fallbackUrl,
  }) async {
    try {
      final sourceUrl = await _ref.read(
        mediaSourceUrlProvider(sourceMediaAssetId).future,
      );
      if (sourceUrl.isNotEmpty) return sourceUrl;
    } on Object {
      // Fall through to caller-supplied URL.
    }

    if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
      return fallbackUrl;
    }

    throw StateError('Unable to resolve source URL for $sourceMediaAssetId');
  }

  bool _isStagingObjectUrl(String? url) {
    final normalized = url?.trim();
    if (normalized == null || normalized.isEmpty) return false;
    return normalized.contains('/staging/');
  }

  List<ImageVariant> _fallbackChain(ImageVariant preferred) {
    switch (preferred) {
      case ImageVariant.thumbnail:
        return [
          ImageVariant.thumbnail,
          ImageVariant.medium,
          ImageVariant.original,
        ];
      case ImageVariant.medium:
        return [
          ImageVariant.medium,
          ImageVariant.original,
          ImageVariant.thumbnail,
        ];
      case ImageVariant.original:
        return [
          ImageVariant.original,
          ImageVariant.medium,
          ImageVariant.thumbnail,
        ];
    }
  }
}

final mediaImageUrlResolverProvider = Provider<MediaImageUrlResolver>(
  MediaImageUrlResolver.new,
);
