import 'dart:async';

import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen-agnostic prefetch helper for list and grid image URLs.
class AppImagePrefetcher {
  AppImagePrefetcher(this._imageService);

  final ImageService _imageService;

  /// Prefetches up to [lookahead] URLs immediately after [lastVisibleIndex].
  void prefetchAhead({
    required List<String> urls,
    required int lastVisibleIndex,
    int lookahead = 30,
  }) {
    if (urls.isEmpty || lastVisibleIndex < 0) return;

    final start = lastVisibleIndex + 1;
    if (start >= urls.length) return;

    final end = (start + lookahead).clamp(0, urls.length);
    unawaited(
      _imageService.prefetchUrls(
        urls.sublist(start, end),
        limit: lookahead,
      ),
    );
  }

  /// Prefetches image URLs for list items after [lastVisibleIndex].
  void prefetchItemsAhead<T>({
    required List<T> items,
    required int lastVisibleIndex,
    required String? Function(T item) urlExtractor,
    int lookahead = 30,
  }) {
    prefetchItemsWindow(
      items: items,
      firstVisibleIndex: lastVisibleIndex + 1,
      lastVisibleIndex: lastVisibleIndex,
      urlExtractor: urlExtractor,
      lookahead: lookahead,
    );
  }

  /// Prefetches image URLs for visible rows plus [lookahead] below.
  void prefetchItemsWindow<T>({
    required List<T> items,
    required int firstVisibleIndex,
    required int lastVisibleIndex,
    required String? Function(T item) urlExtractor,
    int lookahead = 30,
  }) {
    if (items.isEmpty) return;

    final start = firstVisibleIndex.clamp(0, items.length - 1);
    final end = (lastVisibleIndex + lookahead + 1).clamp(0, items.length);
    if (start >= end) return;

    final urls = collectImageUrls(
      items.sublist(start, end),
      urlExtractor,
    );
    unawaited(_imageService.prefetchUrls(urls, limit: end - start));
  }

  /// Estimates the first visible row index from scroll position.
  static int estimateFirstVisibleIndex(
    ScrollController controller, {
    double itemExtent = 56,
  }) {
    if (!controller.hasClients || itemExtent <= 0) return 0;
    return (controller.offset / itemExtent).floor();
  }

  /// Estimates the last visible row index from scroll position.
  static int estimateLastVisibleIndex(
    ScrollController controller, {
    double itemExtent = 56,
  }) {
    if (!controller.hasClients || itemExtent <= 0) return 0;

    final offset = controller.offset;
    final viewport = controller.position.viewportDimension;
    return ((offset + viewport) / itemExtent).ceil() - 1;
  }

  /// Attaches a scroll listener that prefetches ahead while scrolling.
  void attachScrollPrefetch({
    required ScrollController controller,
    required List<String> Function() urlsBuilder,
    double itemExtent = 56,
    int lookahead = 30,
  }) {
    void onScroll() {
      if (!controller.hasClients) return;
      final urls = urlsBuilder();
      prefetchAhead(
        urls: urls,
        lastVisibleIndex: estimateLastVisibleIndex(
          controller,
          itemExtent: itemExtent,
        ),
        lookahead: lookahead,
      );
    }

    controller.addListener(onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => onScroll());
  }
}

final appImagePrefetcherProvider = Provider<AppImagePrefetcher>((ref) {
  return AppImagePrefetcher(ref.watch(imageServiceProvider));
});

/// Collects non-empty image URLs from a list using [urlExtractor].
List<String> collectImageUrls<T>(
  Iterable<T> items,
  String? Function(T item) urlExtractor,
) {
  return [
    for (final item in items) ?normalizeImageUrl(urlExtractor(item)),
  ];
}
