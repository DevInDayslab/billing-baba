import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Shared network image with loading, error, and tap-to-retry states.
class AppNetworkImage extends StatefulWidget {
  const AppNetworkImage({
    required this.imageUrl,
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.memCacheWidth,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  var _retryKey = 0;

  void _retry() {
    setState(() {
      _retryKey += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = CachedNetworkImage(
      key: ValueKey('${widget.imageUrl}-$_retryKey'),
      imageUrl: widget.imageUrl,
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
  }
}
