import 'package:billing_baba/core/utils/app_logger.dart';

/// Debug-only logging for the shared image system.
abstract final class ImageDebugLog {
  static void loadedFromMemory(String cacheKey) {
    AppLogger.debug('[image] loaded:memory key=$cacheKey');
  }

  static void loadedFromDisk(String cacheKey) {
    AppLogger.debug('[image] loaded:disk key=$cacheKey');
  }

  static void downloaded(String cacheKey) {
    AppLogger.debug('[image] downloaded key=$cacheKey');
  }

  static void prefetchStart(String cacheKey) {
    AppLogger.debug('[image] prefetch:start key=$cacheKey');
  }

  static void prefetchComplete(String cacheKey) {
    AppLogger.debug('[image] prefetch:complete key=$cacheKey');
  }

  static void cacheEvicted(String cacheKey) {
    AppLogger.debug('[image] cache:evict key=$cacheKey');
  }

  static void signedUrlRefreshed(String mediaAssetId) {
    AppLogger.debug('[image] signedUrl:refresh asset=$mediaAssetId');
  }

  static void memoryPressureCleared() {
    AppLogger.debug('[image] memoryPressure:cleared in-memory caches');
  }

  static void startupWarmupStarted() {
    AppLogger.debug('[image] startupWarmup:start');
  }

  static void startupWarmupComplete() {
    AppLogger.debug('[image] startupWarmup:complete');
  }
}
