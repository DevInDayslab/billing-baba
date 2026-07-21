import 'package:cached_network_image/cached_network_image.dart';

/// Evicts a network image from the disk/memory cache used by [CachedNetworkImage].
Future<void> evictAppNetworkImage(String? imageUrl) async {
  final url = imageUrl?.trim();
  if (url == null || url.isEmpty) return;
  await CachedNetworkImage.evictFromCache(url);
}
