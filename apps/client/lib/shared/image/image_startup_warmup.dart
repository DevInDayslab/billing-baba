import 'dart:async';

import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_list_image_warmup.dart';
import 'package:billing_baba/features/pos/application/pos_items_provider.dart';
import 'package:billing_baba/shared/image/image_debug_log.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Background image warm-up after a business session is ready.
class ImageStartupWarmup {
  ImageStartupWarmup(this._ref);

  final Ref _ref;
  var _ranForBusinessId = '';

  Future<void> run({required String businessId}) async {
    if (_ranForBusinessId == businessId) return;
    _ranForBusinessId = businessId;

    ImageDebugLog.startupWarmupStarted();
    unawaited(_warmBusinessBranding());
    unawaited(_warmInventoryItems());
    unawaited(_warmPosCatalog());
    ImageDebugLog.startupWarmupComplete();
  }

  Future<void> _warmBusinessBranding() async {
    try {
      final profile = _ref.read(currentBusinessProvider);
      if (profile == null) return;

      final imageService = _ref.read(imageServiceProvider);
      await _prefetchBusinessImage(
        imageService: imageService,
        url: profile.logoUrl,
        context: ImageDisplayContext.list,
      );
      await _prefetchBusinessImage(
        imageService: imageService,
        url: profile.signatureUrl,
        context: ImageDisplayContext.detail,
      );
      await _prefetchBusinessImage(
        imageService: imageService,
        url: profile.stampUrl,
        context: ImageDisplayContext.detail,
      );
    } on Object {
      // Best-effort warm-up.
    }
  }

  Future<void> _warmInventoryItems() async {
    try {
      final items = _ref.read(inventoryItemListProvider);
      _ref
          .read(inventoryListImageWarmupProvider)
          .warmItems(
            items.take(30),
            limit: 30,
          );
    } on Object {
      // Best-effort warm-up.
    }
  }

  Future<void> _warmPosCatalog() async {
    try {
      final items = _ref.read(
        posFilteredCatalogProvider(
          searchQuery: '',
        ),
      );
      final imageService = _ref.read(imageServiceProvider);
      for (final item in items.take(24)) {
        await _prefetchBusinessImage(
          imageService: imageService,
          url: item.imageUrl,
          context: ImageDisplayContext.grid,
        );
      }
    } on Object {
      // Best-effort warm-up.
    }
  }

  Future<void> _prefetchBusinessImage({
    required ImageService imageService,
    required String? url,
    required ImageDisplayContext context,
  }) async {
    final normalized = normalizeImageUrl(url);
    if (normalized == null) return;

    final mediaAssetId = extractMediaAssetIdFromUrl(normalized);
    if (mediaAssetId != null && mediaAssetId.isNotEmpty) {
      await imageService.prefetchResolved(
        sourceMediaAssetId: mediaAssetId,
        context: context,
        fallbackUrl: normalized,
      );
      return;
    }

    await imageService.prefetchUrl(
      normalized,
      cacheKey: buildImageCacheKey(fallbackUrl: normalized),
    );
  }
}

final imageStartupWarmupProvider = Provider<ImageStartupWarmup>(
  ImageStartupWarmup.new,
);
