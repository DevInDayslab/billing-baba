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

    for (final variant in chain) {
      try {
        final url = await _ref.read(
          mediaVariantUrlProvider((
            sourceMediaAssetId: sourceMediaAssetId,
            variant: variant,
          )).future,
        );
        if (url.isNotEmpty) return url;
      } catch (_) {
        continue;
      }
    }

    if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
      return fallbackUrl;
    }

    throw StateError('Unable to resolve image URL for $sourceMediaAssetId');
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
