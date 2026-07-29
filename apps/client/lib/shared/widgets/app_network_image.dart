import 'dart:async';

import 'package:billing_baba/shared/image/app_image_placeholder.dart';
import 'package:billing_baba/shared/image/image_cache_manager.dart';
import 'package:billing_baba/shared/image/image_debug_log.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/media/media_image_providers.dart';
import 'package:billing_baba/shared/media/media_image_url_resolver.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Shared network image with loading, error, tap-to-retry, and optional variant resolution.
class AppNetworkImage extends ConsumerStatefulWidget {
  const AppNetworkImage({
    required this.imageUrl,
    super.key,
    this.sourceMediaAssetId,
    this.displayContext,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.memCacheWidth,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.loadWhenVisible = true,
    this.fadeInDuration = const Duration(milliseconds: 200),
  });

  final String imageUrl;
  final String? sourceMediaAssetId;
  final ImageDisplayContext? displayContext;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool loadWhenVisible;
  final Duration fadeInDuration;

  @override
  ConsumerState<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends ConsumerState<AppNetworkImage> {
  var _retryKey = 0;
  var _isVisible = false;
  var _autoRetried = false;
  late Future<String> _resolvedUrlFuture;

  String? get _cacheKey => buildImageCacheKey(
    mediaAssetId: widget.sourceMediaAssetId,
    displayContext: widget.displayContext,
    fallbackUrl: widget.imageUrl,
  );

  @override
  void initState() {
    super.initState();
    _resolvedUrlFuture = _resolveUrl();
    if (!widget.loadWhenVisible) {
      _isVisible = true;
    }
  }

  @override
  void didUpdateWidget(covariant AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.sourceMediaAssetId != widget.sourceMediaAssetId ||
        oldWidget.displayContext != widget.displayContext) {
      _autoRetried = false;
      _resolvedUrlFuture = _resolveUrl();
    }
    if (oldWidget.loadWhenVisible != widget.loadWhenVisible &&
        !widget.loadWhenVisible) {
      _isVisible = true;
    }
  }

  Future<String> _resolveUrl() {
    return resolveImageUrl(
      sourceMediaAssetId: widget.sourceMediaAssetId,
      displayContext: widget.displayContext,
      fallbackUrl: widget.imageUrl,
      resolver: ref.read(mediaImageUrlResolverProvider),
    );
  }

  Future<void> _refreshSignedUrlAndRetry() async {
    final mediaAssetId = widget.sourceMediaAssetId?.trim();
    if (mediaAssetId != null && mediaAssetId.isNotEmpty) {
      invalidateMediaVariantUrls(ref.container, mediaAssetId);
      ImageDebugLog.signedUrlRefreshed(mediaAssetId);
    }
    if (!mounted) return;
    setState(() {
      _retryKey += 1;
      _resolvedUrlFuture = _resolveUrl();
    });
  }

  void _retry() {
    unawaited(_refreshSignedUrlAndRetry());
  }

  Future<void> _handleLoadError() async {
    if (_autoRetried) return;
    _autoRetried = true;
    await _refreshSignedUrlAndRetry();
  }

  void _scheduleLoadErrorRetry() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_handleLoadError());
    });
  }

  int? _effectiveMemCacheWidth(BuildContext context) {
    if (widget.memCacheWidth != null) return widget.memCacheWidth;
    final width = widget.width;
    if (width == null || !width.isFinite || width <= 0) return null;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return (width * dpr).round();
  }

  Widget _defaultPlaceholder() {
    return AppImagePlaceholder(
      width: widget.width,
      height: widget.height,
      borderRadius: widget.borderRadius,
    );
  }

  Widget _defaultErrorWidget() {
    return AppImageErrorPlaceholder(
      onRetry: _retry,
      width: widget.width,
      height: widget.height,
      borderRadius: widget.borderRadius,
    );
  }

  Widget _buildImage(String url, BuildContext context) {
    final cacheKey = _cacheKey;
    if (cacheKey != null) {
      ImageDebugLog.loadedFromMemory(cacheKey);
    }

    final child = CachedNetworkImage(
      key: ValueKey('$url-$cacheKey-$_retryKey'),
      imageUrl: url,
      cacheKey: cacheKey,
      cacheManager: appImageCacheManager,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      memCacheWidth: _effectiveMemCacheWidth(context),
      fadeInDuration: widget.fadeInDuration,
      fadeOutDuration: Duration.zero,
      placeholder: (_, _) => widget.placeholder ?? _defaultPlaceholder(),
      errorWidget: (_, _, _) {
        _scheduleLoadErrorRetry();
        return widget.errorWidget ?? _defaultErrorWidget();
      },
    );

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }

    return child;
  }

  Widget _buildContent(BuildContext context) {
    if (widget.loadWhenVisible && !_isVisible) {
      return widget.placeholder ?? _defaultPlaceholder();
    }

    return FutureBuilder<String>(
      future: _resolvedUrlFuture,
      builder: (context, snapshot) {
        final url = normalizeImageUrl(snapshot.data ?? widget.imageUrl);
        if (url == null) {
          return widget.errorWidget ?? _defaultErrorWidget();
        }
        return _buildImage(url, context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.loadWhenVisible) {
      return _buildContent(context);
    }

    return VisibilityDetector(
      key: Key('app-network-image-${widget.imageUrl}-$_retryKey'),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        final visible = info.visibleFraction > 0;
        if (visible != _isVisible) {
          setState(() => _isVisible = visible);
        }
      },
      child: _buildContent(context),
    );
  }
}
