import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// App-wide disk cache for every network image (thumbnails, logos, attachments).
final appImageCacheManager = CacheManager(
  Config(
    'billing_baba_images',
    stalePeriod: const Duration(days: 30),
    maxNrOfCacheObjects: 3500,
    fileService: HttpFileService(),
  ),
);
