import 'package:billing_baba/core/media/image_variant.dart';
import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/providers/future_provider.dart';

typedef MediaVariantRequest = ({
  String sourceMediaAssetId,
  ImageVariant variant,
});

final FutureProviderFamily<String, MediaVariantRequest> mediaVariantUrlProvider = FutureProvider.family<String, MediaVariantRequest>(
  (ref, request) async {
    final client = await ref.watch(apiClientProvider.future);
    final path = ApiEndpoints.storageImageVariantUrl(
      request.sourceMediaAssetId,
      request.variant.apiValue,
    );
    final response = await client.dio.get<Map<String, dynamic>>(path);
    final data = response.data?['data'] as Map<String, dynamic>?;
    final url = data?['url'] as String?;
    if (url == null || url.isEmpty) {
      throw StateError('Variant URL missing in response');
    }
    return url;
  },
);

/// Drops cached signed URLs so the next read fetches a fresh variant URL.
void invalidateMediaVariantUrls(ProviderContainer container, String mediaAssetId) {
  final assetId = mediaAssetId.trim();
  if (assetId.isEmpty) return;

  for (final variant in ImageVariant.values) {
    container.invalidate(
      mediaVariantUrlProvider((
        sourceMediaAssetId: assetId,
        variant: variant,
      )),
    );
  }
}
