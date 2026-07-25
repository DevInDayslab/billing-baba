import 'dart:async';

import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_list_image_warmup.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/pos/application/pos_items_provider.dart';
import 'package:billing_baba/shared/image/image_debug_log.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
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
      await imageService.prefetchUrl(
        profile.logoUrl,
        cacheKey: buildImageCacheKey(fallbackUrl: profile.logoUrl),
      );
      await imageService.prefetchUrl(
        profile.signatureUrl,
        cacheKey: buildImageCacheKey(fallbackUrl: profile.signatureUrl),
      );
    } on Object {
      // Best-effort warm-up.
    }
  }

  Future<void> _warmInventoryItems() async {
    try {
      final items = _ref.read(inventoryItemsProvider).value ?? const [];
      _ref.read(inventoryListImageWarmupProvider).warmItems(
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
        await imageService.prefetchUrl(
          item.imageUrl,
          cacheKey: buildImageCacheKey(fallbackUrl: item.imageUrl),
        );
      }
    } on Object {
      // Best-effort warm-up.
    }
  }
}

final imageStartupWarmupProvider = Provider<ImageStartupWarmup>(
  ImageStartupWarmup.new,
);
