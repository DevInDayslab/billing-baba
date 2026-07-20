import 'package:billing_baba/core/media/image_display_context.dart';
import 'package:billing_baba/core/media/media_image_url_resolver.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  ConsumerState<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends ConsumerState<AppNetworkImage> {
  var _retryKey = 0;
  late Future<String> _resolvedUrlFuture;

  @override
  void initState() {
    super.initState();
    _resolvedUrlFuture = _resolveUrl();
  }

  @override
  void didUpdateWidget(covariant AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.sourceMediaAssetId != widget.sourceMediaAssetId ||
        oldWidget.displayContext != widget.displayContext) {
      _resolvedUrlFuture = _resolveUrl();
    }
  }

  Future<String> _resolveUrl() async {
    if (widget.sourceMediaAssetId != null && widget.displayContext != null) {
      try {
        return ref.read(mediaImageUrlResolverProvider).resolve(
              sourceMediaAssetId: widget.sourceMediaAssetId!,
              context: widget.displayContext!,
              fallbackUrl: widget.imageUrl,
            );
      } catch (_) {
        return widget.imageUrl;
      }
    }
    return widget.imageUrl;
  }

  void _retry() {
    setState(() {
      _retryKey += 1;
      _resolvedUrlFuture = _resolveUrl();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _resolvedUrlFuture,
      builder: (context, snapshot) {
        final url = snapshot.data ?? widget.imageUrl;
        final child = CachedNetworkImage(
          key: ValueKey('$url-$_retryKey'),
          imageUrl: url,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          memCacheWidth: widget.memCacheWidth,
          placeholder: (_, _) =>
              widget.placeholder ??
              const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          errorWidget: (_, _, _) =>
              widget.errorWidget ??
              GestureDetector(
                onTap: _retry,
                behavior: HitTestBehavior.opaque,
                child: ColoredBox(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.refresh, size: 20),
                  ),
                ),
              ),
        );

        if (widget.borderRadius != null) {
          return ClipRRect(
            borderRadius: widget.borderRadius!,
            child: child,
          );
        }

        return child;
      },
    );
  }
}
