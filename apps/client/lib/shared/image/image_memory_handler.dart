import 'package:billing_baba/shared/image/image_cache_manager.dart';
import 'package:billing_baba/shared/image/image_debug_log.dart';
import 'package:flutter/material.dart';

/// Clears in-memory image caches on OS memory pressure; preserves disk cache.
class ImageMemoryPressureHandler extends WidgetsBindingObserver {
  @override
  void didHaveMemoryPressure() {
    PaintingBinding.instance.imageCache.clear();
    appImageCacheManager.store.emptyMemoryCache();
    ImageDebugLog.memoryPressureCleared();
  }
}
